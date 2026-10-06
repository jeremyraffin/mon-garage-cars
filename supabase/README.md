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

`migrations/20261006090000_garage_data_model.sql` creates the multi-Garage model: `garages`, `garage_memberships`, `oeuvres`, `fiches`, `fiche_photos` and `fiche_oeuvres`. Every relation is a composite key on `(id, garage_id)`, so no row can link two Garages. Tables are deny-all: RLS is enabled and `anon`/`authenticated` hold no grant and no policy until the read policies of #18. `seed.sql` holds the fictitious fixtures the pgTAP tests rely on; `npm run db:test` resets the local database first, and `npx supabase db reset` does the same by hand after changing a migration or the seed.
