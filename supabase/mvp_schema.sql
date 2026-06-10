create extension if not exists pgcrypto;

create table if not exists public.student_groups (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  course int not null check (course between 1 and 4),
  specialty text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role text not null check (role in ('student', 'admin')),
  group_id uuid references public.student_groups(id) on delete set null,
  student_card text unique,
  created_at timestamptz not null default now()
);

create table if not exists public.schedule_lessons (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.student_groups(id) on delete cascade,
  weekday int not null check (weekday between 1 and 6),
  lesson_number int not null check (lesson_number > 0),
  start_time time not null,
  end_time time not null,
  subject text not null,
  teacher text not null,
  classroom text not null,
  created_at timestamptz not null default now(),
  unique (group_id, weekday, lesson_number)
);

create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  is_important boolean not null default false,
  target_group_id uuid references public.student_groups(id) on delete cascade,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'admin'
  );
$$;

alter table public.student_groups enable row level security;
alter table public.profiles enable row level security;
alter table public.schedule_lessons enable row level security;
alter table public.announcements enable row level security;

create policy "groups are visible to signed in users"
on public.student_groups for select
to authenticated
using (true);

create policy "admins manage groups"
on public.student_groups for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "users read own profile or admins read all"
on public.profiles for select
to authenticated
using (id = auth.uid() or public.is_admin());

create policy "admins manage profiles"
on public.profiles for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "students read their group schedule"
on public.schedule_lessons for select
to authenticated
using (
  public.is_admin()
  or exists (
    select 1
    from public.profiles
    where profiles.id = auth.uid()
      and profiles.group_id = schedule_lessons.group_id
  )
);

create policy "admins manage schedule"
on public.schedule_lessons for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "students read relevant announcements"
on public.announcements for select
to authenticated
using (
  public.is_admin()
  or target_group_id is null
  or exists (
    select 1
    from public.profiles
    where profiles.id = auth.uid()
      and profiles.group_id = announcements.target_group_id
  )
);

create policy "admins manage announcements"
on public.announcements for all
to authenticated
using (public.is_admin())
with check (public.is_admin());
