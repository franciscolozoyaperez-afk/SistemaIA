<script>
  let { name = 'dashboard', size = 20 } = $props();

  const icons = {
    dashboard: 'M3 3h7v7H3zM14 3h7v7h-7zM3 14h7v7H3zM14 14h7v7h-7z',
    students: 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm-8 8a8 8 0 0 1 16 0H4Z',
    access: 'M12 3 4 7v5c0 5 3.4 8.5 8 10 4.6-1.5 8-5 8-10V7l-8-4Zm-3 9 2 2 4-4',
    incidents: 'M12 3 2 20h20L12 3Zm0 6v5m0 3h.01',
    guardians: 'M16 11a4 4 0 1 0-8 0 4 4 0 0 0 8 0Zm-12 9a8 8 0 0 1 16 0H4Z',
    notifications: 'M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9ZM10 21h4',
    reports: 'M4 20V10m6 10V4m6 16v-7m4 7H2',
    users: 'M8 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6Zm8 0a3 3 0 1 0 0-6 3 3 0 0 0 0 6ZM2 20a6 6 0 0 1 12 0m4-6a6 6 0 0 1 4 6',
    logout: 'M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4m7 14 5-5-5-5m5 5H9'
  };

  const path = $derived(icons[name] || icons.dashboard);
</script>

<svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
  <path d={path} />
</svg>
