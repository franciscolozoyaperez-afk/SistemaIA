# SIGSE-CETIS 61

Sistema Integral de Gestión y Seguimiento Estudiantil para el Centro de Estudios Tecnológicos Industrial y de Servicios No. 61.

## Estado del proyecto

Esta primera etapa construye la estructura base del sistema:

- Monorepo con npm workspaces.
- Frontend SvelteKit/Svelte 5.
- Backend Node.js/Express compatible con Vercel Functions.
- Supabase Auth y cliente admin solo en backend.
- Migración inicial de `profiles` con RLS.
- Dashboard preliminar con navegación para todos los módulos.
- Documentación de arquitectura, API, base de datos y Vercel.

No incluye todavía CRUD funcional de estudiantes, accesos, incidencias, tutores, notificaciones ni reportes.

## Requisitos

- Node.js 20.19 o superior.
- npm 10 o superior.
- Proyecto Supabase para autenticación y base de datos.

## Instalación

```bash
npm install
```

## Variables de entorno

Crea archivos locales a partir de los ejemplos:

```bash
cp apps/frontend/.env.example apps/frontend/.env.local
cp apps/backend/.env.example apps/backend/.env
```

Edita los valores con las credenciales de tu proyecto Supabase. No subas archivos `.env` al repositorio.

Variables públicas del frontend:

- `PUBLIC_SUPABASE_URL`
- `PUBLIC_SUPABASE_ANON_KEY`
- `PUBLIC_API_BASE_URL`
- `VITE_API_PROXY_TARGET` solo para desarrollo

Variables privadas del backend:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `API_CORS_ORIGINS`
- `PORT`
- `RATE_LIMIT_WINDOW_MS`
- `RATE_LIMIT_MAX`

## Ejecución local

Desde la raíz del monorepo:

```bash
npm run dev:backend
```

En otra terminal:

```bash
npm run dev:frontend
```

O ejecutar ambos procesos desde la raíz:

```bash
npm run dev
```

URLs locales:

- Frontend: `http://localhost:5173`
- Backend: `http://localhost:3001`
- Health check: `http://localhost:3001/api/health`

El frontend usa el proxy de Vite para enviar `/api/*` al backend local.

## Compilación

```bash
npm run build
```

El build del frontend genera la salida configurada por `@sveltejs/adapter-vercel`.

## Base de datos

La migración inicial está en:

```text
supabase/migrations/20261112000000_initial_profiles.sql
```

Documentación del esquema:

```text
docs/database-schema.md
```

## Estructura

```text
SIGSE-CETIS61/
├── apps/
│   ├── frontend/       # SvelteKit, interfaz web
│   └── backend/        # API Node.js/Express
├── packages/
│   └── shared/         # Constantes compartidas
├── supabase/
│   ├── migrations/     # Migraciones PostgreSQL
│   └── seed/           # Datos iniciales no sensibles
├── docs/               # Documentación técnica
├── .env.example        # Referencia general de variables
├── .gitignore
├── package.json
└── README.md
```

## Despliegue

Consulta `docs/vercel.md` para crear los proyectos frontend/backend en Vercel, configurar variables de entorno y verificar el despliegue.

Documentación adicional:

- `docs/architecture.md`: decisiones técnicas y flujo de datos.
- `docs/api.md`: endpoints disponibles y convenciones.
- `docs/database-schema.md`: esquema inicial y tablas propuestas.
- `docs/troubleshooting.md`: problemas comunes de instalación y ejecución.

## Próximos pasos

1. Aplicar la migración de Supabase.
2. Crear el primer usuario administrador.
3. Validar login y protección de rutas.
4. Definir el modelo definitivo de estudiantes, tutores, accesos e incidencias.
5. Implementar autenticación/autorización en endpoints privados del backend.
6. Desarrollar los CRUD por módulo.
