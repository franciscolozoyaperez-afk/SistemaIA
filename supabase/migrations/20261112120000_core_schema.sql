-- SIGSE-CETIS 61 - Esquema definitivo de entidades operativas
-- Cubre: students, guardians, student_guardians, access_events,
--        incidents, incident_updates, notifications,
--        notification_deliveries, audit_logs
--
-- Requiere la migración 20261112000000_initial_profiles.sql aplicada.

-- ============================================================================
-- students
-- ============================================================================

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  control_number text not null unique
    check (control_number ~ '^[0-9A-Za-z-]{4,20}$'),
  first_name text not null check (char_length(first_name) between 1 and 80),
  last_name text not null check (char_length(last_name) between 1 and 120),
  middle_name text check (middle_name is null or char_length(middle_name) <= 80),
  birth_date date,
  gender text check (gender in ('female', 'male', 'other', 'undisclosed')),
  program text check (program is null or char_length(program) <= 120),
  semester smallint check (semester is null or semester between 1 and 12),
  status text not null default 'active'
    check (status in ('active', 'inactive', 'graduated', 'dropped')),
  photo_url text,
  auth_user_id uuid unique references auth.users (id) on delete set null,
  notes text,
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists students_status_idx on public.students (status);
create index if not exists students_program_idx on public.students (program);
create index if not exists students_last_name_idx on public.students (last_name);
create index if not exists students_auth_user_idx on public.students (auth_user_id);

-- ============================================================================
-- guardians (padres/tutores; el acceso al sistema es opcional via profile_id)
-- ============================================================================

