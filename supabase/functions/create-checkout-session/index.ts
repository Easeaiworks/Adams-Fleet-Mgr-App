import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Price mapping in cents
const PRICE_MAP: Record<string, number> = {
  monthly: 9900,    // $99.00/mo
  annual: 89100,    // $891.00/yr (25% off)
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY");

    // If Stripe is not configured, return friendly error
    if (!stripeSecretKey) {
      console.warn("STRIPE_SECRET_KEY not configured");
      return new Response(
        JSON.stringify({
          error: "Stripe is not configured yet. Add your STRIPE_SECRET_KEY in Supabase Edge Function secrets.",
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Parse request body
    const { planType, organizationId } = await req.json();

    // Validate inputs
    if (!planType || !organizationId) {
      return new Response(
        JSON.stringify({
          error: "Missing required fields: planType and organizationId",
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (!Object.keys(PRICE_MAP).includes(planType)) {
      return new Response(
        JSON.stringify({
          error: `Invalid planType. Must be one of: ${Object.keys(PRICE_MAP).join(", ")}`,
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const priceInCents = PRICE_MAP[planType];

    // Get the origin from the request for success/cancel URLs
    const origin = req.headers.get("origin") || "https://example.com";

    // Create Stripe Checkout Session via API
    const checkoutResponse = await fetch(
      "https://api.stripe.com/v1/checkout/sessions",
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${stripeSecretKey}`,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: new URLSearchParams({
          "mode": "subscription",
          "line_items[0][price_data][currency]": "usd",
          "line_items[0][price_data][product_data][name]":
            planType === "monthly" ? "Fleet Pilot Monthly" : "Fleet Pilot Annual",
          "line_items[0][price_data][recurring][interval]":
            planType === "monthly" ? "month" : "year",
          "line_items[0][price_data][unit_amount]": priceInCents.toString(),
          "line_items[0][quantity]": "1",
          "success_url": `${origin}/dashboard?checkout=success`,
          "cancel_url": `${origin}/dashboard?checkout=canceled`,
          "allow_promotion_codes": "true",
          "metadata[organization_id]": organizationId,
          "metadata[plan_type]": planType,
        }).toString(),
      }
    );

    if (!checkoutResponse.ok) {
      const errorData = await checkoutResponse.json();
      console.error("Stripe API error:", errorData);
      return new Response(
        JSON.stringify({
          error: "Failed to create checkout session",
          details: errorData,
        }),
        {
          status: checkoutResponse.status,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const session = await checkoutResponse.json();
    console.log("Checkout session created:", session.id);

    return new Response(
      JSON.stringify({ url: session.url }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    console.error("Error in create-checkout-session:", error);
    return new Response(
      JSON.stringify({ error: errorMessage }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
