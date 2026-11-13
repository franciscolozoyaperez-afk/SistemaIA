<script>
  import logoUrl from '../assets/logo.svg';

  let { children } = $props();
</script>

<div class="auth-shell">
  <section class="auth-card" aria-label="Inicio de sesión">
    <div class="auth-brand">
      <img src={logoUrl} alt="Logo SIGSE-CETIS 61" width="48" height="48" />
      <div>
        <strong>SIGSE-CETIS 61</strong>
        <span>Centro de Estudios Tecnológicos Industrial y de Servicios No. 61</span>
      </div>
    </div>
    {@render children()}
  </section>
</div>

<style>
  .auth-shell {
    display: grid;
    min-height: 100vh;
    place-items: center;
    padding: 1.5rem;
    background:
      radial-gradient(circle at top left, rgb(219 234 254 / 0.8), transparent 32rem),
      linear-gradient(135deg, #eff6ff 0%, #f8fafc 55%, #e2e8f0 100%);
  }

  .auth-card {
    width: min(100%, 28rem);
    padding: 2rem;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-lg);
    background: var(--color-surface);
    box-shadow: var(--shadow-md);
  }

  .auth-brand {
    display: flex;
    align-items: center;
    gap: 1rem;
    margin-bottom: 1.75rem;
    padding-bottom: 1.25rem;
    border-bottom: 1px solid var(--color-border);
  }

  .auth-brand div {
    display: grid;
  }

  .auth-brand strong {
    font-size: 1.1rem;
  }

  .auth-brand span {
    color: var(--color-muted);
    font-size: 0.8rem;
  }
</style>
