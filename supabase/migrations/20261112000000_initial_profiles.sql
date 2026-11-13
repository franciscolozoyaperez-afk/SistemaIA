-- SIGSE-CETIS 61 - Esquema inicial de perfiles y roles
-- Esta migración no crea tablas de estudiantes ni datos académicos.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null unique,
  full_name text not null check (char_length(full_name) between 2 and 160),
  role text not null default 'guardian'
    check (role in ('admin', 'staff', 'teacher', 'guardian', 'student')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists profiles_role_idx on public.profiles (role);
create index if not exists profiles_is_active_idx on public.profiles (is_active);

alter table public.profiles enable row level security;

create or replace function public.has_role(
  _allowed_roles text[]
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles profile
    where profile.id = auth.uid()
      and profile.is_active = true
      and profile.role = any (_allowed_roles)
  );
$$;

revoke all on function public.has_role(text[]) from public;
grant execute on function public.has_role(text[]) to authenticated;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''), split_part(new.email, '@', 1)),
    'guardian'
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

revoke all on function public.handle_new_user() from public;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create policy profiles_select_own_or_privileged
  on public.profiles
  for select
  to authenticated
  using (
    id = auth.uid()
    or public.has_role(array['admin', 'staff']::text[])
  );

create policy profiles_update_admin_only
  on public.profiles
  for update
  to authenticated
  using (public.has_role(array['admin']::text[]))
  with check (public.has_role(array['admin']::text[]));

grant select, update on public.profiles to authenticated;
