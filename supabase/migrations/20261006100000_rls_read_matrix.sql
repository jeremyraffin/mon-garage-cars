-- Read matrix and photo protection (issue #18, parent #4).
--
-- Only SELECT is opened, only to `authenticated`, and only through policies
-- derived from public.appartenances_garage: no role is copied into the JWT.
-- A Parent or the Propriétaire (active appartenance) reads their own Garage;
-- everyone else, and every mutation by a client role, stays refused. The
-- Session d'appareil comes with #7 and is refused until then.

-- ---------------------------------------------------------------------------
-- Policy helpers
--
-- A policy runs with the privileges of the querying role, so the only two
-- functions a client role may execute live here. They take no argument and
-- return only the Garages of the caller (auth.uid()), so they cannot be used
-- to probe another identity or another Garage. The owner-wide read of
-- appartenances_garage cannot be written as a subquery of its own policy
-- (infinite recursion), hence SECURITY DEFINER.
-- ---------------------------------------------------------------------------

create function private.my_garage_ids()
returns setof uuid
language sql
stable
security definer
set search_path = ''
as $$
  select m.garage_id
  from public.appartenances_garage m
  where m.auth_user_id = (select auth.uid())
    and m.state = 'active';
$$;

create function private.my_owned_garage_ids()
returns setof uuid
language sql
stable
security definer
set search_path = ''
as $$
  select m.garage_id
  from public.appartenances_garage m
  where m.auth_user_id = (select auth.uid())
    and m.state = 'active'
    and m.role = 'owner';
$$;

revoke all on function private.my_garage_ids() from public;
revoke all on function private.my_owned_garage_ids() from public;
grant usage on schema private to authenticated;
grant execute on function private.my_garage_ids() to authenticated;
grant execute on function private.my_owned_garage_ids() to authenticated;

-- ---------------------------------------------------------------------------
-- Table reads
-- public.garages stays closed: the matrix does not read it.
-- ---------------------------------------------------------------------------

grant select on table
  public.appartenances_garage,
  public.oeuvres,
  public.fiches,
  public.fiche_photos,
  public.fiche_oeuvres
to authenticated;

create policy appartenances_garage_select on public.appartenances_garage
  for select to authenticated
  using (
    (auth_user_id = (select auth.uid()) and state = 'active')
    or garage_id in (select private.my_owned_garage_ids())
  );

create policy oeuvres_select on public.oeuvres
  for select to authenticated
  using (garage_id in (select private.my_garage_ids()));

create policy fiches_select on public.fiches
  for select to authenticated
  using (garage_id in (select private.my_garage_ids()));

create policy fiche_photos_select on public.fiche_photos
  for select to authenticated
  using (garage_id in (select private.my_garage_ids()));

create policy fiche_oeuvres_select on public.fiche_oeuvres
  for select to authenticated
  using (garage_id in (select private.my_garage_ids()));

-- ---------------------------------------------------------------------------
-- Private photo bucket
--
-- Objects live under <garage_id>/<fiche_id>/<photo_id>/..., so the first path
-- segment bounds the read. No insert, update or delete policy: uploads and
-- replacements come with the business commands of #6.
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public)
values ('fiche-photos', 'fiche-photos', false)
on conflict (id) do update set public = false;

create policy fiche_photos_objects_select on storage.objects
  for select to authenticated
  using (
    bucket_id = 'fiche-photos'
    and (storage.foldername(name))[1] in (
      select g::text from private.my_garage_ids() as g
    )
  );

-- Client roles never mutate Storage directly. The table belongs to
-- supabase_storage_admin, so its default INSERT/UPDATE/DELETE grants cannot be
-- revoked from here; a restrictive policy refuses them even if a permissive
-- policy is added later by mistake. Business commands use the service role.
create policy no_client_insert on storage.objects
  as restrictive for insert to anon, authenticated
  with check (false);

create policy no_client_update on storage.objects
  as restrictive for update to anon, authenticated
  using (false) with check (false);

create policy no_client_delete on storage.objects
  as restrictive for delete to anon, authenticated
  using (false);
