<script>
  let { label, value, helper = '', tone = 'primary' } = $props();
</script>

<article class="stat-card tone-{tone}">
  <span class="stat-label">{label}</span>
  <strong class="stat-value">{value}</strong>
  <span class="stat-helper">{helper}</span>
</article>

<style>
  .stat-card {
    display: grid;
    gap: 0.4rem;
    min-height: 8.5rem;
    padding: 1.25rem;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-lg);
    background: var(--color-surface);
    box-shadow: var(--shadow-sm);
  }

  .stat-label {
    color: var(--color-muted);
    font-size: 0.875rem;
    font-weight: 600;
  }

  .stat-value {
    color: var(--color-text);
    font-size: 2rem;
    line-height: 1;
  }

  .stat-helper {
    color: var(--color-muted);
    font-size: 0.8rem;
  }

  .tone-primary {
    border-top: 4px solid var(--color-primary);
  }

  .tone-success {
    border-top: 4px solid var(--color-success);
  }

  .tone-warning {
    border-top: 4px solid var(--color-warning);
  }

  .tone-neutral {
    border-top: 4px solid #64748b;
  }
</style>
