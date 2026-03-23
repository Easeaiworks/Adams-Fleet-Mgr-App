import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from './useAuth';

interface Organization {
  id: string;
  name: string;
  slug: string;
  logo_url: string | null;
  owner_id: string | null;
  is_active: boolean;
  created_at: string;
}

interface Subscription {
  id: string;
  plan_type: 'monthly' | 'annual';
  status: 'trialing' | 'active' | 'past_due' | 'canceled' | 'unpaid';
  price_cents: number;
  trial_ends_at: string | null;
  current_period_end: string | null;
}

export function useOrganization() {
  const { user } = useAuth();
  const [organization, setOrganization] = useState<Organization | null>(null);
  const [subscription, setSubscription] = useState<Subscription | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user) {
      fetchOrganization();
    } else {
      setOrganization(null);
      setSubscription(null);
      setLoading(false);
    }
  }, [user]);

  const fetchOrganization = async () => {
    try {
      // Get user's organization_id from their profile
      const { data: profile } = await supabase
        .from('profiles')
        .select('organization_id')
        .eq('id', user!.id)
        .single();

      if (!profile?.organization_id) {
        setLoading(false);
        return;
      }

      // Fetch organization details
      const { data: org } = await supabase
        .from('organizations')
        .select('*')
        .eq('id', profile.organization_id)
        .single();

      if (org) {
        setOrganization(org as Organization);

        // Fetch subscription
        const { data: sub } = await supabase
          .from('subscriptions')
          .select('*')
          .eq('organization_id', org.id)
          .order('created_at', { ascending: false })
          .limit(1)
          .single();

        if (sub) {
          setSubscription(sub as Subscription);
        }
      }
    } catch (error) {
      console.error('Error fetching organization:', error);
    } finally {
      setLoading(false);
    }
  };

  const isSubscriptionActive = () => {
    if (!subscription) return false;
    return ['trialing', 'active'].includes(subscription.status);
  };

  return {
    organization,
    subscription,
    loading,
    isSubscriptionActive,
    refetch: fetchOrganization,
  };
}
