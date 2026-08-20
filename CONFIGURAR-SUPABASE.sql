-- JB Torneios Pro V7.4 — configuração única do Supabase
-- 1) Crie um projeto no Supabase.
-- 2) Em Authentication > Providers/Sign In, ative Anonymous Sign-Ins.
-- 3) Abra SQL Editor, cole este arquivo e execute.

create table if not exists public.jb_tournaments (
  share_id text primary key,
  owner_id uuid not null,
  title text not null default 'Torneio',
  payload jsonb not null,
  is_public boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table public.jb_tournaments enable row level security;

-- Leitura pública: qualquer visitante com a anon key pode consultar apenas linhas publicadas.
drop policy if exists "jb_public_read" on public.jb_tournaments;
create policy "jb_public_read"
on public.jb_tournaments
for select
to anon, authenticated
using (is_public = true or owner_id = auth.uid());

-- Criação: usuário anônimo autenticado só cria linha em seu próprio nome.
drop policy if exists "jb_owner_insert" on public.jb_tournaments;
create policy "jb_owner_insert"
on public.jb_tournaments
for insert
to authenticated
with check (owner_id = auth.uid());

-- Atualização: apenas o dono da publicação.
drop policy if exists "jb_owner_update" on public.jb_tournaments;
create policy "jb_owner_update"
on public.jb_tournaments
for update
to authenticated
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

-- Exclusão: apenas o dono da publicação.
drop policy if exists "jb_owner_delete" on public.jb_tournaments;
create policy "jb_owner_delete"
on public.jb_tournaments
for delete
to authenticated
using (owner_id = auth.uid());

create index if not exists jb_tournaments_updated_at_idx
  on public.jb_tournaments(updated_at desc);
