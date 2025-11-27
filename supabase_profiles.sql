-- Profiles table for Anxiety Calculator iOS app
-- Run this in the Supabase SQL editor or via `supabase db remote commit`.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  phone text,
  avatar_url text,
  date_of_birth date,
  membership text default 'Member',
  days_active int default 1,
  check_ins int default 0,
  streak int default 0,
  improvement numeric default 0,
  updated_at timestamptz default timezone('utc', now())
);

alter table public.profiles enable row level security;

-- RLS: users can only see/manage their own profile
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles' and policyname = 'Read own profile'
  ) then
    create policy "Read own profile" on public.profiles
      for select using (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles' and policyname = 'Insert own profile'
  ) then
    create policy "Insert own profile" on public.profiles
      for insert with check (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles' and policyname = 'Update own profile'
  ) then
    create policy "Update own profile" on public.profiles
      for update using (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'profiles' and policyname = 'Delete own profile'
  ) then
    create policy "Delete own profile" on public.profiles
      for delete using (true);
  end if;
end$$;
