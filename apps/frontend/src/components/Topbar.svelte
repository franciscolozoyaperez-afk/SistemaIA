<script>
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { user, signOut } from '../stores/auth';
  import { toggleSidebar } from '../stores/ui';
  import Icon from './Icon.svelte';

  const titles = {
    '/dashboard': 'Panel principal',
    '/dashboard/estudiantes': 'Estudiantes',
    '/dashboard/accesos': 'Control de acceso',
    '/dashboard/incidencias': 'Incidencias',
    '/dashboard/tutores': 'Padres y tutores',
    '/dashboard/notificaciones': 'Notificaciones',
    '/dashboard/reportes': 'Reportes',
    '/dashboard/usuarios': 'Usuarios y roles'
  };

  let title = $derived(titles[$page.url.pathname] || 'SIGSE-CETIS 61');
  let displayName = $derived($user?.user_metadata?.full_name || $user?.email || 'Usuario');

  async function handleSignOut() {
    await signOut();
    await goto('/login', { replaceState: true });
  }
</script>

<header class="topbar">
  <button class="icon-button mobile-only" type="button" aria-label="Abrir menú" onclick={toggleSidebar}>
    <Icon name="dashboard" size={22} />
  </button>

  <div>
    <span class="eyebrow">CETIS 61</span>
    <h1>{title}</h1>
  </div>

  <div class="user-menu">
    <div class="user-copy">
      <strong>{displayName}</strong>
      <span>{$user?.email || 'Sesión activa'}</span>
    </div>
    <button class="icon-button" type="button" aria-label="Cerrar sesión" title="Cerrar sesión" onclick={handleSignOut}>
      <Icon name="logout" size={20} />
    </button>
  </div>
</header>

<style>
  .topbar {
    position: sticky;
    top: 0;
    z-index: 20;
    display: flex;
    align-items: center;
    gap: 1rem;
    min-height: 4.25rem;
    padding: 0.75rem 1rem;
    border-bottom: 1px solid var(--color-border);
    background: rgb(255 255 255 / 0.92);
    backdrop-filter: blur(10px);
  }

  h1 {
    margin: 0;
    font-size: 1.15rem;
  }

  .eyebrow {
    color: var(--color-muted);
    font-size: 0.72rem;
    font-weight: 700;
    letter-spacing: 0.08em;
    text-transform: uppercase;
  }

  .user-menu {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-left: auto;
  }

  .user-copy {
    display: grid;
    text-align: right;
  }

  .user-copy strong {
    font-size: 0.9rem;
  }

  .user-copy span {
    color: var(--color-muted);
    font-size: 0.78rem;
  }

  .icon-button {
    display: inline-grid;
    place-items: center;
    width: 2.5rem;
    height: 2.5rem;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    color: var(--color-text);
    background: var(--color-surface);
    cursor: pointer;
  }

  .icon-button:hover {
    color: var(--color-primary-dark);
    border-color: var(--color-primary);
  }

  .mobile-only {
    display: inline-grid;
  }

  @media (min-width: 1024px) {
    .mobile-only {
      display: none;
    }
  }
</style>
