
-- JB TORNEIOS PRO V7.7.0
-- Sincronização multidispositivo segura por ID + chave privada.
-- Execute UMA VEZ no SQL Editor do Supabase.

create extension if not exists pgcrypto;

create table if not exists public.jb_sync_workspaces (
  sync_id text primary key,
  secret_hash text not null,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.jb_sync_workspaces enable row level security;

-- A tabela não terá acesso direto pelo cliente.
revoke all on table public.jb_sync_workspaces from anon, authenticated;

create or replace function public.jb_sync_create(
  p_sync_id text,
  p_secret text,
  p_payload jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_hash text;
begin
  if coalesce(length(trim(p_sync_id)),0) < 6 or coalesce(length(p_secret),0) < 10 then
    raise exception 'ID ou chave inválidos';
  end if;

  v_hash := encode(digest(p_secret, 'sha256'), 'hex');

  insert into public.jb_sync_workspaces(sync_id, secret_hash, payload, updated_at)
  values (upper(trim(p_sync_id)), v_hash, coalesce(p_payload,'{}'::jsonb), now());

  return jsonb_build_object('ok',true,'sync_id',upper(trim(p_sync_id)),'updated_at',now());
exception
  when unique_violation then
    raise exception 'Este ID de sincronização já existe';
end;
$$;

create or replace function public.jb_sync_push(
  p_sync_id text,
  p_secret text,
  p_payload jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_hash text;
  v_saved text;
begin
  v_hash := encode(digest(p_secret, 'sha256'), 'hex');

  select secret_hash into v_saved
  from public.jb_sync_workspaces
  where sync_id = upper(trim(p_sync_id));

  if v_saved is null or v_saved <> v_hash then
    raise exception 'ID ou chave de sincronização inválidos';
  end if;

  update public.jb_sync_workspaces
  set payload = coalesce(p_payload,'{}'::jsonb), updated_at = now()
  where sync_id = upper(trim(p_sync_id));

  return jsonb_build_object('ok',true,'updated_at',now());
end;
$$;

create or replace function public.jb_sync_pull(
  p_sync_id text,
  p_secret text
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_hash text;
  v_saved text;
  v_payload jsonb;
  v_updated timestamptz;
begin
  v_hash := encode(digest(p_secret, 'sha256'), 'hex');

  select secret_hash, payload, updated_at
    into v_saved, v_payload, v_updated
  from public.jb_sync_workspaces
  where sync_id = upper(trim(p_sync_id));

  if v_saved is null or v_saved <> v_hash then
    raise exception 'ID ou chave de sincronização inválidos';
  end if;

  return jsonb_build_object(
    'payload', v_payload,
    'updated_at', v_updated
  );
end;
$$;

revoke all on function public.jb_sync_create(text,text,jsonb) from public;
revoke all on function public.jb_sync_push(text,text,jsonb) from public;
revoke all on function public.jb_sync_pull(text,text) from public;

grant execute on function public.jb_sync_create(text,text,jsonb) to anon, authenticated;
grant execute on function public.jb_sync_push(text,text,jsonb) to anon, authenticated;
grant execute on function public.jb_sync_pull(text,text) to anon, authenticated;
