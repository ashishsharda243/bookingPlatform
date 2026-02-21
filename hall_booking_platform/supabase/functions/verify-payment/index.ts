// supabase/functions/verify-payment/index.ts
// Verifies Razorpay payment signature and updates booking + payment records.
// Requirements: 5.2, 5.3, 5.4, 5.6

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

/** Convert a hex string to Uint8Array. */
function hexToBytes(hex: string): Uint8Array {
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < hex.length; i += 2) {
    bytes[i / 2] = parseInt(hex.substring(i, i + 2), 16);
  }
  return bytes;
}

/** Convert ArrayBuffer to hex string. */
function bufferToHex(buffer: ArrayBuffer): string {
  return [...new Uint8Array(buffer)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

/**
 * Verify Razorpay payment signature using Web Crypto HMAC-SHA256.
 * Expected signature = HMAC-SHA256(key_secret, order_id + "|" + payment_id)
 */
async function verifySignature(
  orderId: string,
  paymentId: string,
  signature: string,
  keySecret: string,
): Promise<boolean> {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(keySecret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const message = `${orderId}|${paymentId}`;
  const mac = await crypto.subtle.sign("HMAC", key, encoder.encode(message));
  const expectedSignature = bufferToHex(mac);

  // Constant-time comparison to prevent timing attacks
  const sigBytes = hexToBytes(signature);
  const expectedBytes = hexToBytes(expectedSignature);

  if (sigBytes.length !== expectedBytes.length) return false;

  let result = 0;
  for (let i = 0; i < sigBytes.length; i++) {
    result |= sigBytes[i] ^ expectedBytes[i];
  }
  return result === 0;
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  try {
    const {
      razorpay_payment_id,
      razorpay_order_id,
      razorpay_signature,
      booking_id,
    } = await req.json();

    // Validate required fields
    if (
      !razorpay_payment_id ||
      !razorpay_order_id ||
      !razorpay_signature ||
      !booking_id
    ) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: razorpay_payment_id, razorpay_order_id, razorpay_signature, booking_id" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Load secrets from environment
    const razorpayKeySecret = Deno.env.get("RAZORPAY_KEY_SECRET");
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!razorpayKeySecret || !supabaseUrl || !supabaseServiceRoleKey) {
      return new Response(
        JSON.stringify({ error: "Server configuration error" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Initialize Supabase client with service role key (bypasses RLS)
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    // Verify Razorpay signature (Requirement 5.2)
    const isValid = await verifySignature(
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
      razorpayKeySecret,
    );

    if (!isValid) {
      // Payment verification failed (Requirement 5.4)
      // Update booking status to "failed"
      const { error: bookingError } = await supabase
        .from("bookings")
        .update({ booking_status: "failed", payment_status: "failed" })
        .eq("id", booking_id);

      if (bookingError) {
        console.error("Failed to update booking on verification failure:", bookingError);
      }

      // Release the slot back to "available"
      const { data: booking } = await supabase
        .from("bookings")
        .select("slot_id")
        .eq("id", booking_id)
        .single();

      if (booking?.slot_id) {
        const { error: slotError } = await supabase
          .from("slots")
          .update({ status: "available" })
          .eq("id", booking.slot_id);

        if (slotError) {
          console.error("Failed to release slot on verification failure:", slotError);
        }
      }

      return new Response(
        JSON.stringify({ error: "Invalid payment signature" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Signature valid — fetch booking to get amount (Requirement 5.3)
    const { data: bookingData, error: fetchError } = await supabase
      .from("bookings")
      .select("id, total_price, slot_id, booking_status")
      .eq("id", booking_id)
      .single();

    if (fetchError || !bookingData) {
      return new Response(
        JSON.stringify({ error: "Booking not found" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Guard against re-processing an already confirmed booking
    if (bookingData.booking_status === "confirmed") {
      return new Response(
        JSON.stringify({ message: "Booking already confirmed" }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Update booking to confirmed (Requirement 5.3)
    const { error: updateBookingError } = await supabase
      .from("bookings")
      .update({ booking_status: "confirmed", payment_status: "completed" })
      .eq("id", booking_id);

    if (updateBookingError) {
      console.error("Failed to confirm booking:", updateBookingError);
      return new Response(
        JSON.stringify({ error: "Failed to update booking status" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Create payment record (Requirement 5.6)
    const { error: paymentError } = await supabase
      .from("payments")
      .insert({
        booking_id: booking_id,
        razorpay_payment_id: razorpay_payment_id,
        razorpay_order_id: razorpay_order_id,
        status: "completed",
        amount: bookingData.total_price,
      });

    if (paymentError) {
      console.error("Failed to create payment record:", paymentError);
      return new Response(
        JSON.stringify({ error: "Failed to create payment record" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // --- Send push notifications (Requirements 8.1, 8.3) ---
    // Fetch booking details for notification content
    const { data: fullBooking } = await supabase
      .from("bookings")
      .select("user_id, hall_id, halls(name, owner_id), slots(date, start_time)")
      .eq("id", booking_id)
      .single();

    if (fullBooking) {
      const hallName = (fullBooking.halls as { name: string })?.name ?? "Hall";
      const ownerId = (fullBooking.halls as { owner_id: string })?.owner_id;
      const slotDate = (fullBooking.slots as { date: string })?.date ?? "";
      const slotTime = (fullBooking.slots as { start_time: string })?.start_time ?? "";

      const notificationUrl = `${supabaseUrl}/functions/v1/send-notification`;
      const notificationHeaders = {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${supabaseServiceRoleKey}`,
      };

      // Notify the user (Requirement 8.1)
      try {
        await fetch(notificationUrl, {
          method: "POST",
          headers: notificationHeaders,
          body: JSON.stringify({
            user_id: fullBooking.user_id,
            title: "Booking Confirmed",
            body: `Your booking at ${hallName} on ${slotDate} at ${slotTime} is confirmed!`,
            data: { booking_id, type: "booking_confirmed" },
          }),
        });
      } catch (notifErr) {
        console.error("Failed to send user notification:", notifErr);
      }

      // Notify the hall owner (Requirement 8.3)
      if (ownerId) {
        try {
          await fetch(notificationUrl, {
            method: "POST",
            headers: notificationHeaders,
            body: JSON.stringify({
              user_id: ownerId,
              title: "New Booking",
              body: `A new booking has been confirmed at ${hallName} on ${slotDate} at ${slotTime}.`,
              data: { booking_id, type: "new_booking" },
            }),
          });
        } catch (notifErr) {
          console.error("Failed to send owner notification:", notifErr);
        }
      }
    }

    return new Response(
      JSON.stringify({
        message: "Payment verified successfully",
        booking_id: booking_id,
        booking_status: "confirmed",
        payment_status: "completed",
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Unexpected error in verify-payment:", err);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
