-- No relation may link two Garages, including under the server role.
begin;
select plan(14);

select lives_ok(
  $$ insert into public.fiche_oeuvres (garage_id, fiche_id, oeuvre_id)
     values ('10000000-0000-4000-8000-00000000000a', '50000000-0000-4000-8000-0000000000a1', '40000000-0000-4000-8000-0000000000a1') $$,
  'a Fiche links to an Œuvre of its own Garage');
select throws_ok(
  $$ insert into public.fiche_oeuvres (garage_id, fiche_id, oeuvre_id)
     values ('10000000-0000-4000-8000-00000000000a', '50000000-0000-4000-8000-0000000000a2', '40000000-0000-4000-8000-0000000000a1') $$,
  '23505', null, 'the same link twice is refused');
select throws_ok(
  $$ insert into public.fiche_oeuvres (garage_id, fiche_id, oeuvre_id)
     values ('10000000-0000-4000-8000-00000000000a', '50000000-0000-4000-8000-0000000000a1', '40000000-0000-4000-8000-0000000000b1') $$,
  '23503', null, 'a link to an Œuvre of another Garage is refused');
select throws_ok(
  $$ insert into public.fiche_oeuvres (garage_id, fiche_id, oeuvre_id)
     values ('10000000-0000-4000-8000-00000000000b', '50000000-0000-4000-8000-0000000000a1', '40000000-0000-4000-8000-0000000000b1') $$,
  '23503', null, 'a link to a Fiche of another Garage is refused');
select throws_ok(
  $$ delete from public.oeuvres where id = '40000000-0000-4000-8000-0000000000a1' $$,
  '23503', null, 'an Œuvre still linked to a Fiche cannot be deleted');

-- Authors
select throws_ok(
  $$ update public.fiches set created_by = '30000000-0000-4000-8000-0000000000b1'
     where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23503', null, 'the creator must belong to the Fiche Garage');
select throws_ok(
  $$ update public.fiches set updated_by = '30000000-0000-4000-8000-0000000000b1'
     where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23503', null, 'the last editor must belong to the Fiche Garage');
select throws_ok(
  $$ update public.fiches set published_by = '30000000-0000-4000-8000-0000000000b1'
     where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23503', null, 'the publisher must belong to the Fiche Garage');
select throws_ok(
  $$ update public.fiches set archived_by = '30000000-0000-4000-8000-0000000000b1'
     where id = '50000000-0000-4000-8000-0000000000a3' $$,
  '23503', null, 'the archiver must belong to the Fiche Garage');

-- Photos
select throws_ok(
  $$ insert into public.fiche_photos (id, garage_id, fiche_id, master_path)
     values ('60000000-0000-4000-8000-0000000000ab', '10000000-0000-4000-8000-00000000000a',
       '50000000-0000-4000-8000-0000000000b1',
       '10000000-0000-4000-8000-00000000000a/50000000-0000-4000-8000-0000000000b1/60000000-0000-4000-8000-0000000000ab/master.jpg') $$,
  '23503', null, 'a photo cannot attach a Fiche of another Garage');
select throws_ok(
  $$ update public.fiches set active_photo_id = '60000000-0000-4000-8000-0000000000b2'
     where id = '50000000-0000-4000-8000-0000000000a1';
     set constraints all immediate $$,
  '23503', null, 'the active photo cannot come from another Garage');
select throws_ok(
  $$ update public.fiches set active_photo_id = '60000000-0000-4000-8000-0000000000a2'
     where id = '50000000-0000-4000-8000-0000000000a1';
     set constraints all immediate $$,
  '23503', null, 'the active photo must belong to the same Fiche');
select throws_ok(
  $$ update public.fiches set garage_id = '10000000-0000-4000-8000-00000000000b'
     where id = '50000000-0000-4000-8000-0000000000a1' $$,
  '23503', null, 'a Fiche cannot move to another Garage');

-- The server role is bound by the same keys.
select throws_ok(
  $$ set local role service_role;
     insert into public.fiche_oeuvres (garage_id, fiche_id, oeuvre_id)
     values ('10000000-0000-4000-8000-00000000000a', '50000000-0000-4000-8000-0000000000a1', '40000000-0000-4000-8000-0000000000b1');
     reset role $$,
  '23503', null, 'the server role cannot link two Garages');

select * from finish();
rollback;
