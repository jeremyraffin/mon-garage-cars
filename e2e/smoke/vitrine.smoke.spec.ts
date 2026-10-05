import { expect, test } from '@playwright/test';
import { collectForeignRequests } from './foreignRequests';

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

test('the foreign-request guard flags a look-alike origin', async ({
  page,
  baseURL,
}) => {
  const origin = new URL(baseURL ?? '').origin;
  const foreign = collectForeignRequests(page, origin);
  const lookalike = `${origin}.evil.example/pixel`;
  await page.route(lookalike, (route) => route.fulfill({ body: '' }));

  await page.goto('/');
  await page.evaluate(
    (url) => fetch(url, { mode: 'no-cors' }).catch(() => undefined),
    lookalike,
  );

  expect(foreign).toEqual([lookalike]);
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
