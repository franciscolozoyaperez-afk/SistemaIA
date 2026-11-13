<script>
  import Badge from '../components/Badge.svelte';
  import Icon from '../components/Icon.svelte';

  let { title, description, icon = 'dashboard' } = $props();
</script>

<svelte:head>
  <title>{title} | SIGSE-CETIS 61</title>
</svelte:head>

<section class="module-page">
  <div class="module-header">
    <span class="module-icon"><Icon name={icon} size={26} /></span>
    <div>
      <Badge tone="primary">Vista preliminar</Badge>
      <h1>{title}</h1>
      <p>{description}</p>
    </div>
  </div>

  <div class="placeholder-panel">
    <h2>Contenido pendiente</h2>
    <p>Este módulo ya forma parte de la navegación del sistema, pero sus operaciones CRUD se desarrollarán en una etapa posterior.</p>
    <ul>
      <li>Validaciones de formularios</li>
      <li>Políticas RLS de Supabase</li>
      <li>Integración con el API de Node.js</li>
      <li>Pruebas de permisos por rol</li>
    </ul>
  </div>
</section>

<style>
  .module-page {
    display: grid;
    gap: 1.25rem;
  }

  .module-header {
    display: flex;
    align-items: flex-start;
    gap: 1rem;
    padding: 1.5rem;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-lg);
    background: var(--color-surface);
    box-shadow: var(--shadow-sm);
  }

  .module-icon {
    display: inline-grid;
    place-items: center;
    flex: 0 0 auto;
    width: 3.5rem;
    height: 3.5rem;
    border-radius: var(--radius-md);
    color: var(--color-primary-dark);
    background: var(--color-primary-soft);
  }

  h1,
  h2,
  p,
  ul {
    margin: 0;
  }

  h1 {
    margin-top: 0.55rem;
    font-size: 1.7rem;
  }

  h2 {
    font-size: 1.15rem;
  }

  .module-header p,
  .placeholder-panel p {
    margin-top: 0.4rem;
    color: var(--color-muted);
  }

  .placeholder-panel {
    padding: 1.5rem;
    border: 1px dashed #cbd5e1;
    border-radius: var(--radius-lg);
    background: #fff;
  }

  ul {
    display: grid;
    gap: 0.45rem;
    margin-top: 1rem;
    padding-left: 1.25rem;
    color: var(--color-text);
  }
</style>
