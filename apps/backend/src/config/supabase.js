import { createClient } from '@supabase/supabase-js';
import { requireSupabaseEnv } from '../config/env.js';

let supabaseAdminClient;

export function getSupabaseAdmin() {
  if (supabaseAdminClient) {
    return supabaseAdminClient;
  }

  const { url, serviceRoleKey } = requireSupabaseEnv();

  supabaseAdminClient = createClient(url, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false
    }
  });

  return supabaseAdminClient;
}