create table if not exists public.guardians (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid unique references public.profiles (id) on delete set null,
  full_name text not null check (char_length(full_name) between 2 and 160),
  relationship text not null
    check (relationship in ('father', 'mother', 'guardian', 'other')),
  phone text check (phone is null or phone ~ '^[+0-9 ()-]{7,20}$'),
  email text check (email is null or email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  address text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists guardians_profile_idx on public.guardians (profile_id);
create index if not exists guardians_email_idx on public.guardians (email);

-- ============================================================================
-- student_guardians (relación muchos a muchos)
-- ============================================================================

create table if not exists public.student_guardians (
  student_id uuid not null references public.students (id) on delete cascade,
  guardian_id uuid not null references public.guardians (id) on delete cascade,
  relationship text check (relationship is null or char_length(relationship) <= 60),
  is_primary boolean not null default false,
  can_pickup boolean not null default false,
  created_at timestamptz not null default now(),
  primary key (student_id, guardian_id)
);

create unique index if not exists student_guardians_one_primary
  on public.student_guardians (student_id)
  where is_primary;

create index if not exists student_guardians_guardian_idx
  on public.student_guardians (guardian_id);

-- ============================================================================
-- access_events (historial inmutable de entradas/salidas)
-- ============================================================================

create table if not exists public.access_events (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students (id) on delete restrict,
  event_type text not null check (event_type in ('in', 'out')),
  occurred_at timestamptz not null default now(),
  method text not null default 'manual'
    check (method in ('manual', 'qr', 'rfid', 'self')),
  registered_by uuid references public.profiles (id) on delete set null,
  notes text,
  created_at timestamptz not null default now()
);

create index if not exists access_events_student_time_idx
  on public.access_events (student_id, occurred_at desc);
create index if not exists access_events_occurred_idx
  on public.access_events (occurred_at desc);

-- ============================================================================
-- incidents y su historial
-- ============================================================================

create table if not exists public.incidents (
  id uuid primary key default gen_random_uuid(),
  student_id uuid references public.students (id) on delete set null,
  incident_type text not null check (char_length(incident_type) between 2 and 60),
  severity text not null default 'medium'
    check (severity in ('low', 'medium', 'high', 'critical')),
  status text not null default 'open'
    check (status in ('open', 'in_progress', 'resolved', 'closed')),
  title text not null check (char_length(title) between 3 and 200),
  description text,
  occurred_at timestamptz not null default now(),
  reported_by uuid references public.profiles (id) on delete set null,
  resolved_at timestamptz,
  resolved_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists incidents_student_idx on public.incidents (student_id);
create index if not exists incidents_status_idx on public.incidents (status);
create index if not exists incidents_severity_idx on public.incidents (severity);
create index if not exists incidents_occurred_idx on public.incidents (occurred_at desc);

create table if not exists public.incident_updates (
  id uuid primary key default gen_random_uuid(),
  incident_id uuid not null references public.incidents (id) on delete cascade,
  author_id uuid references public.profiles (id) on delete set null,
  action text check (action is null or char_length(action) <= 60),
  comment text not null check (char_length(comment) between 1 and 2000),
  created_at timestamptz not null default now()
);

create index if not exists incident_updates_incident_idx
  on public.incident_updates (incident_id, created_at);

-- ============================================================================
-- notifications y entregas
-- ============================================================================

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 3 and 200),
  body text not null check (char_length(body) between 1 and 5000),
  channel text not null default 'in_app'
    check (channel in ('in_app', 'email', 'sms')),
  audience text not null default 'all'
    check (audience in ('all', 'staff', 'teachers', 'guardians', 'students')),
  status text not null default 'draft'
    check (status in ('draft', 'scheduled', 'sent', 'cancelled')),
  scheduled_for timestamptz,
  sent_at timestamptz,
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists notifications_status_idx on public.notifications (status);
create index if not exists notifications_scheduled_idx
  on public.notifications (scheduled_for)
  where status = 'scheduled';

create table if not exists public.notification_deliveries (
  notification_id uuid not null references public.notifications (id) on delete cascade,
  recipient_type text not null check (recipient_type in ('profile', 'guardian', 'student')),
  recipient_id uuid not null,
  status text not null default 'pending'
    check (status in ('pending', 'sent', 'failed', 'read')),
  attempt_count smallint not null default 0,
  last_attempt_at timestamptz,
  error_message text,
  created_at timestamptz not null default now(),
  primary key (notification_id, recipient_type, recipient_id)
);

create index if not exists notification_deliveries_recipient_idx
  on public.notification_deliveries (recipient_type, recipient_id, status);

-- ============================================================================
-- audit_logs (solo inserción; sin update/delete por política)
-- ============================================================================

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.profiles (id) on delete set null,
  action text not null check (char_length(action) between 2 and 100),
  entity_type text not null check (char_length(entity_type) between 2 and 60),
  entity_id uuid,
  metadata jsonb,
  ip_address inet,
  created_at timestamptz not null default now()
);

create index if not exists audit_logs_entity_idx
  on public.audit_logs (entity_type, entity_id, created_at desc);
create index if not exists audit_logs_actor_idx
  on public.audit_logs (actor_id, created_at desc);

-- ============================================================================
-- updated_at triggers (reutiliza public.set_updated_at de la migración inicial)
-- ============================================================================

do $$
declare
  t text;
begin
  foreach t in array array[
    'students', 'guardians', 'incidents', 'notifications'
  ]
  loop
    execute format('drop trigger if exists %I_set_updated_at on public.%I', t, t);
    execute format(
      'create trigger %I_set_updated_at before update on public.%I
       for each row execute function public.set_updated_at()',
      t, t
    );
  end loop;
end $$;

-- ============================================================================
-- Row Level Security
-- ============================================================================

alter table public.students enable row level security;
alter table public.guardians enable row level security;
alter table public.student_guardians enable row level security;
alter table public.access_events enable row level security;
alter table public.incidents enable row level security;
alter table public.incident_updates enable row level security;
alter table public.notifications enable row level security;
alter table public.notification_deliveries enable row level security;
alter table public.audit_logs enable row level security;

-- Estudiantes: staff/admin gestionan; el propio estudiante (vía auth_user_id)
-- y sus tutores (vía student_guardians -> guardians.profile_id) solo leen.

create policy students_select
  on public.students for select to authenticated
  using (
    public.has_role(array['admin', 'staff']::text[])
    or auth_user_id = auth.uid()
    or exists (
      select 1
      from public.student_guardians sg
      join public.guardians g on g.id = sg.guardian_id
      where sg.student_id = students.id
        and g.profile_id = auth.uid()
        and g.is_active
    )
  );

create policy students_insert
  on public.students for insert to authenticated
  with check (public.has_role(array['admin', 'staff']::text[]));

create policy students_update
  on public.students for update to authenticated
  using (public.has_role(array['admin', 'staff']::text[]))
  with check (public.has_role(array['admin', 'staff']::text[]));

create policy students_delete
  on public.students for delete to authenticated
  using (public.has_role(array['admin']::text[]));

-- Tutores: staff/admin gestionan; el tutor lee su propio registro.

create policy guardians_select
  on public.guardians for select to authenticated
  using (
    public.has_role(array['admin', 'staff']::text[])
    or profile_id = auth.uid()
  );

create policy guardians_insert
  on public.guardians for insert to authenticated
  with check (public.has_role(array['admin', 'staff']::text[]));

create policy guardians_update
  on public.guardians for update to authenticated
  using (public.has_role(array['admin', 'staff']::text[]))
  with check (public.has_role(array['admin', 'staff']::text[]));

create policy guardians_delete
  on public.guardians for delete to authenticated
  using (public.has_role(array['admin']::text[]));

-- student_guardians: hereda visibilidad del estudiante y del tutor.

create policy student_guardians_select
  on public.student_guardians for select to authenticated
  using (
    public.has_role(array['admin', 'staff']::text[])
    or exists (
      select 1 from public.students s
      where s.id = student_id and s.auth_user_id = auth.uid()
    )
    or exists (
      select 1 from public.guardians g
      where g.id = guardian_id and g.profile_id = auth.uid()
    )
  );

create policy student_guardians_insert
  on public.student_guardians for insert to authenticated
  with check (public.has_role(array['admin', 'staff']::text[]));

create policy student_guardians_update
  on public.student_guardians for update to authenticated
  using (public.has_role(array['admin', 'staff']::text[]))
  with check (public.has_role(array['admin', 'staff']::text[]));

create policy student_guardians_delete
  on public.student_guardians for delete to authenticated
  using (public.has_role(array['admin']::text[]));

-- Accesos: staff/admin registran y consultan todo; estudiante y tutor
-- solo consultan los eventos de sus estudiantes. Sin update/delete
-- (historial inmutable).

create policy access_events_select
  on public.access_events for select to authenticated
  using (
    public.has_role(array['admin', 'staff']::text[])
    or exists (
      select 1 from public.students s
      where s.id = student_id and s.auth_user_id = auth.uid()
    )
    or exists (
      select 1
      from public.student_guardians sg
      join public.guardians g on g.id = sg.guardian_id
      where sg.student_id = access_events.student_id
        and g.profile_id = auth.uid()
        and g.is_active
    )
  );

create policy access_events_insert
  on public.access_events for insert to authenticated
  with check (
    public.has_role(array['admin', 'staff']::text[])
    and registered_by = auth.uid()
  );

-- Incidencias: staff/admin gestionan; docente reporta y da seguimiento;
-- estudiante/tutor solo leen las que les corresponden.

create policy incidents_select
  on public.incidents for select to authenticated
  using (
    public.has_role(array['admin', 'staff', 'teacher']::text[])
    or exists (
      select 1 from public.students s
      where s.id = student_id and s.auth_user_id = auth.uid()
    )
    or exists (
      select 1
      from public.student_guardians sg
      join public.guardians g on g.id = sg.guardian_id
      where sg.student_id = incidents.student_id
        and g.profile_id = auth.uid()
        and g.is_active
    )
  );

create policy incidents_insert
  on public.incidents for insert to authenticated
  with check (
    public.has_role(array['admin', 'staff', 'teacher']::text[])
    and reported_by = auth.uid()
  );

create policy incidents_update
  on public.incidents for update to authenticated
  using (public.has_role(array['admin', 'staff', 'teacher']::text[]))
  with check (public.has_role(array['admin', 'staff', 'teacher']::text[]));

create policy incidents_delete
  on public.incidents for delete to authenticated
  using (public.has_role(array['admin']::text[]));

create policy incident_updates_select
  on public.incident_updates for select to authenticated
  using (
    public.has_role(array['admin', 'staff', 'teacher']::text[])
    or exists (
      select 1
      from public.incidents i
      join public.students s on s.id = i.student_id
      where i.id = incident_updates.incident_id
        and s.auth_user_id = auth.uid()
    )
    or exists (
      select 1
      from public.incidents i
      join public.student_guardians sg on sg.student_id = i.student_id
      join public.guardians g on g.id = sg.guardian_id
      where i.id = incident_updates.incident_id
        and g.profile_id = auth.uid()
        and g.is_active
    )
  );

create policy incident_updates_insert
  on public.incident_updates for insert to authenticated
  with check (
    author_id = auth.uid()
    and exists (
      select 1 from public.incidents i
      where i.id = incident_id
        and public.has_role(array['admin', 'staff', 'teacher']::text[])
    )
  );

-- Notificaciones: staff/admin crean y gestionan; cada usuario lee las
-- entregas dirigidas a él (profile_id propio, o tutor/estudiante vinculado).

create policy notifications_select_staff
  on public.notifications for select to authenticated
  using (public.has_role(array['admin', 'staff']::text[]));

create policy notifications_insert
  on public.notifications for insert to authenticated
  with check (
    public.has_role(array['admin', 'staff']::text[])
    and created_by = auth.uid()
  );

create policy notifications_update
  on public.notifications for update to authenticated
  using (public.has_role(array['admin', 'staff']::text[]))
  with check (public.has_role(array['admin', 'staff']::text[]));

create policy notifications_delete
  on public.notifications for delete to authenticated
  using (public.has_role(array['admin']::text[]));

create policy notification_deliveries_select
  on public.notification_deliveries for select to authenticated
  using (
    public.has_role(array['admin', 'staff']::text[])
    or (recipient_type = 'profile' and recipient_id = auth.uid())
    or (recipient_type = 'guardian' and exists (
      select 1 from public.guardians g
      where g.id = recipient_id and g.profile_id = auth.uid()
    ))
    or (recipient_type = 'student' and exists (
      select 1 from public.students s
      where s.id = recipient_id and s.auth_user_id = auth.uid()
    ))
  );

create policy notification_deliveries_update_own
  on public.notification_deliveries for update to authenticated
  using (
    (recipient_type = 'profile' and recipient_id = auth.uid())
    or (recipient_type = 'guardian' and exists (
      select 1 from public.guardians g
      where g.id = recipient_id and g.profile_id = auth.uid()
    ))
    or (recipient_type = 'student' and exists (
      select 1 from public.students s
      where s.id = recipient_id and s.auth_user_id = auth.uid()
    ))
  )
  with check (
    (recipient_type = 'profile' and recipient_id = auth.uid())
    or (recipient_type = 'guardian' and exists (
      select 1 from public.guardians g
      where g.id = recipient_id and g.profile_id = auth.uid()
    ))
    or (recipient_type = 'student' and exists (
      select 1 from public.students s
      where s.id = recipient_id and s.auth_user_id = auth.uid()
    ))
  );

-- audit_logs: staff/admin solo lectura; inserción permitida a cualquier
-- autenticado (la app registra la acción del propio usuario).

create policy audit_logs_select
  on public.audit_logs for select to authenticated
  using (public.has_role(array['admin', 'staff']::text[]));

create policy audit_logs_insert
  on public.audit_logs for insert to authenticated
  with check (actor_id = auth.uid());

-- ============================================================================
-- Grants (RLS sigue filtrando filas)
-- ============================================================================

grant select, insert, update, delete on public.students to authenticated;
grant select, insert, update, delete on public.guardians to authenticated;
grant select, insert, update, delete on public.student_guardians to authenticated;
grant select, insert on public.access_events to authenticated;
grant select, insert, update, delete on public.incidents to authenticated;
grant select, insert on public.incident_updates to authenticated;
grant select, insert, update, delete on public.notifications to authenticated;
grant select, update on public.notification_deliveries to authenticated;
grant select, insert on public.audit_logs to authenticated;
