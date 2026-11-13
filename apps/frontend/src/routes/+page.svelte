<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { get } from 'svelte/store';
  import { initAuth, user } from '../stores/auth';

  onMount(async () => {
    await initAuth();
    await goto(get(user) ? '/dashboard' : '/login', { replaceState: true });
  });
</script>

<p class="loading" role="status">Cargando SIGSE-CETIS 61...</p>

<style>
  .loading {
    display: grid;
    min-height: 100vh;
    place-items: center;
    color: var(--color-muted);
    font-weight: 600;
  }
</style>
