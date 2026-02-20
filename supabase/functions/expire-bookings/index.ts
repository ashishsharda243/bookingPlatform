// supabase/functions/expire-bookings/index.ts
// Expires pending bookings older than 10 minutes and releases their slots.
// Designed to run every 5 minutes via pg_cron.
// Requirements: 5.5

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceRoleKey) {
      return new Response(
        JSON.stringify({ error: "Server configuration error" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Use service role key to bypass RLS
    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    // Find pending bookings older than 10 minutes (Requirement 5.5)
    const tenMinutesAgo = new Date(Date.now() - 10 * 60 * 1000).toISOString();

    const { data: expiredBookings, error: fetchError } = await supabase
      .from("bookings")
      .select("id, slot_id")
      .eq("booking_status", "pending")
      .lt("created_at", tenMinutesAgo);

    if (fetchError) {
      console.error("Failed to fetch expired bookings:", fetchError);
      return new Response(
        JSON.stringify({ error: "Failed to query expired bookings" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    if (!expiredBookings || expiredBookings.length === 0) {
      return new Response(
        JSON.stringify({ message: "No expired bookings found", expired: 0 }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const bookingIds = expiredBookings.map((b: { id: string }) => b.id);
    const slotIds = expiredBookings.map(
      (b: { slot_id: string }) => b.slot_id,
    );

    // Update all expired bookings: cancel booking and mark payment as failed
    // (payment_status CHECK constraint allows: pending, completed, failed, refunded)
    const { error: updateBookingsError } = await supabase
      .from("bookings")
      .update({
        booking_status: "cancelled",
        payment_status: "failed",
      })
      .in("id", bookingIds);

    if (updateBookingsError) {
      console.error("Failed to cancel expired bookings:", updateBookingsError);
      return new Response(
        JSON.stringify({ error: "Failed to update expired bookings" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Release associated slots back to "available"
    const { error: updateSlotsError } = await supabase
      .from("slots")
      .update({ status: "available" })
      .in("id", slotIds);

    if (updateSlotsError) {
      console.error("Failed to release slots:", updateSlotsError);
      return new Response(
        JSON.stringify({
          error: "Bookings cancelled but failed to release some slots",
          expired: bookingIds.length,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    console.log(
      `Expired ${bookingIds.length} booking(s): ${bookingIds.join(", ")}`,
    );

    return new Response(
      JSON.stringify({
        message: `Successfully expired ${bookingIds.length} booking(s)`,
        expired: bookingIds.length,
        booking_ids: bookingIds,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (err) {
    console.error("Unexpected error in expire-bookings:", err);
    return new Response(
      JSON.stringify({ error: "Internal server error" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
