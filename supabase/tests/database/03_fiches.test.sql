-- Fiche invariants: state, version, completeness, metadata, photos.
-- Each statement ends with `set constraints all immediate` so that deferred
-- checks (active photo, thumbnail) fire inside the assertion.
begin;
select plan(30);

select col_type_is('public', 'fiches', 'number', 'text', 'the number is text');

-- Version and status
select throws_ok(
  $$ update public.fiches set version = 0 where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23514', null, 'version zero is refused');
select throws_ok(
  $$ update public.fiches set version = -1 where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23514', null, 'negative version is refused');
select lives_ok(
  $$ update public.fiches set version = 3 where id = '50000000-0000-4000-8000-0000000000a2' $$,
  'a positive version is accepted');
select throws_ok(
  $$ update public.fiches set status = 'deleted' where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23514', null, 'unknown status is refused');

-- Colour, blank fields
select throws_ok(
  $$ update public.fiches set color = 'red' where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23514', null, 'a colour name is refused');
select throws_ok(
  $$ update public.fiches set color = '#12345' where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23514', null, 'a short hex colour is refused');
select throws_ok(
  $$ update public.fiches set color = '#GGGGGG' where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23514', null, 'a non-hex colour is refused');
select lives_ok(
  $$ update public.fiches set color = '#aBc123' where id = '50000000-0000-4000-8000-0000000000a2' $$,
  'a #RRGGBB colour is accepted');
select throws_ok(
  $$ update public.fiches set name_fr = '  ' where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23514', null, 'a blank name is refused');
select throws_ok(
  $$ update public.fiches set description = '' where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23514', null, 'a blank description is refused');

-- Publication requirements
select throws_ok(
  $$ update public.fiches set name_fr = null where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23514', null, 'a published Fiche needs a name');
select throws_ok(
  $$ update public.fiches set color = null where id = '50000000-0000-4000-8000-0000000000a3' $$,
  '23514', null, 'an archived Fiche needs a colour');
select throws_ok(
  $$ update public.fiches set status = 'published',
       published_by = '30000000-0000-4000-8000-0000000000a1', published_at = now()
     where id = '50000000-0000-4000-8000-0000000000a1' $$,
  '23514', null, 'a Brouillon with only a photo cannot be published');
select throws_ok(
  $$ update public.fiches set status = 'published', name_fr = 'Nom', color = '#112233',
       description = 'Description', published_by = '30000000-0000-4000-8000-0000000000a1',
       published_at = now();
     set constraints all immediate $$,
  '23514', null, 'publishing is refused while the active photo has no thumbnail');
select lives_ok(
  $$ update public.fiche_photos set thumbnail_path =
       '10000000-0000-4000-8000-00000000000a/50000000-0000-4000-8000-0000000000a1/60000000-0000-4000-8000-0000000000a1/thumbnail.webp'
     where id = '60000000-0000-4000-8000-0000000000a1';
     update public.fiches set status = 'published', name_fr = 'Nom', color = '#112233',
       description = 'Description', published_by = '30000000-0000-4000-8000-0000000000a1',
       published_at = now(), updated_at = now()
     where id = '50000000-0000-4000-8000-0000000000a1';
     set constraints all immediate $$,
  'a complete Brouillon with a thumbnail can be published');
select throws_ok(
  $$ update public.fiche_photos set thumbnail_path = null
     where id = '60000000-0000-4000-8000-0000000000a2';
     set constraints all immediate $$,
  '23514', null, 'the thumbnail of a published Fiche cannot be removed');

-- Metadata coherence
select throws_ok(
  $$ update public.fiches set published_by = null where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23514', null, 'a published Fiche needs its publication author');
select throws_ok(
  $$ update public.fiches set archived_by = null where id = '50000000-0000-4000-8000-0000000000a3' $$,
  '23514', null, 'an archived Fiche needs its archiving author');
select throws_ok(
  $$ update public.fiches set published_at = now(), published_by = '30000000-0000-4000-8000-0000000000a1'
     where id = '50000000-0000-4000-8000-0000000000b2' $$,
  '23514', null, 'a Brouillon carries no publication metadata');
select throws_ok(
  $$ update public.fiches set archived_at = now(), archived_by = '30000000-0000-4000-8000-0000000000a1'
     where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23514', null, 'a published Fiche carries no archiving metadata');
select throws_ok(
  $$ update public.fiches set updated_at = created_at - interval '1 day'
     where id = '50000000-0000-4000-8000-0000000000a2' $$,
  '23514', null, 'a Fiche cannot be updated before being created');
select throws_ok(
  $$ update public.fiches set archived_at = published_at - interval '1 day'
     where id = '50000000-0000-4000-8000-0000000000a3' $$,
  '23514', null, 'a Fiche cannot be archived before being published');

-- Optional fields and no uniqueness on similar Fiches
select lives_ok(
  $$ set constraints all deferred;
     insert into public.fiches (id, garage_id, status, name_fr, color, description, number,
       active_photo_id, created_by, created_at, updated_by, updated_at, published_by, published_at)
     select '50000000-0000-4000-8000-0000000000a9', garage_id, status, name_fr, color, description, number,
       '60000000-0000-4000-8000-0000000000a9', created_by, created_at, updated_by, updated_at, published_by, published_at
     from public.fiches where id = '50000000-0000-4000-8000-0000000000a2';
     insert into public.fiche_photos (id, garage_id, fiche_id, master_path, thumbnail_path)
     values ('60000000-0000-4000-8000-0000000000a9', '10000000-0000-4000-8000-00000000000a',
       '50000000-0000-4000-8000-0000000000a9',
       '10000000-0000-4000-8000-00000000000a/50000000-0000-4000-8000-0000000000a9/60000000-0000-4000-8000-0000000000a9/master.jpg',
       '10000000-0000-4000-8000-00000000000a/50000000-0000-4000-8000-0000000000a9/60000000-0000-4000-8000-0000000000a9/thumbnail.webp');
     set constraints all immediate $$,
  'a look-alike Fiche (same name, colour, number) is not blocked');
select is(
  (select count(*) from public.fiches where number = '95'), 2::bigint,
  'the number is not unique');
select lives_ok(
  $$ update public.fiches set number = null, team = null where id = '50000000-0000-4000-8000-0000000000a2' $$,
  'number and team are optional');

-- Photos
select throws_ok(
  $$ set constraints all deferred;
     insert into public.fiches (id, garage_id, active_photo_id, created_by, updated_by)
     values ('50000000-0000-4000-8000-0000000000a8', '10000000-0000-4000-8000-00000000000a',
       '60000000-0000-4000-8000-0000000000a8', '30000000-0000-4000-8000-0000000000a1',
       '30000000-0000-4000-8000-0000000000a1');
     set constraints all immediate $$,
  '23503', null, 'a Fiche without its photo is refused');
select throws_ok(
  $$ insert into public.fiche_photos (garage_id, fiche_id, master_path)
     values ('10000000-0000-4000-8000-00000000000a', '50000000-0000-4000-8000-0000000000a1', 'master.jpg') $$,
  '23514', null, 'a storage path without the photo id is refused');
select lives_ok(
  $$ insert into public.fiche_photos (id, garage_id, fiche_id, master_path, thumbnail_path)
     values ('60000000-0000-4000-8000-0000000000aa', '10000000-0000-4000-8000-00000000000a',
       '50000000-0000-4000-8000-0000000000a2',
       '10000000-0000-4000-8000-00000000000a/50000000-0000-4000-8000-0000000000a2/60000000-0000-4000-8000-0000000000aa/master.jpg',
       '10000000-0000-4000-8000-00000000000a/50000000-0000-4000-8000-0000000000a2/60000000-0000-4000-8000-0000000000aa/thumbnail.webp');
     update public.fiches set active_photo_id = '60000000-0000-4000-8000-0000000000aa'
     where id = '50000000-0000-4000-8000-0000000000a2';
     delete from public.fiche_photos where id = '60000000-0000-4000-8000-0000000000a2';
     set constraints all immediate $$,
  'a replacement photo has its own path and the old one is removed after the swap');
select throws_ok(
  $$ delete from public.fiche_photos where id = '60000000-0000-4000-8000-0000000000aa';
     set constraints all immediate $$,
  '23503', null, 'the active photo cannot be deleted');

select * from finish();
rollback;
