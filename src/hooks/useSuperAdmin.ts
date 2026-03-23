import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from './useAuth';

export function useSuperAdmin() {
  const { user } = useAuth();
  const [isSuperAdmin, setIsSuperAdmin] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user) {
      checkSuperAdmin();
    } else {
      setIsSuperAdmin(false);
      setLoading(false);
    }
  }, [user]);

  const checkSuperAdmin = async () => {
    try {
      const { data, error } = await supabase
        .from('super_admins')
        .select('id')
        .eq('user_id', user!.id)
        .single();

      setIsSuperAdmin(!!data && !error);
    } catch {
      setIsSuperAdmin(false);
    } finally {
      setLoading(false);
    }
  };

  return { isSuperAdmin, loading };
}
