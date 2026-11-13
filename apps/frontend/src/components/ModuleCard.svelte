<script>
  import Icon from './Icon.svelte';

  let { module } = $props();
</script>

<a class="module-card" href={module.path}>
  <span class="module-icon"><Icon name={module.icon} size={22} /></span>
  <span class="module-copy">
    <strong>{module.label}</strong>
    <span>{module.description}</span>
  </span>
  <span class="module-status">Vista preliminar</span>
</a>

<style>
  .module-card {
    position: relative;
    display: grid;
    grid-template-columns: auto 1fr;
    gap: 1rem;
    min-height: 7rem;
    padding: 1.25rem;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-lg);
    background: var(--color-surface);
    box-shadow: var(--shadow-sm);
    transition: border-color 160ms ease, box-shadow 160ms ease, transform 160ms ease;
  }

  .module-card:hover {
    border-color: var(--color-primary);
    box-shadow: var(--shadow-md);
    transform: translateY(-1px);
  }

  .module-icon {
    display: inline-grid;
    place-items: center;
    width: 2.75rem;
    height: 2.75rem;
    border-radius: var(--radius-md);
    color: var(--color-primary-dark);
    background: var(--color-primary-soft);
  }

  .module-copy {
    display: grid;
    gap: 0.25rem;
    align-content: start;
  }

  .module-copy strong {
    font-size: 1rem;
  }

  .module-copy span {
    color: var(--color-muted);
    font-size: 0.875rem;
  }

  .module-status {
    grid-column: 2;
    width: fit-content;
    padding: 0.2rem 0.55rem;
    border-radius: 999px;
    color: var(--color-primary-dark);
    background: var(--color-primary-soft);
    font-size: 0.75rem;
    font-weight: 700;
  }
</style>
