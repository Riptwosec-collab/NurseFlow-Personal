-- NurseFlow Personal v0.7. Migration already applied to Supabase as 20261027030848.
create table if not exists public.nurseflow_user_backups (
 owner_id uuid primary key references auth.users(id) on delete cascade,
 snapshot jsonb not null,
 version bigint not null default 1 check (version >= 1),
 updated_at timestamptz not null default now(),
 constraint nurseflow_snapshot_object check (jsonb_typeof(snapshot) = 'object'),
 constraint nurseflow_snapshot_size check (octet_length(snapshot::text) <= 800000)
);
alter table public.nurseflow_user_backups enable row level security;
revoke all on public.nurseflow_user_backups from public, anon;
grant select, insert, delete on public.nurseflow_user_backups to authenticated;
grant update(snapshot, version, updated_at) on public.nurseflow_user_backups to authenticated;
create policy "nurseflow_owner_select" on public.nurseflow_user_backups for select to authenticated using ((select auth.uid()) = owner_id);
create policy "nurseflow_owner_insert" on public.nurseflow_user_backups for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "nurseflow_owner_update" on public.nurseflow_user_backups for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "nurseflow_owner_delete" on public.nurseflow_user_backups for delete to authenticated using ((select auth.uid()) = owner_id);
