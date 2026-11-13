import { writable } from 'svelte/store';
import { getSupabase } from '../services/supabase';

export const user = writable(null);
export const session = writable(null);
export const authLoading = writable(true);
export const authError = writable(null);

let initialized = false;
let authSubscription;

export async function initAuth() {
  if (initialized) {
    return;
  }

  initialized = true;
  authLoading.set(true);
  authError.set(null);

  try {
    const supabase = getSupabase();
    const { data, error } = await supabase.auth.getSession();

    if (error) {
      throw error;
    }

    session.set(data.session);
    user.set(data.session?.user ?? null);

    const { data: subscription } = supabase.auth.onAuthStateChange((_event, nextSession) => {
      session.set(nextSession);
      user.set(nextSession?.user ?? null);
    });

    authSubscription = subscription;
  } catch (error) {
    authError.set(error.message || 'No fue posible inicializar la autenticación.');
    user.set(null);
    session.set(null);
  } finally {
    authLoading.set(false);
  }
}

export async function signIn(email, password) {
  authError.set(null);

  try {
    const supabase = getSupabase();
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });

    if (error) {
      throw error;
    }

    session.set(data.session);
    user.set(data.user);
    return { error: null };
  } catch (error) {
    const message = error.message || 'No fue posible iniciar sesión.';
    authError.set(message);
    return { error: message };
  }
}

export async function signUp(email, password, fullName) {
  authError.set(null);

  try {
    const supabase = getSupabase();
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: { full_name: fullName }
      }
    });

    if (error) {
      throw error;
    }

    if (data.session) {
      session.set(data.session);
      user.set(data.user);
      return { error: null, needsConfirmation: false };
    }

    return { error: null, needsConfirmation: true };
  } catch (error) {
    const message = error.message || 'No fue posible crear la cuenta.';
    authError.set(message);
    return { error: message, needsConfirmation: false };
  }
}

export async function signInWithGoogle() {
  authError.set(null);

  try {
    const supabase = getSupabase();
    const redirectTo = `${window.location.origin}/dashboard`;
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: { redirectTo }
    });

    if (error) {
      throw error;
    }

    return { error: null };
  } catch (error) {
    const message = error.message || 'No fue posible iniciar sesión con Google.';
    authError.set(message);
    return { error: message };
  }
}

export async function signOut() {
  try {
    await getSupabase().auth.signOut();
  } catch {
    // La sesión local se limpia aunque Supabase no esté configurado.
  } finally {
    session.set(null);
    user.set(null);
  }
}
