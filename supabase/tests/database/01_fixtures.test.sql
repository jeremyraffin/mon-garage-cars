-- The fictitious fixtures of supabase/seed.sql cover the cases every other
-- test relies on. If this file fails on a fresh checkout, run
-- `npx supabase db reset` so the migrations and the seed are applied.
begin;
select plan(9);

select is((select count(*) from public.garages), 2::bigint, 'two Garages');

select results_eq(
  $$ select garage_id, role, state, auth_user_id is not null
     from public.appartenances_garage
     order by garage_id, id $$,
  $$ values
    ('10000000-0000-4000-8000-00000000000a'::uuid, 'owner', 'active', true),
    ('10000000-0000-4000-8000-00000000000a'::uuid, 'parent', 'active', true),
    ('10000000-0000-4000-8000-00000000000a'::uuid, 'parent', 'removed', true),
    ('10000000-0000-4000-8000-00000000000a'::uuid, 'parent', 'historical', false),
    ('10000000-0000-4000-8000-00000000000b'::uuid, 'owner', 'active', true),
    ('10000000-0000-4000-8000-00000000000b'::uuid, 'parent', 'active', true) $$,
  'appartenances cover owner, active Parent, removed Parent and historical appartenance'
);

select results_eq(
  $$ select status from public.fiches
     where garage_id = '10000000-0000-4000-8000-00000000000a'
     order by status $$,
  $$ values ('archived'), ('draft'), ('published') $$,
  'Garage A has a Fiche in each state'
);

select is((select count(*) from public.oeuvres), 3::bigint, 'three Œuvres');
select is((select count(*) from public.fiche_photos), 5::bigint, 'one photo per Fiche');
select is((select count(*) from public.fiche_oeuvres), 3::bigint, 'three Fiche–Œuvre links');

select is(
  (select count(*) from public.fiches
   where name_fr is null and color is null and description is null),
  2::bigint,
  'Brouillons exist with only their photo'
);

select is(
  (select count(*) from public.appartenances_garage m
   where not exists (
     select 1 from public.garages g where g.id = m.garage_id
   )),
  0::bigint,
  'every appartenance belongs to a Garage'
);

select is(
  (select count(*) from auth.users where email !~ '@example\.test$'),
  0::bigint,
  'fixture identities use the reserved example.test domain only'
);

select * from finish();
rollback;
