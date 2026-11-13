<script>
  import Sidebar from './Sidebar.svelte';
  import Topbar from './Topbar.svelte';

  let { children } = $props();
</script>

<div class="shell">
  <Sidebar />
  <div class="shell-main">
    <Topbar />
    <main class="content">
      {@render children()}
    </main>
  </div>
</div>

<style>
  .shell {
    min-height: 100vh;
    background: var(--color-background);
  }

  .shell-main {
    min-width: 0;
  }

  .content {
    width: min(100%, 90rem);
    margin: 0 auto;
    padding: 1.5rem;
  }

  @media (min-width: 1024px) {
    .shell {
      display: grid;
      grid-template-columns: 17rem minmax(0, 1fr);
    }

    .content {
      padding: 2rem;
    }
  }
</style>
