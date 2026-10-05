import { defineConfig, devices } from '@playwright/test';

// Read-only post-merge smoke tests against a deployed URL (see scripts/smoke.mjs).
const baseURL = process.env.SMOKE_URL;
if (!baseURL) {
  throw new Error('SMOKE_URL is required: run `npm run smoke`.');
}

export default defineConfig({
  testDir: 'e2e/smoke',
  retries: 0,
  reporter: 'list',
  use: { baseURL, trace: 'retain-on-failure' },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],
});
