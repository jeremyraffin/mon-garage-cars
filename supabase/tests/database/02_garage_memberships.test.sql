-- Membership invariants: role and state, one active owner per Garage, Auth
-- identity tied to state, and pseudonymous audit references that survive.
begin;
select plan(22);

-- Role and state
select throws_ok(
  $$ insert into public.garage_memberships (garage_id, auth_user_id, role, state)
     values ('10000000-0000-4000-8000-00000000000a', '20000000-0000-4000-8000-0000000000c1', 'admin', 'active') $$,
  '23514', null, 'unknown role is refused'
);
select throws_ok(
  $$ insert into public.garage_memberships (garage_id, auth_user_id, role, state)
     values ('10000000-0000-4000-8000-00000000000a', '20000000-0000-4000-8000-0000000000c1', 'parent', 'pending') $$,
  '23514', null, 'unknown state is refused'
);
select lives_ok(
  $$ insert into public.garage_memberships (garage_id, auth_user_id, role, state)
     values ('10000000-0000-4000-8000-00000000000a', '20000000-0000-4000-8000-0000000000c1', 'parent', 'active') $$,
  'a new active Parent is accepted'
);

-- One active owner per Garage
select throws_ok(
  $$ insert into public.garage_memberships (garage_id, auth_user_id, role, state)
     values ('10000000-0000-4000-8000-00000000000a', '20000000-0000-4000-8000-0000000000b1', 'owner', 'active') $$,
  '23505', null, 'a second active owner is refused'
);
select lives_ok(
  $$ insert into public.garage_memberships (garage_id, auth_user_id, role, state)
     values ('10000000-0000-4000-8000-00000000000a', null, 'owner', 'historical'),
            ('10000000-0000-4000-8000-00000000000a', '20000000-0000-4000-8000-0000000000b1', 'owner', 'removed') $$,
  'historical and removed owners do not count as active owners'
);
select lives_ok(
  $$ update public.garage_memberships set state = 'removed'
     where id = '30000000-0000-4000-8000-0000000000b1';
     insert into public.garage_memberships (garage_id, auth_user_id, role, state)
     values ('10000000-0000-4000-8000-00000000000b', '20000000-0000-4000-8000-0000000000c1', 'owner', 'active') $$,
  'a new owner is accepted once the previous one is no longer active'
);

-- Auth identity follows state
select throws_ok(
  $$ insert into public.garage_memberships (garage_id, auth_user_id, role, state)
     values ('10000000-0000-4000-8000-00000000000b', null, 'parent', 'active') $$,
  '23514', null, 'an active membership needs an Auth identity'
);
select throws_ok(
  $$ insert into public.garage_memberships (garage_id, auth_user_id, role, state)
     values ('10000000-0000-4000-8000-00000000000b', '20000000-0000-4000-8000-0000000000a2', 'parent', 'historical') $$,
  '23514', null, 'a historical membership cannot keep an Auth identity'
);
select lives_ok(
  $$ insert into public.garage_memberships (garage_id, auth_user_id, role, state)
     values ('10000000-0000-4000-8000-00000000000b', null, 'parent', 'removed'),
            ('10000000-0000-4000-8000-00000000000b', '20000000-0000-4000-8000-0000000000a2', 'parent', 'removed') $$,
  'a removed membership may or may not keep its Auth identity'
);
select throws_ok(
  $$ insert into public.garage_memberships (garage_id, auth_user_id, role, state)
     values ('10000000-0000-4000-8000-00000000000a', '20000000-0000-4000-8000-0000000000a2', 'parent', 'active') $$,
  '23505', null, 'an identity has a single active membership per Garage'
);
select lives_ok(
  $$ insert into public.garage_memberships (garage_id, auth_user_id, role, state)
     values ('10000000-0000-4000-8000-00000000000b', '20000000-0000-4000-8000-0000000000a2', 'parent', 'active') $$,
  'the same identity may be active in two Garages'
);
select throws_ok(
  $$ insert into public.garage_memberships (garage_id, auth_user_id, role, state)
     values ('10000000-0000-4000-8000-0000000000ff', '20000000-0000-4000-8000-0000000000c1', 'parent', 'active') $$,
  '23503', null, 'a membership belongs to an existing Garage'
);
select throws_ok(
  $$ insert into public.garage_memberships (garage_id, auth_user_id, role, state)
     values (null, '20000000-0000-4000-8000-0000000000c1', 'parent', 'active') $$,
  '23502', null, 'a membership belongs to exactly one Garage'
);

-- Pseudonymous audit references survive removal and Auth deletion
select lives_ok(
  $$ update public.garage_memberships set state = 'removed'
     where id = '30000000-0000-4000-8000-0000000000a2' $$,
  'an active Parent who authored a Fiche can be removed'
);
select is(
  (select created_by from public.fiches
   where id = '50000000-0000-4000-8000-0000000000a1'),
  '30000000-0000-4000-8000-0000000000a2'::uuid,
  'the Fiche still points to the removed membership'
);
select throws_ok(
  $$ delete from public.garage_memberships
     where id = '30000000-0000-4000-8000-0000000000a2' $$,
  '23503', null, 'a membership referenced by a Fiche cannot be deleted'
);
select is(
  (select auth_user_id from public.garage_memberships
   where id = '30000000-0000-4000-8000-0000000000a4'),
  null,
  'a historical membership keeps its id without any Auth identity'
);
select is(
  (select count(*) from public.fiches f
   join public.garage_memberships m on m.id = f.created_by and m.garage_id = f.garage_id
   where m.state = 'historical'),
  1::bigint,
  'a historical membership remains a valid audit author'
);

select lives_ok(
  $$ delete from auth.users where id = '20000000-0000-4000-8000-0000000000a3' $$,
  'deleting the Auth user of a removed membership is allowed'
);
select results_eq(
  $$ select state, auth_user_id from public.garage_memberships
     where id = '30000000-0000-4000-8000-0000000000a3' $$,
  $$ values ('removed', null::uuid) $$,
  'the removed membership is detached from Auth and kept'
);
select throws_ok(
  $$ delete from auth.users where id = '20000000-0000-4000-8000-0000000000c1' $$,
  '23514', null, 'deleting the Auth user of an active membership is refused'
);
select throws_ok(
  $$ update public.garage_memberships set garage_id = '10000000-0000-4000-8000-00000000000b'
     where id = '30000000-0000-4000-8000-0000000000a2' $$,
  '23503', null, 'a membership that authored a Fiche cannot move to another Garage'
);

select * from finish();
rollback;
