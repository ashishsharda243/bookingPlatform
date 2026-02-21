// supabase/functions/create-order/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { booking_id } = await req.json()

        // Initialize Supabase Admin Client
        const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
        const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
        const supabaseDispatcher = createClient(supabaseUrl, supabaseServiceRoleKey);

        // SKIP PAYMENT: Directly confirm the booking
        const { error } = await supabaseDispatcher
            .from('bookings')
            .update({
                booking_status: 'confirmed',
                payment_status: 'completed' // Satisfies check constraint (pending, completed, failed, refunded)
            })
            .eq('id', booking_id);

        if (error) throw error;

        return new Response(
            JSON.stringify({
                order_id: "skipped_payment", // Signal to client that payment is skipped
                message: "Booking confirmed (Payment Skipped)",
                skipped_payment: true
            }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
        )

    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
        )
    }
})
