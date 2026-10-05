import { expect, test } from '@playwright/test';
import { collectForeignRequests, isForeign } from './foreignRequests';

test('the Vitrine is served at / with its eight Fiches', async ({
  page,
  baseURL,
}) => {
  const foreign = collectForeignRequests(page, new URL(baseURL ?? '').origin);

  await page.goto('/');
  await expect(
    page.getByRole('heading', { level: 1, name: 'Mon Garage de Miniatures' }),
  ).toBeVisible();
  await expect(
    page.getByText('sans affiliation avec Disney/Pixar'),
  ).toBeVisible();
  const cards = page.getByRole('listitem');
  await expect(cards).toHaveCount(8);

  // Lazy images only load once scrolled into view: walk the page so that
  // any deferred third-party resource is requested before we assert.
  for (const card of await cards.all()) await card.scrollIntoViewIfNeeded();
  await page.waitForLoadState('networkidle');
  expect(foreign).toEqual([]);
});

test('the foreign-request listener reports a request to another origin', async ({
  page,
  baseURL,
}) => {
  const foreign = collectForeignRequests(page, new URL(baseURL ?? '').origin);
  // A fixed external origin, intercepted so nothing leaves the browser: it is
  // foreign for any target (host name, IPv4 or IPv6, with or without port).
  // Look-alike hosts are covered by the isForeign test below.
  const external = 'https://tracker.invalid/pixel';
  await page.route(external, (route) => route.fulfill({ body: '' }));

  await page.goto('/');
  await page.evaluate(
    (url) => fetch(url, { mode: 'no-cors' }).catch(() => undefined),
    external,
  );

  expect(foreign).toEqual([external]);
});

test('isForeign compares exact origins', () => {
  const origin = 'https://mon-garage-cars.pages.dev';
  expect(isForeign(`${origin}/assets/a.jpg`, origin)).toBe(false);
  expect(isForeign('data:image/png;base64,AAAA', origin)).toBe(false);
  expect(isForeign(`${origin}.evil.example/pixel`, origin)).toBe(true);
  expect(isForeign('https://fonts.googleapis.com/css', origin)).toBe(true);
  expect(isForeign('http://mon-garage-cars.pages.dev/', origin)).toBe(true);
  expect(isForeign('http://localhost:4174/a', 'http://localhost:4174')).toBe(
    false,
  );
  expect(isForeign('http://localhost:4175/a', 'http://localhost:4174')).toBe(
    true,
  );
  expect(isForeign('http://[::1]:4175/a', 'http://[::1]:4175')).toBe(false);
  expect(isForeign('http://[::1]:4176/a', 'http://[::1]:4175')).toBe(true);
});

test('the CTA leads to the neutral Garage shell', async ({ page, baseURL }) => {
  await page.goto('/');
  await page.getByRole('link', { name: 'Aller au Garage' }).click();
  await expect(page).toHaveURL(/\/garage$/);
  const url = new URL(page.url());
  expect(url.origin).toBe(new URL(baseURL ?? '').origin);
  expect(url.pathname).toBe('/garage');
  await expect(page.getByRole('heading', { name: 'Garage' })).toBeVisible();
});

test('direct load of /garage serves the Garage shell', async ({ page }) => {
  await page.goto('/garage');
  await expect(page.getByRole('heading', { name: 'Garage' })).toBeVisible();
});
