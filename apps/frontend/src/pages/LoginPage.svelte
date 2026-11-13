<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { authError, initAuth, signIn, signInWithGoogle, signUp, user } from '../stores/auth';

  let mode = $state('login');
  let fullName = $state('');
  let email = $state('');
  let password = $state('');
  let loading = $state(false);
  let notice = $state('');
  let localError = $state('');

  onMount(async () => {
    await initAuth();

    if ($user) {
      await goto('/dashboard', { replaceState: true });
    }
  });

  function switchMode(nextMode) {
    mode = nextMode;
    localError = '';
    notice = '';
  }

  async function handleSubmit(event) {
    event.preventDefault();
    localError = '';
    notice = '';

    if (!email || !password) {
      localError = 'Ingresa tu correo y contraseña.';
      return;
    }

    if (mode === 'register' && !fullName.trim()) {
      localError = 'Ingresa tu nombre completo.';
      return;
    }

    if (password.length < 6) {
      localError = 'La contraseña debe tener al menos 6 caracteres.';
      return;
    }

    loading = true;

    if (mode === 'register') {
      const { error, needsConfirmation } = await signUp(email.trim(), password, fullName.trim());
      loading = false;

      if (!error && needsConfirmation) {
        notice = 'Cuenta creada. Revisa tu correo para confirmarla antes de iniciar sesión.';
        switchMode('login');
      } else if (!error) {
        await goto('/dashboard', { replaceState: true });
      }
      return;
    }

    const { error } = await signIn(email.trim(), password);
    loading = false;

    if (!error) {
      await goto('/dashboard', { replaceState: true });
    }
  }

  async function handleGoogle() {
    localError = '';
    notice = '';
    loading = true;
    const { error } = await signInWithGoogle();
    if (error) {
      loading = false;
    }
  }
</script>

<svelte:head>
  <title>{mode === 'login' ? 'Inicio de sesión' : 'Crear cuenta'} | SIGSE-CETIS 61</title>
</svelte:head>

<div class="login-copy">
  <span class="eyebrow">Acceso institucional</span>
  <h1>Gestión y seguimiento estudiantil</h1>
  <p>Administra estudiantes, accesos, incidencias y comunicación con padres o tutores desde un solo lugar.</p>
</div>

<div class="mode-tabs" role="tablist">
  <button
    type="button"
    role="tab"
    aria-selected={mode === 'login'}
    class:active={mode === 'login'}
    onclick={() => switchMode('login')}
  >
    Iniciar sesión
  </button>
  <button
    type="button"
    role="tab"
    aria-selected={mode === 'register'}
    class:active={mode === 'register'}
    onclick={() => switchMode('register')}
  >
    Crear cuenta
  </button>
</div>

