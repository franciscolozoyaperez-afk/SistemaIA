# Despliegue en Vercel

El monorepo se publica como dos proyectos independientes en Vercel.

> Importante: al configurar cada proyecto, establece **Root Directory** en `apps/frontend` o `apps/backend` y mantén habilitada la opción **Include source files outside of the Root Directory in the Build Step**. No sobrescribas el Install Command: Vercel debe detectar `package-lock.json` desde la raíz del repositorio para instalar los workspaces correctamente.

## Proyecto frontend

- Root directory: `apps/frontend`
- Framework: `SvelteKit`
- Build command: `npm run build`
- Install command: automático; no sobrescribir para que Vercel use el lockfile de la raíz
- Adapter: `@sveltejs/adapter-vercel`

Variables de entorno recomendadas:

| Variable | Valor |
| --- | --- |
| `PUBLIC_SUPABASE_URL` | URL del proyecto Supabase |
| `PUBLIC_SUPABASE_ANON_KEY` | Anon key de Supabase |
| `PUBLIC_API_BASE_URL` | `https://<backend>.vercel.app/api` o `/api` si se usa proxy/rewrite |

## Proyecto backend

- Root directory: `apps/backend`
- Runtime: Node.js serverless functions
- Archivos de función: `api/index.js` y `api/[...path].js`
- `src/index.js` exporta la app Express y no abre puerto cuando `VERCEL` está definido.

Variables de entorno recomendadas:

| Variable | Valor |
| --- | --- |
| `SUPABASE_URL` | URL del proyecto Supabase |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key, solo en Vercel/backend |
| `API_CORS_ORIGINS` | Dominio del frontend, por ejemplo `https://sigse-cetis61.vercel.app` |
| `RATE_LIMIT_WINDOW_MS` | `60000` |
| `RATE_LIMIT_MAX` | `120` o el valor acordado |

## Supabase

1. Crear el proyecto Supabase.
2. Aplicar `supabase/migrations/20261112000000_initial_profiles.sql`.
3. Crear usuarios en Authentication > Users.
4. Confirmar que el trigger crea registros en `profiles`.
5. Cambiar el rol del primer administrador a `admin` mediante una operación controlada.

## Verificación posterior al despliegue

1. Abrir el frontend y comprobar que redirige a `/login`.
2. Iniciar sesión con un usuario real de Supabase Auth.
3. Comprobar `/dashboard`.
4. Llamar `<backend>/api/health` o configurar `/api` en el frontend.
5. Confirmar que `SUPABASE_SERVICE_ROLE_KEY` no aparece en archivos versionados ni en el bundle del frontend.
