# Esquema de base de datos - SIGSE-CETIS 61

## Estado actual

- `20261112000000_initial_profiles.sql`: implementada. Crea `public.profiles`, `has_role()`, trigger `on_auth_user_created` y RLS inicial.
- `20261112120000_core_schema.sql`: diseño definitivo de las entidades operativas. Cubre estudiantes, tutores, accesos, incidencias, notificaciones y auditoría. Pendiente de aplicar en Supabase.

## Tabla implementada: `public.profiles`

| Columna | Tipo | Reglas |
| --- | --- | --- |
| `id` | `uuid` | PK, referencia `auth.users(id)`, borrado en cascada |
| `email` | `text` | Correo institucional, único y no nulo |
| `full_name` | `text` | Nombre completo, no nulo |
| `role` | `text` | `admin`, `staff`, `teacher`, `guardian` o `student`; valor inicial seguro `guardian` |
| `is_active` | `boolean` | Permite suspender accesos sin borrar la cuenta |
| `created_at` | `timestamptz` | Valor automático |
| `updated_at` | `timestamptz` | Valor automático y actualizado por trigger |

### Seguridad

- RLS habilitado.
- Un usuario autenticado puede consultar su propio perfil.
- Los roles `admin` y `staff` pueden consultar perfiles.
- Solo `admin` puede actualizar perfiles.
- El alta del perfil se hace mediante trigger desde `auth.users`; el cliente no puede insertar perfiles directamente.
- El trigger no confía en `raw_user_meta_data.role` para evitar autoasignación de privilegios.

## Esquema definitivo: `20261112120000_core_schema.sql`

### `public.students`

Datos académicos y administrativos del estudiante. No duplica credenciales: `auth_user_id` es opcional y liga con `auth.users` cuando el estudiante tenga cuenta propia.

Campos: `id`, `control_number` (único, formato `^[0-9A-Za-z-]{4,20}$`), `first_name`, `last_name`, `middle_name`, `birth_date`, `gender` (`female|male|other|undisclosed`), `program`, `semester` (1-12), `status` (`active|inactive|graduated|dropped`), `photo_url`, `auth_user_id`, `notes`, `created_by`, timestamps.

Índices: `status`, `program`, `last_name`, `auth_user_id`.

### `public.guardians`

Padres, madres o tutores. `profile_id` es opcional: un tutor solo tiene cuenta si se vincula a `profiles`.

Campos: `id`, `profile_id` (único, nullable), `full_name`, `relationship` (`father|mother|guardian|other`), `phone`, `email`, `address`, `is_active`, timestamps.

### `public.student_guardians`

Relación muchos a muchos. PK compuesta `(student_id, guardian_id)`.

Campos: `relationship`, `is_primary` (índice único parcial: un solo primario por estudiante), `can_pickup`, `created_at`.

### `public.access_events`

Historial inmutable de entradas/salidas. Sin políticas `update`/`delete`: los eventos no se corrigen, se registran nuevos.

Campos: `id`, `student_id` (`on delete restrict`, nunca se borra un estudiante con historial), `event_type` (`in|out`), `occurred_at`, `method` (`manual|qr|rfid|self`), `registered_by`, `notes`, `created_at`.

Índices: `(student_id, occurred_at desc)`, `(occurred_at desc)`.

### `public.incidents`

Campos: `id`, `student_id` (nullable, `set null`), `incident_type`, `severity` (`low|medium|high|critical`), `status` (`open|in_progress|resolved|closed`), `title`, `description`, `occurred_at`, `reported_by`, `resolved_at`, `resolved_by`, timestamps.

### `public.incident_updates`

Historial de acciones sobre una incidencia (solo `insert`, sin correcciones).

Campos: `id`, `incident_id` (`cascade`), `author_id`, `action`, `comment`, `created_at`.

### `public.notifications`

Campos: `id`, `title`, `body`, `channel` (`in_app|email|sms`), `audience` (`all|staff|teachers|guardians|students`), `status` (`draft|scheduled|sent|cancelled`), `scheduled_for`, `sent_at`, `created_by`, timestamps.

### `public.notification_deliveries`

Estado de entrega por destinatario. PK compuesta `(notification_id, recipient_type, recipient_id)`.

Campos: `recipient_type` (`profile|guardian|student`), `status` (`pending|sent|failed|read`), `attempt_count`, `last_attempt_at`, `error_message`, `created_at`.

### `public.audit_logs`

Trazabilidad. Solo `select` (admin/staff) e `insert` (cualquier autenticado registrando su propia acción con `actor_id = auth.uid()`). Sin `update` ni `delete`.

Campos: `id`, `actor_id`, `action`, `entity_type`, `entity_id`, `metadata` (jsonb), `ip_address` (inet), `created_at`.

## Políticas RLS por rol

| Tabla | admin/staff | teacher | student (propio) | guardian (vinculado) |
| --- | --- | --- | --- | --- |
| students | CRUD | — | select propio | select sus estudiantes |
| guardians | CRUD | — | — | select propio |
| student_guardians | CRUD | — | select vínculos propios | select vínculos propios |
| access_events | select+insert | — | select propios | select de sus estudiantes |
| incidents | CRUD | select+insert+update | select propias | select de sus estudiantes |
| incident_updates | select+insert | select+insert | select las de sus casos | select las de sus casos |
| notifications | CRUD | — | solo entregas propias | solo entregas propias |
| notification_deliveries | select | — | update estado propio | update estado propio |
| audit_logs | select | — | insert propio | insert propio |

Notas:
- `registered_by`, `reported_by`, `created_by`, `resolved_by` y `actor_id` se verifican contra `auth.uid()` en las políticas de inserción.
- `access_events` y `audit_logs` son inmutables por diseño (append-only).
- La visibilidad de tutores/estudiantes se resuelve vía `student_guardians → guardians.profile_id` y `students.auth_user_id`, siempre con `guardians.is_active = true`.

## Índices y decisiones

- Búsquedas frecuentes cubiertas: control_number (unique), last_name, status, program, student+fecha en accesos, estado/severidad en incidencias.
- `access_events.student_id` usa `on delete restrict` para preservar historial; el resto de FKs usan `set null` o `cascade` según corresponda.
- Datos sensibles (CURP, acta de nacimiento) no se incluyen en esta etapa; si se requieren, evaluar cifrado a nivel aplicación antes de agregarlos.

## Pendientes antes de exponer CRUD

1. Aplicar ambas migraciones en el proyecto Supabase.
2. Crear el primer usuario administrador y promover su `role` a `admin`.
3. Escribir pruebas de autorización (login real + verificación RLS por rol).
4. Definir retención de datos personales y consentimiento de tutores.
5. Implementar endpoint/worker para `notifications.scheduled_for` → `sent`.
