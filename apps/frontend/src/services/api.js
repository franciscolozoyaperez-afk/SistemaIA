const baseUrl = (import.meta.env.PUBLIC_API_BASE_URL || '/api').replace(/\/$/, '');

async function request(path, options = {}) {
  const response = await fetch(`${baseUrl}${path}`, {
    headers: {
      Accept: 'application/json',
      ...(options.body ? { 'Content-Type': 'application/json' } : {}),
      ...options.headers
    },
    ...options
  });

  const contentType = response.headers.get('content-type') || '';
  const payload = contentType.includes('application/json') ? await response.json() : await response.text();

  if (!response.ok) {
    const message = payload?.error?.message || payload?.message || `Error HTTP ${response.status}`;
    throw new Error(message);
  }

  return payload;
}

export function getHealth() {
  return request('/health');
}

export function getStatus() {
  return request('/v1/status');
}
