-- Client surface after #18: SELECT only, on five tables, to authenticated only.
-- appartenances_garage is granted by column, without auth_user_id.
-- No mutation, no truncate, no grant to anon or PUBLIC, and no direct call of a
-- function: authenticated only holds EXECUTE on the two argument-less policy
-- helpers, without USAGE on their schema. Any new table in
-- public must enable RLS and must not be granted to a client role: this file
-- turns red otherwise.
begin;
select plan(38);

-- RLS coverage ---------------------------------------------------------------
select is(
  (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public' and c.relkind in ('r', 'p') and not c.relrowsecurity),
  0::bigint, 'every table in public has RLS enabled');
select is(
  (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'storage' and c.relkind in ('r', 'p') and not c.relrowsecurity),
  0::bigint, 'every table in storage has RLS enabled');

-- TRUNCATE ignores RLS and its policies: no client may hold it on Storage.
select is(
  (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
   cross join (values ('anon'), ('authenticated')) r(role)
   where n.nspname in ('public', 'storage') and c.relkind in ('r', 'p')
     and has_table_privilege(r.role, c.oid, 'truncate')),
  0::bigint, 'no client role may TRUNCATE any table of public or storage');

-- Policies: exactly the accepted read matrix -----------------------------------
select is(
  (select string_agg(concat_ws(':', tablename, policyname, cmd, roles::text, permissive), ' ' order by tablename)
   from pg_policies where schemaname = 'public'),
  'appartenances_garage:appartenances_garage_select:SELECT:{authenticated}:PERMISSIVE '
  || 'fiche_oeuvres:fiche_oeuvres_select:SELECT:{authenticated}:PERMISSIVE '
  || 'fiche_photos:fiche_photos_select:SELECT:{authenticated}:PERMISSIVE '
  || 'fiches:fiches_select:SELECT:{authenticated}:PERMISSIVE '
  || 'oeuvres:oeuvres_select:SELECT:{authenticated}:PERMISSIVE',
  'public holds five SELECT policies for authenticated and nothing else');
select is((select count(*) from pg_policies where schemaname = 'public' and tablename = 'garages'),
  0::bigint, 'garages has no policy: it stays closed to clients');

select is(
  (select string_agg(concat_ws(':', tablename, policyname, cmd, roles::text, permissive,
     case when permissive = 'RESTRICTIVE' then coalesce(qual, '-') || ':' || coalesce(with_check, '-') else '*' end),
     ' ' order by policyname)
   from pg_policies where schemaname = 'storage'),
  'objects:fiche_photos_objects_select:SELECT:{authenticated}:PERMISSIVE:* '
  || 'objects:no_client_delete:DELETE:{anon,authenticated}:RESTRICTIVE:false:- '
  || 'objects:no_client_insert:INSERT:{anon,authenticated}:RESTRICTIVE:-:false '
  || 'objects:no_client_update:UPDATE:{anon,authenticated}:RESTRICTIVE:false:false',
  'storage.objects holds exactly one read policy and three restrictive mutation refusals');
select is((select count(*) from pg_policies where schemaname = 'storage' and tablename <> 'objects'),
  0::bigint, 'no other Storage table has a policy');

-- Table grants -------------------------------------------------------------------
select is(
  (select string_agg(concat_ws(':', table_name, grantee, privilege_type), ' '
                     order by table_name, grantee, privilege_type)
   from information_schema.role_table_grants
   where table_schema = 'public' and grantee in ('anon', 'authenticated', 'PUBLIC')),
  'fiche_oeuvres:authenticated:SELECT fiche_photos:authenticated:SELECT '
  || 'fiches:authenticated:SELECT oeuvres:authenticated:SELECT',
  'clients hold a table-level SELECT on four matrix tables and nothing else');
select is(
  (select string_agg(t.relname || ':' || t.readable || '/' || t.total, ' ' order by t.relname)
   from (select c.relname,
           count(*) filter (where has_column_privilege('authenticated', c.oid, a.attnum, 'select')) as readable,
           count(*) as total
         from pg_class c join pg_namespace n on n.oid = c.relnamespace
         join pg_attribute a on a.attrelid = c.oid and a.attnum > 0 and not a.attisdropped
         where n.nspname = 'public' and c.relkind = 'r'
         group by c.relname) t),
  'appartenances_garage:5/6 fiche_oeuvres:4/4 fiche_photos:6/6 fiches:18/18 garages:0/2 oeuvres:4/4',
  'authenticated reads every column of four tables, appartenances_garage without auth_user_id, and garages none');
select is(
  (select count(*)
   from pg_class c join pg_namespace n on n.oid = c.relnamespace
   join pg_attribute a on a.attrelid = c.oid and a.attnum > 0 and not a.attisdropped
   cross join (values ('anon'), ('authenticated')) r(role)
   where n.nspname = 'public' and c.relkind = 'r'
     and (has_column_privilege(r.role, c.oid, a.attnum, 'insert')
       or has_column_privilege(r.role, c.oid, a.attnum, 'update')
       or has_column_privilege(r.role, c.oid, a.attnum, 'references')
       or (r.role = 'anon' and has_column_privilege(r.role, c.oid, a.attnum, 'select')))),
  0::bigint, 'no column-level mutation or reference right, and no column read for anon');
select is(
  (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public' and c.relkind in ('S', 'v', 'm', 'f')
     and (has_table_privilege('anon', c.oid, 'select,insert,update,delete')
       or has_table_privilege('authenticated', c.oid, 'insert,update,delete'))),
  0::bigint, 'no sequence, view or other relation of public is open to clients');

-- Functions ------------------------------------------------------------------------
select is(
  (select count(*) from information_schema.routine_privileges
   where routine_schema in ('public', 'private') and grantee in ('anon', 'PUBLIC')),
  0::bigint, 'anon and PUBLIC execute no function of public or private');
select is(
  (select string_agg(routine_schema || '.' || routine_name, ' ' order by routine_name)
   from information_schema.routine_privileges
   where routine_schema in ('public', 'private') and grantee = 'authenticated'),
  'private.my_garage_ids private.my_owned_garage_ids',
  'authenticated executes only the two policy helpers');
select is(
  (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'private' and p.prosecdef
     and not (coalesce(p.proconfig, '{}') @> array['search_path=""'])),
  0::bigint, 'every SECURITY DEFINER function of private pins an empty search_path');
select is(
  (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public'),
  0::bigint, 'public exposes no function (no RPC surface)');
select ok(not has_schema_privilege('anon', 'private', 'usage'), 'anon cannot use the private schema');
select ok(not has_schema_privilege('authenticated', 'private', 'usage'),
  'authenticated cannot use the private schema, so no direct call of a helper');
select ok(not has_function_privilege('authenticated', 'private.assert_fiche_has_thumbnail()', 'execute'),
  'authenticated cannot call a trigger function');
select ok(not has_function_privilege('authenticated', 'private.assert_active_photo_keeps_thumbnail()', 'execute'),
  'authenticated cannot call the other trigger function');

select throws_ok(
  $$ set local role anon; select private.my_garage_ids(); reset role $$,
  '42501', null, 'anon cannot call a policy helper');
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
     select * from private.my_garage_ids(); reset role $$,
  '42501', null, 'authenticated cannot call a policy helper directly');
select throws_ok(
  $$ set local role anon; select private.assert_fiche_has_thumbnail(); reset role $$,
  '42501', null, 'anon cannot call a trigger function');
select throws_ok(
  $$ set local role authenticated; select private.assert_fiche_has_thumbnail(); reset role $$,
  '42501', null, 'authenticated cannot call a trigger function');

-- Reads closed to anon and to garages ---------------------------------------------
select throws_ok(
  format($$ set local role anon; select * from public.%I; reset role $$, t),
  '42501', null, 'anon cannot read ' || t)
from unnest(array['garages', 'fiches']) as t;
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
     select * from public.garages; reset role $$,
  '42501', null, 'the Propriétaire of A cannot read the garages table');