<form class="login-form" onsubmit={handleSubmit} novalidate>
  {#if mode === 'register'}
    <label>
      Nombre completo
      <input type="text" bind:value={fullName} autocomplete="name" placeholder="Nombre y apellidos" required />
    </label>
  {/if}

  <label>
    Correo electrónico
    <input type="email" bind:value={email} autocomplete="email" placeholder="nombre@correo.com" required />
  </label>

  <label>
    Contraseña
    <input type="password" bind:value={password} autocomplete={mode === 'login' ? 'current-password' : 'new-password'} placeholder="••••••••" required />
  </label>

  {#if localError || $authError}
    <div class="form-error" role="alert">{localError || $authError}</div>
  {/if}

  {#if notice}
    <div class="form-notice" role="status">{notice}</div>
  {/if}

  <button class="primary-button" type="submit" disabled={loading}>
    {loading ? 'Procesando...' : mode === 'login' ? 'Entrar al sistema' : 'Crear cuenta'}
  </button>
</form>

<div class="divider" aria-hidden="true"><span>o</span></div>

<button class="google-button" type="button" onclick={handleGoogle} disabled={loading}>
  <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true">
    <path fill="#4285F4" d="M23.49 12.27c0-.79-.07-1.54-.19-2.27H12v4.51h6.47a5.57 5.57 0 0 1-2.4 3.58v3h3.86c2.26-2.09 3.56-5.17 3.56-8.82Z" />
    <path fill="#34A853" d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.86-3c-1.08.72-2.45 1.16-4.07 1.16-3.13 0-5.78-2.11-6.73-4.96H1.29v3.09A11.99 11.99 0 0 0 12 24Z" />
    <path fill="#FBBC05" d="M5.27 14.29a7.2 7.2 0 0 1 0-4.58V6.62H1.29a12 12 0 0 0 0 10.76l3.98-3.09Z" />
    <path fill="#EA4335" d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42A11.98 11.98 0 0 0 12 0 11.99 11.99 0 0 0 1.29 6.62l3.98 3.09C6.22 6.86 8.87 4.75 12 4.75Z" />
  </svg>
  Continuar con Google
</button>

<p class="login-note">Las credenciales son administradas por Supabase Auth. Este proyecto aún no incluye recuperación de contraseña.</p>

<style>
  .login-copy {
    margin-bottom: 1.5rem;
  }

  .eyebrow {
    color: var(--color-primary);
    font-size: 0.78rem;
    font-weight: 800;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }

  h1 {
    margin: 0.35rem 0 0.5rem;
    font-size: 1.75rem;
    line-height: 1.15;
  }

  p {
    margin: 0;
    color: var(--color-muted);
  }

  .mode-tabs {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 0.25rem;
    margin-bottom: 1.25rem;
    padding: 0.25rem;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    background: var(--color-background);
  }

  .mode-tabs button {
    min-height: 2.4rem;
    border: 0;
    border-radius: calc(var(--radius-md) - 0.25rem);
    background: transparent;
    color: var(--color-muted);
    font-weight: 700;
    cursor: pointer;
  }

  .mode-tabs button.active {
    background: var(--color-surface);
    color: var(--color-primary);
    box-shadow: var(--shadow-sm);
  }

  .login-form {
    display: grid;
    gap: 1rem;
  }

  label {
    display: grid;
    gap: 0.4rem;
    color: var(--color-text);
    font-size: 0.9rem;
    font-weight: 700;
  }

  input {
    width: 100%;
    min-height: 2.85rem;
    padding: 0 0.85rem;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    background: #fff;
    color: var(--color-text);
  }

  input:focus {
    outline: 3px solid rgb(29 78 216 / 0.18);
    border-color: var(--color-primary);
  }

  .form-error {
    padding: 0.75rem 0.9rem;
    border: 1px solid #fecaca;
    border-radius: var(--radius-md);
    color: var(--color-danger);
    background: #fef2f2;
    font-size: 0.9rem;
  }

  .form-notice {
    padding: 0.75rem 0.9rem;
    border: 1px solid #bbf7d0;
    border-radius: var(--radius-md);
    color: var(--color-success);
    background: #f0fdf4;
    font-size: 0.9rem;
  }

  .primary-button {
    min-height: 2.9rem;
    border: 0;
    border-radius: var(--radius-md);
    color: #fff;
    background: var(--color-primary);
    font-weight: 800;
    cursor: pointer;
  }

  .primary-button:hover:not(:disabled) {
    background: var(--color-primary-dark);
  }

  .primary-button:disabled,
  .google-button:disabled {
    cursor: wait;
    opacity: 0.7;
  }

  .divider {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin: 1.25rem 0;
    color: var(--color-muted);
    font-size: 0.85rem;
  }

  .divider::before,
  .divider::after {
    content: '';
    flex: 1;
    border-top: 1px solid var(--color-border);
  }

  .google-button {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.65rem;
    width: 100%;
    min-height: 2.9rem;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    background: #fff;
    color: var(--color-text);
    font-weight: 700;
    cursor: pointer;
  }

  .google-button:hover:not(:disabled) {
    background: var(--color-background);
  }

  .login-note {
    margin-top: 1rem;
    font-size: 0.8rem;
  }
</style>
