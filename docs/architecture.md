# Arquitectura inicial

## Monorepo

El proyecto usa npm workspaces:

- `apps/frontend`: SvelteKit (Svelte 5) configurado para Vercel.
- `apps/backend`: API Node.js con Express, preparada para ejecutarse localmente y como Vercel Functions.
- `packages/shared`: constantes compartidas de módulos, roles, endpoints y avisos de datos demo.
- `supabase/migrations`: cambios versionados de PostgreSQL/Supabase.
- `supabase/seed`: datos iniciales no sensibles.
- `docs`: decisiones técnicas y operación.

## Flujo actual

1. El usuario entra por `apps/frontend`.
2. SvelteKit carga la aplicación en cliente (`ssr = false` en la etapa inicial).
3. `src/stores/auth.js` usa `@supabase/supabase-js` con la anon key y Supabase Auth.
4. El dashboard consulta `/api/health` mediante el proxy de Vite en desarrollo.
5. En producción, `/api` puede apuntar al proyecto backend desplegado en Vercel.
6. El backend usa `SUPABASE_SERVICE_ROLE_KEY` solo en servidor para futuras operaciones privilegiadas.

## Seguridad

- La `service_role` nunca se expone al frontend.
- El frontend usa únicamente `PUBLIC_SUPABASE_URL` y `PUBLIC_SUPABASE_ANON_KEY`.
- Supabase Auth administra contraseñas; el sistema no las almacena.
- La migración inicial habilita RLS en `profiles`.
- El backend aplica Helmet, CORS por origen, JSON limitado y rate limiting.
- El backend es stateless: no guarda sesiones propias ni estado en memoria compartida obligatoria.

## Escalabilidad en Vercel

- Frontend y backend se despliegan como proyectos separados dentro del mismo monorepo.
- Vercel Functions ejecutan el backend sin estado y permite escalar horizontalmente.
- No se implementa balanceador manual en Node.js.
- Las conexiones a Supabase deben reutilizar clientes por instancia mediante los singletons de `config/supabase.js`.
- El rate limiter en memoria es apropiado para una primera etapa; si se requiere coordinación entre múltiples instancias, sustituirlo por un limitador distribuido antes de producción intensiva.

## Alcance de esta etapa

- Login con Supabase Auth.
- Protección básica de rutas del dashboard.
- Navegación lateral con todos los módulos.
- Dashboard con indicadores vacíos identificados como demostración.
- API de salud/estado.
- Esquema inicial de perfiles y roles.

No incluye CRUD funcional de estudiantes, accesos, incidencias, tutores, notificaciones ni reportes.
