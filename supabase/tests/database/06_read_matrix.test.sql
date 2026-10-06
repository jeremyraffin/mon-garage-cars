-- Read matrix (#18): who reads what, per identity, from the seed fixtures.
-- Identities: owner A (…a1), active Parent A (…a2), removed Parent A (…a3),
-- owner B (…b1), active Parent B (…b2), stranger without appartenance (…c1).
begin;
select plan(40);

-- The two helper functions below are repeated in 07_storage.test.sql on purpose:
-- pg_temp objects live and die with each test file's transaction.

-- Runs a one-column query as a client role and returns its sorted values.
create function pg_temp.read_as(who text, claims jsonb, q text)
returns text language plpgsql as $$
declare result text;
begin
  perform set_config('request.jwt.claims', claims::text, true);
  execute format('set local role %I', who);
  execute 'select coalesce(string_agg(x::text, '','' order by x::text), '''') from ('
    || q || ') s(x)' into result;
  reset role;
  return result;
end $$;

create function pg_temp.jwt(uid text) returns jsonb language sql as $$
  select jsonb_build_object('sub', uid, 'role', 'authenticated') $$;

-- Garage A, active Parent ------------------------------------------------------
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a2'),
    'select right(id::text, 2) from public.fiches'),
  'a1,a2,a3', 'an active Parent reads every Fiche of A: Brouillon, published, archived');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a2'),
    'select right(id::text, 2) from public.oeuvres'),
  'a1,a2', 'a Parent reads the Œuvres of A only');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a2'),
    'select right(id::text, 2) from public.fiche_photos'),
  'a1,a2,a3', 'a Parent reads the photo metadata of A only');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a2'),
    'select right(oeuvre_id::text, 2) from public.fiche_oeuvres'),
  'a1,a2', 'a Parent reads the Fiche–Œuvre links of A only');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a2'),
    'select right(id::text, 2) from public.appartenances_garage'),
  'a2', 'a Parent reads only their own appartenance');

-- Garage A, Propriétaire ---------------------------------------------------------
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a1'),
    'select right(id::text, 2) from public.fiches'),
  'a1,a2,a3', 'the Propriétaire of A reads every Fiche of A');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a1'),
    'select right(id::text, 2) from public.oeuvres'),
  'a1,a2', 'the Propriétaire reads the Œuvres of A');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a1'),
    'select right(id::text, 2) from public.fiche_photos'),
  'a1,a2,a3', 'the Propriétaire reads the photo metadata of A');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a1'),
    'select right(oeuvre_id::text, 2) from public.fiche_oeuvres'),
  'a1,a2', 'the Propriétaire reads the links of A');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a1'),
    'select right(id::text, 2) from public.appartenances_garage'),
  'a1,a2,a3,a4',
  'the Propriétaire reads every appartenance of A: active, removed and historical');

-- Garage B is a separate world -----------------------------------------------------
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000b2'),
    'select right(id::text, 2) from public.fiches'),
  'b1,b2', 'a Parent of B reads the Fiches of B and none of A');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000b2'),
    'select right(id::text, 2) from public.appartenances_garage'),
  'b2', 'a Parent of B reads only their own appartenance');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000b1'),
    'select right(id::text, 2) from public.appartenances_garage'),
  'b1,b2', 'the Propriétaire of B reads only the appartenances of B');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000b1'),
    'select right(id::text, 2) from public.oeuvres'),
  'b1', 'the Propriétaire of B reads only the Œuvres of B');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000b1'),
    'select right(id::text, 2) from public.fiche_photos'),
  'b1,b2', 'the Propriétaire of B reads only the photo metadata of B');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000b1'),
    'select right(oeuvre_id::text, 2) from public.fiche_oeuvres'),
  'b1', 'the Propriétaire of B reads only the links of B');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000b1'),
    'select count(*)::text from public.fiches where garage_id = ''10000000-0000-4000-8000-00000000000a'''),
  '0', 'a direct filter on Garage A returns nothing for the Propriétaire of B');

-- No access ---------------------------------------------------------------------
-- Removed Parent: the appartenance row exists but grants nothing.
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a3'),
    'select right(id::text, 2) from public.fiches'),
  '', 'a removed Parent reads no Fiche');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a3'),
    'select right(id::text, 2) from public.appartenances_garage'),
  '', 'a removed Parent does not even read their own appartenance');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a3'),
    'select right(id::text, 2) from public.oeuvres'),
  '', 'a removed Parent reads no Œuvre');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a3'),
    'select right(id::text, 2) from public.fiche_photos'),
  '', 'a removed Parent reads no photo metadata');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a3'),
    'select right(oeuvre_id::text, 2) from public.fiche_oeuvres'),
  '', 'a removed Parent reads no link');

