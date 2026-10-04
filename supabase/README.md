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
npm run db:test    # run the pgTAP tests
npm run db:stop    # stop the stack cleanly
```

Never commit real photos, real e-mail addresses, backups or secrets. The keys printed by `supabase start` are the standard local demo keys, not secrets.
