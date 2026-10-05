import type { Page } from '@playwright/test';

const LOCAL_SCHEMES = new Set(['data:', 'blob:', 'about:']);

// Compares the exact origin: a look-alike host such as
// https://example.pages.dev.evil.example must not pass as same-origin.
export function isForeign(requestUrl: string, origin: string): boolean {
  const url = new URL(requestUrl);
  return !LOCAL_SCHEMES.has(url.protocol) && url.origin !== origin;
}

export function collectForeignRequests(page: Page, origin: string): string[] {
  const foreign: string[] = [];
  page.on('request', (request) => {
    if (isForeign(request.url(), origin)) foreign.push(request.url());
  });
  return foreign;
}
