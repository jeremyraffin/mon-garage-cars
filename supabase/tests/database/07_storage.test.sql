-- Private photo bucket (#18): read by Garage, no client mutation.
-- Objects are inserted here with the server role; no real photo is involved.
begin;
select plan(18);

-- read_as and jwt are repeated from 06_read_matrix.test.sql on purpose:
-- pg_temp objects live and die with each test file's transaction.

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

-- Runs a statement as a client role and returns the number of rows it touched.
create function pg_temp.affected_as(who text, claims jsonb, stmt text)
returns text language plpgsql as $$
declare n bigint;
begin
  perform set_config('request.jwt.claims', claims::text, true);
  execute format('set local role %I', who);
  execute stmt;
  get diagnostics n = row_count;
  reset role;
  return n::text;
end $$;

create function pg_temp.jwt(uid text) returns jsonb language sql as $$
  select jsonb_build_object('sub', uid, 'role', 'authenticated') $$;

insert into storage.buckets (id, name, public) values ('elsewhere', 'elsewhere', false);

insert into storage.objects (bucket_id, name)
values
  ('fiche-photos', '10000000-0000-4000-8000-00000000000a/50000000-0000-4000-8000-0000000000a2/60000000-0000-4000-8000-0000000000a2/master.jpg'),
  ('fiche-photos', '10000000-0000-4000-8000-00000000000a/50000000-0000-4000-8000-0000000000a2/60000000-0000-4000-8000-0000000000a2/thumbnail.webp'),
  ('fiche-photos', '10000000-0000-4000-8000-00000000000b/50000000-0000-4000-8000-0000000000b1/60000000-0000-4000-8000-0000000000b1/master.jpg'),
  ('fiche-photos', 'loose.jpg'),
  ('elsewhere', '10000000-0000-4000-8000-00000000000a/other.jpg');

select is((select public from storage.buckets where id = 'fiche-photos'), false,
  'the photo bucket is private');
select is((select count(*) from storage.buckets where public), 0::bigint, 'no bucket is public');

-- Reads ------------------------------------------------------------------------
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a2'),
    'select split_part(name, ''/'', 4) from storage.objects'),
  'master.jpg,thumbnail.webp', 'a Parent of A reads the photo objects of A only');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a1'),
    'select split_part(name, ''/'', 4) from storage.objects'),
  'master.jpg,thumbnail.webp', 'the Propriétaire of A reads the photo objects of A only');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000b2'),
    'select left(name, 36) from storage.objects'),
  '10000000-0000-4000-8000-00000000000b', 'a Parent of B reads only the photo object of B');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000b1'),
    'select count(*)::text from storage.objects where name like ''10000000-0000-4000-8000-00000000000a/%'''),
  '0', 'the Propriétaire of B reads nothing under the path of A');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a3'),
    'select name from storage.objects'),
  '', 'a removed Parent reads no photo object');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000c1'),
    'select name from storage.objects'),
  '', 'a non-invited identity reads no photo object');
select is(
  pg_temp.read_as('authenticated', '{"role":"authenticated"}'::jsonb,
    'select name from storage.objects'),
  '', 'a token without subject reads no photo object');
select is(
  pg_temp.read_as('authenticated',
    '{"sub":"20000000-0000-4000-8000-0000000000d1","role":"authenticated","is_anonymous":true,"session_kind":"device"}'::jsonb,
    'select name from storage.objects'),
  '', 'a device-like token reads no photo object');
select is(
  pg_temp.read_as('anon', '{"role":"anon"}'::jsonb, 'select name from storage.objects'),
  '', 'anon reads no photo object');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a2'),
    'select name from storage.objects where bucket_id = ''elsewhere'''),
  '', 'a path under the Garage id in another bucket stays closed');
select is(
  pg_temp.read_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a2'),
    'select name from storage.objects where name = ''loose.jpg'''),
  '', 'an object outside any Garage folder is not readable');

-- Mutations ----------------------------------------------------------------------
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
     insert into storage.objects (bucket_id, name)
     values ('fiche-photos', '10000000-0000-4000-8000-00000000000a/new.jpg'); reset role $$,
  '42501', null, 'the Propriétaire cannot upload an object');
select throws_ok(
  $$ set local role anon;
     insert into storage.objects (bucket_id, name)
     values ('fiche-photos', '10000000-0000-4000-8000-00000000000a/new.jpg'); reset role $$,
  '42501', null, 'anon cannot upload an object');
select is(
  pg_temp.affected_as('authenticated', pg_temp.jwt('20000000-0000-4000-8000-0000000000a1'),
    'update storage.objects set name = name || ''x'''),
  '0', 'the Propriétaire updates no object');
-- Storage's own protect_delete trigger refuses a direct DELETE before the
-- restrictive policy is even evaluated: two independent barriers.
select throws_ok(
  $$ set local role authenticated;
     select set_config('request.jwt.claims', '{"sub":"20000000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
     delete from storage.objects; reset role $$,
  null, 'Direct deletion from storage tables is not allowed. Use the Storage API instead.',
  'the Propriétaire cannot delete an object');
select is((select count(*) from storage.objects), 5::bigint, 'every object is still there');

select * from finish();
rollback;
