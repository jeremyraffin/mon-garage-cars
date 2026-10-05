// Post-merge smoke test: read-only checks of a deployed URL (default: production).
// Usage: npm run smoke [-- <url>]
import { spawnSync } from 'node:child_process';

const PRODUCTION_URL = 'https://mon-garage-cars.pages.dev/';
const url = process.argv[2] ?? PRODUCTION_URL;

try {
  new URL(url);
} catch {
  console.error(`Invalid URL: ${url}`);
  process.exit(1);
}

console.log(`Smoke test against ${url}`);
const result = spawnSync(
  'npx',
  ['playwright', 'test', '-c', 'playwright.smoke.config.ts'],
  { stdio: 'inherit', env: { ...process.env, SMOKE_URL: url } },
);
process.exit(result.status ?? 1);
