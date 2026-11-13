<script>
  let { tone = 'neutral', children } = $props();
</script>

<span class="badge badge-{tone}">{@render children()}</span>

<style>
  .badge {
    display: inline-flex;
    align-items: center;
    width: fit-content;
    padding: 0.2rem 0.65rem;
    border-radius: 999px;
    font-size: 0.75rem;
    font-weight: 700;
    letter-spacing: 0.02em;
    text-transform: uppercase;
  }

  .badge-neutral {
    color: #475569;
    background: #e2e8f0;
  }

  .badge-primary {
    color: var(--color-primary-dark);
    background: var(--color-primary-soft);
  }

  .badge-success {
    color: var(--color-success);
    background: #dcfce7;
  }

  .badge-warning {
    color: var(--color-warning);
    background: #fef3c7;
  }

  .badge-danger {
    color: var(--color-danger);
    background: #fee2e2;
  }
</style>
