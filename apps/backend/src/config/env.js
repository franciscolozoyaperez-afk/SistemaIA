import 'dotenv/config';

function parseCorsOrigins(value) {
  return (value || '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
}

function parseInteger(value, fallback) {
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

export const env = {
  nodeEnv: process.env.NODE_ENV || 'development',
  isProduction: process.env.NODE_ENV === 'production',
  port: parseInteger(process.env.PORT, 3001),
  supabaseUrl: process.env.SUPABASE_URL || '',
  supabaseServiceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY || '',
  corsOrigins: parseCorsOrigins(process.env.API_CORS_ORIGINS),
  rateLimitWindowMs: parseInteger(process.env.RATE_LIMIT_WINDOW_MS, 60_000),
  rateLimitMax: parseInteger(process.env.RATE_LIMIT_MAX, 120)
};

export function isSupabaseConfigured() {
  return Boolean(env.supabaseUrl && env.supabaseServiceRoleKey);
}

export function requireSupabaseEnv() {
  if (!env.supabaseUrl || !env.supabaseServiceRoleKey) {
    throw new Error('Supabase no está configurado. Define SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY.');
  }

  return {
    url: env.supabaseUrl,
    serviceRoleKey: env.supabaseServiceRoleKey
  };
}
