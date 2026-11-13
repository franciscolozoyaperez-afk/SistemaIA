<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import AppShell from '../components/AppShell.svelte';
  import { authLoading, initAuth, user } from '../stores/auth';

  let { children } = $props();

  onMount(async () => {
    await initAuth();

    if (!$user) {
      await goto('/login', { replaceState: true });
    }
  });
</script>

{#if $authLoading}
  <div class="loading" role="status">Verificando sesión...</div>
{:else if $user}
  <AppShell>{@render children()}</AppShell>
{/if}

<style>
  .loading {
    display: grid;
    min-height: 100vh;
    place-items: center;
    color: var(--color-muted);
    font-weight: 600;
  }
</style>
