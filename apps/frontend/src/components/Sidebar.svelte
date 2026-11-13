<script>
  import { page } from '$app/stores';
  import { MODULES } from '@sigse/shared';
  import Icon from './Icon.svelte';
  import { sidebarOpen, closeSidebar } from '../stores/ui';

  function isActive(path) {
    return $page.url.pathname === path;
  }
</script>

<aside class="sidebar" class:open={$sidebarOpen} aria-label="Navegación principal">
  <div class="brand">
    <span class="brand-mark">61</span>
    <span>
      <strong>SIGSE-CETIS 61</strong>
      <small>Gestión estudiantil</small>
    </span>
  </div>

  <nav>
    {#each MODULES as item}
      <a
        class="nav-link"
        class:active={isActive(item.path)}
        href={item.path}
        aria-current={isActive(item.path) ? 'page' : undefined}
        onclick={closeSidebar}
      >
        <Icon name={item.icon} size={19} />
        <span>{item.label}</span>
      </a>
    {/each}
  </nav>
</aside>

<style>
  .sidebar {
    position: fixed;
    inset: 0 auto 0 0;
    z-index: 30;
    display: flex;
    flex-direction: column;
    width: min(17rem, 86vw);
    padding: 1.25rem;
    border-right: 1px solid var(--color-border);
    background: var(--color-surface);
    box-shadow: var(--shadow-md);
    transform: translateX(-105%);
    transition: transform 180ms ease;
  }

  .sidebar.open {
    transform: translateX(0);
  }

  .brand {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding-bottom: 1.25rem;
    border-bottom: 1px solid var(--color-border);
  }

  .brand-mark {
    display: inline-grid;
    place-items: center;
    width: 2.5rem;
    height: 2.5rem;
    border-radius: var(--radius-md);
    color: #fff;
    background: var(--color-primary);
    font-weight: 800;
  }

  .brand span:last-child {
    display: grid;
  }

  .brand strong {
    font-size: 0.95rem;
    line-height: 1.2;
  }

  .brand small {
    color: var(--color-muted);
    font-size: 0.75rem;
  }

  nav {
    display: grid;
    gap: 0.35rem;
    margin-top: 1rem;
    overflow-y: auto;
  }

  .nav-link {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    min-height: 2.75rem;
    padding: 0 0.85rem;
    border-radius: var(--radius-md);
    color: #334155;
    font-weight: 600;
  }

  .nav-link:hover {
    color: var(--color-primary-dark);
    background: #f1f5f9;
  }

  .nav-link.active {
    color: var(--color-primary-dark);
    background: var(--color-primary-soft);
  }

  @media (min-width: 1024px) {
    .sidebar {
      position: sticky;
      top: 0;
      width: 17rem;
      height: 100vh;
      transform: none;
      box-shadow: none;
    }
  }
</style>
