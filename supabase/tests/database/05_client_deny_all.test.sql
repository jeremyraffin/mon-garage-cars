-- Deny-all base before #18: RLS on, no policy, and no grant to anon or
-- authenticated. Role-based attempts fail with insufficient_privilege.
begin;
select plan(23);

select is(
  (select count(*) from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public' and c.relkind in ('r', 'p') and not c.relrowsecurity),
  0::bigint, 'every table in public has RLS enabled');
select is((select count(*) from pg_policies where schemaname = 'public'), 0::bigint,
  'no policy exists yet');
select is(
  (select count(*) from information_schema.role_table_grants
   where table_schema = 'public' and grantee in ('anon', 'authenticated', 'PUBLIC')),
  0::bigint, 'anon, authenticated and PUBLIC hold no table grant');
select is(
  (select count(*) from information_schema.role_column_grants
   where table_schema = 'public' and grantee in ('anon', 'authenticated', 'PUBLIC')),
  0::bigint, 'no column grant either');
select is(
  (select count(*) from information_schema.routine_privileges
   where routine_schema in ('public', 'private') and grantee in ('anon', 'authenticated', 'PUBLIC')),
  0::bigint, 'no function of public or private is executable by clients');
select ok(not has_schema_privilege('anon', 'private', 'usage'), 'anon cannot use the private schema');
select ok(not has_schema_privilege('authenticated', 'private', 'usage'), 'authenticated cannot use the private schema');

select throws_ok(
  $$ set local role anon; select * from public.fiches; reset role $$,
  '42501', null, 'anon cannot read Fiches');
select throws_ok(
  $$ set local role anon; select * from public.appartenances_garage; reset role $$,
  '42501', null, 'anon cannot read appartenances');
select throws_ok(
  $$ set local role anon; select private.assert_fiche_has_thumbnail(); reset role $$,
  '42501', null, 'anon cannot call a private function');

-- Authenticated, signed in as the owner of Garage A, a Parent and a stranger.
select throws_ok(
  format($$ set local role authenticated;
    select set_config('request.jwt.claims', '{"sub":"%s","role":"authenticated"}', true);
    select * from public.%I; reset role $$, '20000000-0000-4000-8000-0000000000a1', t),
  '42501', null, 'owner of A cannot read ' || t)
from unnest(array['garages', 'appartenances_garage', 'oeuvres', 'fiches', 'fiche_photos', 'fiche_oeuvres']) as t;

select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a2","role":"authenticated"}', true);
     select * from public.fiches; reset role $$,
  '42501', null, 'an active Parent cannot read Fiches before #18');
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000c1","role":"authenticated"}', true);
     select * from public.fiches; reset role $$,
  '42501', null, 'a non-invited identity cannot read Fiches');
select throws_ok(
  $$ set local role authenticated;
     insert into public.oeuvres (garage_id, name) values ('10000000-0000-4000-8000-00000000000a', 'x'); reset role $$,
  '42501', null, 'authenticated cannot insert');
select throws_ok(
  $$ set local role authenticated;
     update public.fiches set version = 9; reset role $$,
  '42501', null, 'authenticated cannot update');
select throws_ok(
  $$ set local role authenticated; delete from public.fiche_oeuvres; reset role $$,
  '42501', null, 'authenticated cannot delete');
select throws_ok(
  $$ set local role anon; insert into public.garages default values; reset role $$,
  '42501', null, 'anon cannot insert');
select throws_ok(
  $$ set local role anon; truncate public.fiches; reset role $$,
  '42501', null, 'anon cannot truncate');

select * from finish();
rollback;