-- No direct mutation for any client role, Propriétaire included --------------------
select throws_ok(
  format($$ set local role authenticated;
    select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
    insert into public.%I default values; reset role $$, t),
  '42501', null, 'the Propriétaire cannot insert into ' || t)
from unnest(array['garages', 'appartenances_garage', 'oeuvres']) as t;
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
     update public.fiches set version = 9; reset role $$,
  '42501', null, 'the Propriétaire cannot update Fiches');
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
     delete from public.fiche_oeuvres; reset role $$,
  '42501', null, 'the Propriétaire cannot delete links');
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
     truncate public.fiches; reset role $$,
  '42501', null, 'the Propriétaire cannot truncate');
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a2","role":"authenticated"}', true);
     update public.appartenances_garage set role = 'owner'; reset role $$,
  '42501', null, 'a Parent cannot promote an appartenance');
select throws_ok(
  $$ set local role anon; insert into public.garages default values; reset role $$,
  '42501', null, 'anon cannot insert');
select throws_ok(
  $$ set local role anon; truncate public.fiches; reset role $$,
  '42501', null, 'anon cannot truncate');
select throws_ok(
  $$ set local role anon; update public.fiches set version = 9; reset role $$,
  '42501', null, 'anon cannot update');
select throws_ok(
  $$ set local role anon; delete from public.oeuvres; reset role $$,
  '42501', null, 'anon cannot delete');
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
     insert into public.fiche_photos default values; reset role $$,
  '42501', null, 'the Propriétaire cannot insert photo metadata');

select * from finish();
rollback;
