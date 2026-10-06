-- Garage data model (issue #17, parent #4): Garages, appartenances, Fiches,
-- Œuvres, Fiche–Œuvre links and photos.
--
-- Every private table carries its own garage_id and every relation is a
-- composite foreign key on (id, garage_id), so a link between two Garages is
-- impossible whatever the role writing the row, including the server role.
--
-- This migration is a deny-all base: RLS is enabled on every table and
-- anon/authenticated receive no grant and no policy. The only read access
-- (#18) and the business commands (#6) come in later slices.

-- Helper functions live outside the exposed schemas.
create schema private;
revoke all on schema private from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Garages
-- ---------------------------------------------------------------------------

create table public.garages (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Garage appartenances
--
-- The appartenance id is the Garage-scoped pseudonymous identity used for audit
-- columns. The Auth identity is only a link: a historical appartenance keeps its
-- id but has no Auth identity and grants no access. A removed appartenance keeps
-- its rows' audit references; deleting its Auth user detaches it.
-- ---------------------------------------------------------------------------

create table public.appartenances_garage (
  id uuid primary key default gen_random_uuid(),
  garage_id uuid not null references public.garages (id),
  auth_user_id uuid references auth.users (id) on delete set null,
  role text not null,
  state text not null,
  created_at timestamptz not null default now(),
  constraint appartenances_garage_role_valid check (role in ('owner', 'parent')),
  constraint appartenances_garage_state_valid check (
    state in ('active', 'removed', 'historical')
  ),
  constraint appartenances_garage_identity_matches_state check (
    case state
      when 'active' then auth_user_id is not null
      when 'historical' then auth_user_id is null
      else true
    end
  ),
  constraint appartenances_garage_id_garage_key unique (id, garage_id)
);

create unique index appartenances_garage_one_active_owner
  on public.appartenances_garage (garage_id)
  where role = 'owner' and state = 'active';

create unique index appartenances_garage_one_active_per_identity
  on public.appartenances_garage (garage_id, auth_user_id)
  where state = 'active';

create index appartenances_garage_auth_user_idx
  on public.appartenances_garage (auth_user_id)
  where auth_user_id is not null;

-- ---------------------------------------------------------------------------
-- Œuvres
-- ---------------------------------------------------------------------------

create table public.oeuvres (
  id uuid primary key default gen_random_uuid(),
  garage_id uuid not null references public.garages (id),
  name text not null,
  created_at timestamptz not null default now(),
  constraint oeuvres_name_not_blank check (btrim(name) <> ''),
  constraint oeuvres_id_garage_key unique (id, garage_id)
);

-- ---------------------------------------------------------------------------
-- Fiches
--
-- The active photo is declared below, once fiche_photos exists: the two tables
-- reference each other, so that foreign key is deferred to the end of the
-- transaction. A Fiche always has a photo, even as a Brouillon.
-- ---------------------------------------------------------------------------

create table public.fiches (
  id uuid primary key default gen_random_uuid(),
  garage_id uuid not null references public.garages (id),
  status text not null default 'draft',
  version integer not null default 1,
  name_fr text,
  color text,
  description text,
  number text,
  team text,
  active_photo_id uuid not null,
  created_by uuid not null,
  created_at timestamptz not null default now(),
  updated_by uuid not null,
  updated_at timestamptz not null default now(),
  published_by uuid,
  published_at timestamptz,
  archived_by uuid,
  archived_at timestamptz,
  constraint fiches_id_garage_key unique (id, garage_id),
  constraint fiches_status_valid check (
    status in ('draft', 'published', 'archived')
  ),
  constraint fiches_version_positive check (version > 0),
  constraint fiches_name_fr_not_blank check (
    name_fr is null or btrim(name_fr) <> ''
  ),
  constraint fiches_color_format check (
    color is null or color ~ '^#[0-9A-Fa-f]{6}$'
  ),
  constraint fiches_description_not_blank check (
    description is null or btrim(description) <> ''
  ),
  constraint fiches_number_not_blank check (
    number is null or btrim(number) <> ''
  ),
  constraint fiches_team_not_blank check (team is null or btrim(team) <> ''),
  -- A published or archived Fiche is complete. The thumbnail requirement spans
  -- two tables and is enforced by a constraint trigger below.
  constraint fiches_publishable_fields check (
    status = 'draft'
    or (name_fr is not null and color is not null and description is not null)
  ),
  constraint fiches_metadata_matches_status check (
    case status
      when 'draft' then
        published_by is null and published_at is null
        and archived_by is null and archived_at is null
      when 'published' then
        published_by is not null and published_at is not null
        and archived_by is null and archived_at is null
      else
        published_by is not null and published_at is not null
        and archived_by is not null and archived_at is not null
    end
  ),
  -- The last modification never precedes creation, publication or archiving.
  constraint fiches_updated_after_creation check (updated_at >= created_at),
  constraint fiches_published_after_creation check (
    published_at is null or published_at >= created_at
  ),
  constraint fiches_archived_after_publication check (
    archived_at is null or archived_at >= published_at
  ),
  constraint fiches_updated_after_events check (
    (published_at is null or updated_at >= published_at)
    and (archived_at is null or updated_at >= archived_at)
  ),
  -- Authors are appartenances of the Fiche's own Garage.
  constraint fiches_created_by_fkey foreign key (created_by, garage_id)
    references public.appartenances_garage (id, garage_id),
  constraint fiches_updated_by_fkey foreign key (updated_by, garage_id)
    references public.appartenances_garage (id, garage_id),
  constraint fiches_published_by_fkey foreign key (published_by, garage_id)
    references public.appartenances_garage (id, garage_id),
  constraint fiches_archived_by_fkey foreign key (archived_by, garage_id)
    references public.appartenances_garage (id, garage_id)
);

create index fiches_garage_status_idx on public.fiches (garage_id, status);

-- ---------------------------------------------------------------------------
-- Fiche photos
--
-- Storage paths embed the photo id, so a replacement photo gets its own path
-- and the previous one can be removed after the swap succeeds.
-- ---------------------------------------------------------------------------

create table public.fiche_photos (
  id uuid primary key default gen_random_uuid(),
  garage_id uuid not null references public.garages (id),
  fiche_id uuid not null,
  master_path text not null,
  thumbnail_path text,
  created_at timestamptz not null default now(),
  constraint fiche_photos_id_fiche_garage_key unique (id, fiche_id, garage_id),
  constraint fiche_photos_fiche_fkey foreign key (fiche_id, garage_id)
    references public.fiches (id, garage_id) on delete cascade,
  constraint fiche_photos_master_path_format check (
    master_path = garage_id::text || '/' || fiche_id::text || '/' || id::text
      || '/master.jpg'
  ),
  constraint fiche_photos_thumbnail_path_format check (
    thumbnail_path is null
    or thumbnail_path like garage_id::text || '/' || fiche_id::text || '/'
      || id::text || '/thumbnail._%'
  )
);

create index fiche_photos_fiche_idx on public.fiche_photos (fiche_id);

-- The active photo belongs to the same Fiche and the same Garage. Deferred so
-- that a Fiche and its first photo can be inserted in one transaction.
alter table public.fiches
  add constraint fiches_active_photo_fkey
  foreign key (active_photo_id, id, garage_id)
  references public.fiche_photos (id, fiche_id, garage_id)
  deferrable initially deferred;

-- A published or archived Fiche needs a thumbnail on its active photo. Checked
-- at commit from both sides: when the Fiche changes and when the photo does.
create function private.assert_fiche_has_thumbnail()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status <> 'draft' and not exists (
    select 1
    from public.fiche_photos p
    where p.id = new.active_photo_id and p.thumbnail_path is not null
  ) then
    raise exception 'Fiche % is % but its active photo has no thumbnail',
      new.id, new.status
      using errcode = '23514';
  end if;
  return null;
end;
$$;

create function private.assert_active_photo_keeps_thumbnail()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.thumbnail_path is null and exists (
    select 1
    from public.fiches f
    where f.active_photo_id = new.id and f.status <> 'draft'
  ) then
    raise exception 'Photo % is the active photo of a published or archived Fiche and needs a thumbnail',
      new.id
      using errcode = '23514';
  end if;
  return null;
end;
$$;

revoke all on function private.assert_fiche_has_thumbnail() from public;
revoke all on function private.assert_active_photo_keeps_thumbnail() from public;

create constraint trigger fiches_thumbnail_required
  after insert or update on public.fiches
  deferrable initially deferred
  for each row execute function private.assert_fiche_has_thumbnail();

create constraint trigger fiche_photos_thumbnail_kept
  after update of thumbnail_path on public.fiche_photos
  deferrable initially deferred
  for each row execute function private.assert_active_photo_keeps_thumbnail();

-- ---------------------------------------------------------------------------
-- Fiche–Œuvre links
-- ---------------------------------------------------------------------------

create table public.fiche_oeuvres (
  garage_id uuid not null references public.garages (id),
  fiche_id uuid not null,
  oeuvre_id uuid not null,
  created_at timestamptz not null default now(),
  primary key (fiche_id, oeuvre_id),
  constraint fiche_oeuvres_fiche_fkey foreign key (fiche_id, garage_id)
    references public.fiches (id, garage_id) on delete cascade,
  constraint fiche_oeuvres_oeuvre_fkey foreign key (oeuvre_id, garage_id)
    references public.oeuvres (id, garage_id)
);

create index fiche_oeuvres_oeuvre_idx on public.fiche_oeuvres (oeuvre_id);

-- ---------------------------------------------------------------------------
-- Deny-all base: RLS on, no policy, no client grant.
-- ---------------------------------------------------------------------------

alter table public.garages enable row level security;
alter table public.appartenances_garage enable row level security;
alter table public.oeuvres enable row level security;
alter table public.fiches enable row level security;
alter table public.fiche_photos enable row level security;
alter table public.fiche_oeuvres enable row level security;

-- Supabase grants new public tables to the Data API roles by default.
revoke all on table
  public.garages,
  public.appartenances_garage,
  public.oeuvres,
  public.fiches,
  public.fiche_photos,
  public.fiche_oeuvres
from anon, authenticated;
