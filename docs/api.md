# API inicial

Base local: `http://localhost:3001`

El backend acepta rutas con o sin prefijo `/api` para facilitar tanto el desarrollo local como Vercel Functions.

## `GET /health` o `GET /api/health`

Responde el estado básico del servicio.

Respuesta exitosa:

```json
{
  "success": true,
  "data": {
    "status": "ok",
    "service": "sigse-cetis61-api",
    "timestamp": "2026-11-12T00:00:00.000Z"
  }
}
```

## `GET /v1/status` o `GET /api/v1/status`

Responde configuración general sin exponer secretos.

```json
{
  "success": true,
  "data": {
    "service": "sigse-cetis61-api",
    "status": "ok",
    "environment": "development",
    "supabase": {
      "configured": true,
      "mode": "server-only"
    },
    "timestamp": "2026-11-12T00:00:00.000Z"
  }
}
```

## Formato de error

```json
{
  "success": false,
  "error": {
    "message": "Mensaje understandable"
  }
}
```

## Convenciones para futuras rutas

- Usar `/api/v1/<recurso>` en producción.
- Validar entrada en backend antes de tocar Supabase.
- Verificar JWT de Supabase Auth en endpoints privados.
- Aplicar autorización por rol además de RLS.
- No devolver `service_role` ni secretos en respuestas.
