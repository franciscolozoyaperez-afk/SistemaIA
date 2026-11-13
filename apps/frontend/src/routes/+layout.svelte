<script>
  import '../app.css';
  import { onMount } from 'svelte';
  import { initAuth } from '../stores/auth';

  let { children } = $props();

  onMount(() => {
    void initAuth();
  });
</script>

<svelte:head>
  <meta name="theme-color" content="#1d4ed8" />
</svelte:head>

{@render children()}