-- Non-invited identity.
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000c1'),
    'select right(id::text, 2) from public.fiches'),
  '', 'a non-invited identity reads no Fiche');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000c1'),
    'select right(id::text, 2) from public.appartenances_garage'),
  '', 'a non-invited identity reads no appartenance');

-- Authenticated token without subject: no session.
select is(
  pg_temp.read_as('authenticated', '{"role":"authenticated"}'::jsonb,
    'select right(id::text, 2) from public.fiches'),
  '', 'a token without subject reads no Fiche');
select is(
  pg_temp.read_as('authenticated', '{"role":"authenticated"}'::jsonb,
    'select right(id::text, 2) from public.appartenances_garage'),
  '', 'a token without subject reads no appartenance');

-- Unauthorised Session d'appareil: until #7, a device-like token has no
-- appartenance and no matrix right, whatever its claims say.
select is(
  pg_temp.read_as('authenticated',
    '{"sub":"20000000-0000-4000-8000-0000000000d1","role":"authenticated","is_anonymous":true,"session_kind":"device","garage_id":"10000000-0000-4000-8000-00000000000a"}'::jsonb,
    'select right(id::text, 2) from public.fiches'),
  '', 'a device-like token reads no Fiche');
select is(
  pg_temp.read_as('authenticated',
    '{"sub":"20000000-0000-4000-8000-0000000000c1","role":"authenticated","is_anonymous":true}'::jsonb,
    'select right(id::text, 2) from public.fiche_photos'),
  '', 'an anonymous identity reads no photo metadata');

-- Rights come from the appartenance, never from the JWT.
select is(
  pg_temp.read_as('authenticated',
    '{"sub":"20000000-0000-4000-8000-0000000000c1","role":"authenticated","app_metadata":{"role":"owner","garage_id":"10000000-0000-4000-8000-00000000000a"},"user_metadata":{"role":"owner"},"user_role":"owner"}'::jsonb,
    'select right(id::text, 2) from public.fiches'),
  '', 'owner claims in the JWT grant nothing');
select is(
  pg_temp.read_as('authenticated',
    '{"sub":"20000000-0000-4000-8000-0000000000a2","role":"authenticated","app_metadata":{"role":"owner"}}'::jsonb,
    'select right(id::text, 2) from public.appartenances_garage'),
  'a2', 'an owner claim does not widen a Parent to the owner read');

-- Anon cannot read; there is no grant.
select throws_ok(
  $$ set local role anon; select * from public.fiche_photos; reset role $$,
  '42501', null, 'anon cannot read photo metadata');
select throws_ok(
  $$ set local role anon; select * from public.appartenances_garage; reset role $$,
  '42501', null, 'anon cannot read appartenances');

-- A removal takes effect immediately: the rights follow the appartenance row.
update public.appartenances_garage set state = 'removed'
  where id = '30000000-0000-4000-8000-0000000000a2';
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a2'),
    'select right(id::text, 2) from public.fiches'),
  '', 'a Parent removed during the session loses the read at once');
update public.appartenances_garage set state = 'active'
  where id = '30000000-0000-4000-8000-0000000000a2';
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a2'),
    'select right(id::text, 2) from public.fiches'),
  'a1,a2,a3', 'and gets it back when reinstated');

-- Policy helpers: the policies evaluate them, but a client cannot call them.
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a2","role":"authenticated"}', true);
     select * from private.my_garage_ids(); reset role $$,
  '42501', null, 'a Parent cannot call my_garage_ids directly');
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
     select * from private.my_owned_garage_ids(); reset role $$,
  '42501', null, 'the Propriétaire cannot call my_owned_garage_ids directly');
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000c1","role":"authenticated"}', true);
     select * from private.my_garage_ids(); reset role $$,
  '42501', null, 'a stranger cannot call my_garage_ids directly');
select throws_ok(
  $$ set local role anon; select * from private.my_owned_garage_ids(); reset role $$,
  '42501', null, 'anon cannot call my_owned_garage_ids');

-- auth_user_id is never returned to a client, the Propriétaire included.
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
     select auth_user_id from public.appartenances_garage; reset role $$,
  '42501', null, 'the Propriétaire cannot read auth_user_id');
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a2","role":"authenticated"}', true);
     select * from public.appartenances_garage; reset role $$,
  '42501', null, 'select * on appartenances_garage is refused: columns must be named');

select * from finish();
rollback;
