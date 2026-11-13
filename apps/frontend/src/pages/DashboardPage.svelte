<script>
  import { onMount } from 'svelte';
  import { DEMO_DATA_NOTICE, MODULES } from '@sigse/shared';
  import Badge from '../components/Badge.svelte';
  import ModuleCard from '../components/ModuleCard.svelte';
  import StatCard from '../components/StatCard.svelte';
  import { demoStats } from '../services/demoData';
  import { getHealth } from '../services/api';

  let apiStatus = $state('checking');
  let apiMessage = $state('Comprobando conexión con el API...');

  onMount(async () => {
    try {
      const health = await getHealth();
      apiStatus = health.status === 'ok' ? 'online' : 'warning';
      apiMessage = health.status === 'ok'
        ? 'API Node.js disponible'
        : 'API disponible con observaciones';
    } catch (error) {
      apiStatus = 'offline';
      apiMessage = error.message || 'No fue posible conectar con el API.';
    }
  });
</script>

<svelte:head>
  <title>Panel principal | SIGSE-CETIS 61</title>
</svelte:head>

<section class="dashboard-intro">
  <div>
    <Badge tone="primary">Etapa inicial</Badge>
    <h1>Panel principal</h1>
    <p>{DEMO_DATA_NOTICE}</p>
  </div>
  <div class="api-status" class:online={apiStatus === 'online'} class:offline={apiStatus === 'offline'}>
    <strong>{apiStatus === 'online' ? 'API en línea' : apiStatus === 'offline' ? 'API no disponible' : 'Verificando API'}</strong>
    <span>{apiMessage}</span>
  </div>
</section>

<section class="stats-grid" aria-label="Indicadores">
  {#each demoStats as stat}
    <StatCard label={stat.label} value={stat.value} helper={stat.helper} tone={stat.tone} />
  {/each}
</section>

<section class="module-section">
  <div class="section-heading">
    <div>
      <h2>Módulos del sistema</h2>
      <p>La navegación ya está disponible; las vistas operativas se implementarán por etapas.</p>
    </div>
  </div>

  <div class="module-grid">
    {#each MODULES.filter((item) => item.id !== 'dashboard') as item}
      <ModuleCard module={item} />
    {/each}
  </div>
</section>

<style>
  .dashboard-intro {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 1rem;
    margin-bottom: 1.5rem;
  }

  h1,
  h2,
  p {
    margin: 0;
  }

  h1 {
    margin-top: 0.65rem;
    font-size: 1.8rem;
  }

  h2 {
    font-size: 1.25rem;
  }

  .dashboard-intro p,
  .section-heading p {
    margin-top: 0.4rem;
    color: var(--color-muted);
  }

  .api-status {
    display: grid;
    gap: 0.2rem;
    min-width: 15rem;
    padding: 0.9rem 1rem;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-md);
    background: var(--color-surface);
    text-align: right;
  }

  .api-status strong {
    font-size: 0.9rem;
  }

  .api-status span {
    color: var(--color-muted);
    font-size: 0.8rem;
  }

  .api-status.online strong {
    color: var(--color-success);
  }

  .api-status.offline strong {
    color: var(--color-danger);
  }

  .stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(13rem, 1fr));
    gap: 1rem;
    margin-bottom: 2rem;
  }

  .module-section {
    display: grid;
    gap: 1rem;
  }

  .module-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(18rem, 1fr));
    gap: 1rem;
  }

  @media (max-width: 720px) {
    .dashboard-intro {
      flex-direction: column;
    }

    .api-status {
      width: 100%;
      text-align: left;
    }
  }
</style>
