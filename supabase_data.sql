-- State tables for physiology and lifestyle with permissive RLS (allow all). Replace with user-scoped policies in production.

create table if not exists public.physio_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  hr double precision default 0,
  hrv double precision default 0,
  rr double precision default 0,
  eda double precision default 0,
  temp double precision default 0,
  motion_score double precision default 0,
  is_exercising boolean default false,
  updated_at timestamptz default timezone('utc', now())
);

create table if not exists public.lifestyle_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  sleep_start timestamptz default timezone('utc', now()),
  wake_time timestamptz default timezone('utc', now()),
  sleep_debt_hours double precision default 0,
  caffeine_mg_after_2pm double precision default 0,
  nicotine boolean default false,
  alcohol_units_after_8pm int default 0,
  activity_minutes double precision default 0,
  vigorous_minutes double precision default 0,
  workload_hours double precision default 0,
  is_exam_day boolean default false,
  self_care_minutes double precision default 0,
  has_cycle_data boolean default false,
  cycle_phase text default 'No Data',
  post_11pm_screen_minutes double precision default 0,
  daytime_screen_hours double precision default 0,
  skipped_meals int default 0,
  sugary_items int default 0,
  water_glasses int default 0,
  updated_at timestamptz default timezone('utc', now())
);

alter table public.physio_state enable row level security;
alter table public.lifestyle_state enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'physio_state' and policyname = 'physio_select_all'
  ) then
    create policy physio_select_all on public.physio_state for select using (true);
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'physio_state' and policyname = 'physio_upsert_all'
  ) then
    create policy physio_upsert_all on public.physio_state for insert with check (true);
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'physio_state' and policyname = 'physio_update_all'
  ) then
    create policy physio_update_all on public.physio_state for update using (true) with check (true);
  end if;
end$$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'lifestyle_state' and policyname = 'lifestyle_select_all'
  ) then
    create policy lifestyle_select_all on public.lifestyle_state for select using (true);
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'lifestyle_state' and policyname = 'lifestyle_upsert_all'
  ) then
    create policy lifestyle_upsert_all on public.lifestyle_state for insert with check (true);
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'lifestyle_state' and policyname = 'lifestyle_update_all'
  ) then
    create policy lifestyle_update_all on public.lifestyle_state for update using (true) with check (true);
  end if;
end$$;
