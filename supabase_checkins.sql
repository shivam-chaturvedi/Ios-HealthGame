-- Check-ins and tagged moments tables with permissive RLS (allow all users; tighten if needed).

create table if not exists public.checkins (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  gad2 int not null default 0,
  mood int not null default 0,
  gad_updated timestamptz not null default timezone('utc', now()),
  mood_updated timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.checkin_moments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  note text,
  intensity float8,
  timestamp timestamptz not null default timezone('utc', now())
);

alter table public.checkins enable row level security;
alter table public.checkin_moments enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'checkins' and policyname = 'checkins_read_all'
  ) then
    create policy checkins_read_all on public.checkins for select using (true);
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'checkins' and policyname = 'checkins_write_all'
  ) then
    create policy checkins_write_all on public.checkins for insert with check (true);
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'checkins' and policyname = 'checkins_update_all'
  ) then
    create policy checkins_update_all on public.checkins for update using (true) with check (true);
  end if;
end$$;

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'checkin_moments' and policyname = 'moments_read_all'
  ) then
    create policy moments_read_all on public.checkin_moments for select using (true);
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'checkin_moments' and policyname = 'moments_write_all'
  ) then
    create policy moments_write_all on public.checkin_moments for insert with check (true);
  end if;
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'checkin_moments' and policyname = 'moments_update_all'
  ) then
    create policy moments_update_all on public.checkin_moments for update using (true) with check (true);
  end if;
end$$;
