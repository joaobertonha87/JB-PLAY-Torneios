-- JB TORNEIOS PRO V7.8.0 — Conta JB Cloud
-- Execute UMA VEZ no SQL Editor do Supabase.

create table if not exists public.jb_user_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.jb_user_data enable row level security;

drop policy if exists "jb_user_select_own" on public.jb_user_data;
create policy "jb_user_select_own"
on public.jb_user_data for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "jb_user_insert_own" on public.jb_user_data;
create policy "jb_user_insert_own"
on public.jb_user_data for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "jb_user_update_own" on public.jb_user_data;
create policy "jb_user_update_own"
on public.jb_user_data for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

grant select, insert, update on public.jb_user_data to authenticated;
