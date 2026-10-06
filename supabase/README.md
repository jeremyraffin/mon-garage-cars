# Supabase local

Versioned backend of the project (see ADR 0002, 0003 and 0005). The local stack never contacts production: this repository is not linked to any remote Supabase project.

## Layout

- `config.toml`: local stack configuration
- `migrations/`: versioned schema changes
- `seed.sql`: fictitious local data only
- `functions/`: Edge Functions (application commands)
- `tests/database/`: pgTAP tests

## Commands

Docker Desktop must be running.

```bash
npm run db:start   # start the local stack (first run pulls images)
npm run db:test    # reset the local database, then run the pgTAP tests
npm run db:stop    # stop the stack cleanly
```

Never commit real photos, real e-mail addresses, backups or secrets. The keys printed by `supabase start` are the standard local demo keys, not secrets.

## Data model

`migrations/20261006090000_garage_data_model.sql` creates the multi-Garage model: `garages`, `appartenances_garage`, `oeuvres`, `fiches`, `fiche_photos` and `fiche_oeuvres`. Garage-scoped relationships use composite foreign keys on `(id, garage_id)`, so no row can link two Garages. RLS is enabled on every table. `seed.sql` holds the fictitious fixtures the pgTAP tests rely on; `npm run db:test` resets the local database first, and `npx supabase db reset` does the same by hand after changing a migration or the seed.

## Read matrix and photo bucket

`migrations/20261006100000_rls_read_matrix.sql` (#18) opens `SELECT` only, to `authenticated` only, on `appartenances_garage`, `oeuvres`, `fiches`, `fiche_photos` and `fiche_oeuvres`; `garages` stays closed. Rights derive from the active row of `appartenances_garage`, never from the JWT: an active Parent reads their Garage and their own appartenance, the active Propriétaire also reads every appartenance of their Garage. Nobody else reads anything, and the Session d'appareil stays refused until #7.

Policies call two argument-less helpers, `private.my_garage_ids()` and `private.my_owned_garage_ids()` (`SECURITY DEFINER`, empty `search_path`). They are the only functions a client role can execute, and they only return the caller's own Garages. The private schema is not exposed by the Data API.

The `fiche-photos` bucket is private; objects live under `<garage_id>/…` and the first path segment bounds the read. No client mutation of tables or objects exists: `INSERT`, `UPDATE`, `DELETE` and `TRUNCATE` are not granted on tables, and restrictive policies refuse them on `storage.objects` (whose default grants belong to `supabase_storage_admin` and cannot be revoked from a migration). Uploads come with the business commands of #6 under the service role.

`tests/database/05_client_deny_all.test.sql` fails if a table of `public` lacks RLS or is granted to a client, if a policy or an executable function is added, or if a grant is widened.
