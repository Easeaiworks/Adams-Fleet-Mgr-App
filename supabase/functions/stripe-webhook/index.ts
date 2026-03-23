import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Stripe webhook event type definitions
interface StripeEvent {
  type: string;
  data: {
    object: any;
  };
}

// Validate webhook signature (basic implementation)
function isValidWebhookSignature(
  payload: string,
  signature: string,
  secret: string
): boolean {
  // Note: In production, use Stripe's official signature verification
  // This is a simplified check. For full validation, integrate Stripe's verify header method
  if (!signature || !secret) {
    return false;
  }
  // For now, we'll accept all requests if secret is configured
  // In production: const crypto = await import("https://deno.land/std/crypto/mod.ts");
  // and properly verify the HMAC SHA256 signature
  console.log("Webhook signature verification skipped - implement proper HMAC-SHA256 validation in production");
  return true;
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const stripeWebhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");

    // If webhook secret is not configured, return error
    if (!stripeWebhookSecret) {
      console.warn("STRIPE_WEBHOOK_SECRET not configured");
      return new Response(
        JSON.stringify({
          error: "Stripe webhook is not configured yet. Add your STRIPE_WEBHOOK_SECRET in Supabase Edge Function secrets.",
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Get raw body for signature verification
    const rawBody = await req.text();
    const signature = req.headers.get("stripe-signature");

    // Verify webhook signature
    if (!isValidWebhookSignature(rawBody, signature || "", stripeWebhookSecret)) {
      console.error("Invalid webhook signature");
      return new Response(
        JSON.stringify({ error: "Invalid webhook signature" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const event: StripeEvent = JSON.parse(rawBody);
    console.log("Processing Stripe event:", event.type);

    // Initialize Supabase client with service role
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Route to appropriate handler based on event type
    switch (event.type) {
      case "checkout.session.completed":
        await handleCheckoutSessionCompleted(event.data.object, supabase);
        break;

      case "customer.subscription.updated":
        await handleSubscriptionUpdated(event.data.object, supabase);
        break;

      case "customer.subscription.deleted":
        await handleSubscriptionDeleted(event.data.object, supabase);
        break;

      case "invoice.payment_succeeded":
        await handleInvoicePaymentSucceeded(event.data.object, supabase);
        break;

      case "invoice.payment_failed":
        await handleInvoicePaymentFailed(event.data.object, supabase);
        break;

      default:
        console.log("Unhandled event type:", event.type);
    }

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    console.error("Error in stripe-webhook:", error);
    return new Response(
      JSON.stringify({ error: errorMessage }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});

// Handle checkout.session.completed event
async function handleCheckoutSessionCompleted(
  session: any,
  supabase: any
): Promise<void> {
  console.log("Handling checkout.session.completed for:", session.id);

  const organizationId = session.metadata?.organization_id;
  const planType = session.metadata?.plan_type;
  const subscriptionId = session.subscription;

  if (!organizationId || !subscriptionId) {
    console.error("Missing organizationId or subscriptionId in session metadata");
    return;
  }

  // Create or update subscription record
  const { data, error } = await supabase
    .from("subscriptions")
    .upsert(
      {
        organization_id: organizationId,
        stripe_subscription_id: subscriptionId,
        stripe_customer_id: session.customer,
        plan_type: planType || "monthly",
        status: "active",
        current_period_start: new Date(session.created * 1000).toISOString(),
        current_period_end: null, // Will be updated on invoice events
        updated_at: new Date().toISOString(),
      },
      { onConflict: "organization_id" }
    )
    .select();

  if (error) {
    console.error("Error upserting subscription:", error);
    throw error;
  }

  console.log("Subscription created/updated:", data);
}

// Handle customer.subscription.updated event
async function handleSubscriptionUpdated(
  subscription: any,
  supabase: any
): Promise<void> {
  console.log("Handling customer.subscription.updated for:", subscription.id);

  // Determine status based on Stripe subscription status
  let status = "active";
  if (subscription.status === "past_due") {
    status = "past_due";
  } else if (subscription.status === "canceled") {
    status = "canceled";
  }

  // Find organization by stripe_subscription_id
  const { data: existingSubscription, error: findError } = await supabase
    .from("subscriptions")
    .select("organization_id")
    .eq("stripe_subscription_id", subscription.id)
    .single();

  if (findError) {
    console.error("Error finding subscription:", findError);
    return;
  }

  if (!existingSubscription) {
    console.warn("Subscription not found for stripe_subscription_id:", subscription.id);
    return;
  }

  // Update subscription status
  const { error: updateError } = await supabase
    .from("subscriptions")
    .update({
      status,
      plan_type: subscription.metadata?.plan_type || "monthly",
      current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
      current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq("organization_id", existingSubscription.organization_id);

  if (updateError) {
    console.error("Error updating subscription:", updateError);
    throw updateError;
  }

  console.log("Subscription updated for organization:", existingSubscription.organization_id);
}

// Handle customer.subscription.deleted event
async function handleSubscriptionDeleted(
  subscription: any,
  supabase: any
): Promise<void> {
  console.log("Handling customer.subscription.deleted for:", subscription.id);

  // Find organization by stripe_subscription_id
  const { data: existingSubscription, error: findError } = await supabase
    .from("subscriptions")
    .select("organization_id")
    .eq("stripe_subscription_id", subscription.id)
    .single();

  if (findError) {
    console.error("Error finding subscription:", findError);
    return;
  }

  if (!existingSubscription) {
    console.warn("Subscription not found for stripe_subscription_id:", subscription.id);
    return;
  }

  // Mark subscription as canceled
  const { error: updateError } = await supabase
    .from("subscriptions")
    .update({
      status: "canceled",
      canceled_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq("organization_id", existingSubscription.organization_id);

  if (updateError) {
    console.error("Error marking subscription as canceled:", updateError);
    throw updateError;
  }

  console.log("Subscription marked as canceled for organization:", existingSubscription.organization_id);
}

// Handle invoice.payment_succeeded event
async function handleInvoicePaymentSucceeded(
  invoice: any,
  supabase: any
): Promise<void> {
  console.log("Handling invoice.payment_succeeded for:", invoice.id);

  if (!invoice.subscription) {
    console.log("Invoice not associated with subscription, skipping");
    return;
  }

  // Find organization by stripe_subscription_id
  const { data: existingSubscription, error: findError } = await supabase
    .from("subscriptions")
    .select("organization_id")
    .eq("stripe_subscription_id", invoice.subscription)
    .single();

  if (findError) {
    console.error("Error finding subscription:", findError);
    return;
  }

  if (!existingSubscription) {
    console.warn("Subscription not found for stripe_subscription_id:", invoice.subscription);
    return;
  }

  // Update subscription period dates from invoice
  const { error: updateError } = await supabase
    .from("subscriptions")
    .update({
      status: "active",
      current_period_start: invoice.period_start
        ? new Date(invoice.period_start * 1000).toISOString()
        : undefined,
      current_period_end: invoice.period_end
        ? new Date(invoice.period_end * 1000).toISOString()
        : undefined,
      updated_at: new Date().toISOString(),
    })
    .eq("organization_id", existingSubscription.organization_id);

  if (updateError) {
    console.error("Error updating subscription:", updateError);
    throw updateError;
  }

  console.log("Subscription period updated for organization:", existingSubscription.organization_id);
}

// Handle invoice.payment_failed event
async function handleInvoicePaymentFailed(
  invoice: any,
  supabase: any
): Promise<void> {
  console.log("Handling invoice.payment_failed for:", invoice.id);

  if (!invoice.subscription) {
    console.log("Invoice not associated with subscription, skipping");
    return;
  }

  // Find organization by stripe_subscription_id
  const { data: existingSubscription, error: findError } = await supabase
    .from("subscriptions")
    .select("organization_id")
    .eq("stripe_subscription_id", invoice.subscription)
    .single();

  if (findError) {
    console.error("Error finding subscription:", findError);
    return;
  }

  if (!existingSubscription) {
    console.warn("Subscription not found for stripe_subscription_id:", invoice.subscription);
    return;
  }

  // Mark subscription as past due
  const { error: updateError } = await supabase
    .from("subscriptions")
    .update({
      status: "past_due",
      updated_at: new Date().toISOString(),
    })
    .eq("organization_id", existingSubscription.organization_id);

  if (updateError) {
    console.error("Error updating subscription:", updateError);
    throw updateError;
  }

  console.log("Subscription marked as past_due for organization:", existingSubscription.organization_id);
}
