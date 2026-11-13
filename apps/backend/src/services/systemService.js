import { env, isSupabaseConfigured } from '../config/env.js';

export function getSystemStatus() {
  return {
    service: 'sigse-cetis61-api',
    status: 'ok',
    environment: env.nodeEnv,
    supabase: {
      configured: isSupabaseConfigured(),
      mode: 'server-only'
    },
    timestamp: new Date().toISOString()
  };
}
