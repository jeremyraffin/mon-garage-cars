import { expect, test } from '@playwright/test';

test('the Vitrine is served at / with its eight Fiches', async ({
  page,
  baseURL,
}) => {
  const origin = new URL(baseURL ?? '').origin;
  const foreignRequests: string[] = [];
  page.on('request', (request) => {
    if (!request.url().startsWith(origin)) {
      foreignRequests.push(request.url());
    }
  });

  await page.goto('/');
  await expect(
    page.getByRole('heading', { level: 1, name: 'Mon Garage de Miniatures' }),
  ).toBeVisible();
  await expect(
    page.getByText('sans affiliation avec Disney/Pixar'),
  ).toBeVisible();
  await expect(page.getByRole('listitem')).toHaveCount(8);
  expect(foreignRequests).toEqual([]);
});

test('the CTA leads to the neutral Garage shell', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('link', { name: 'Aller au Garage' }).click();
  await expect(page).toHaveURL(/\/garage$/);
  await expect(page.getByRole('heading', { name: 'Garage' })).toBeVisible();
});

test('direct load of /garage serves the Garage shell', async ({ page }) => {
  await page.goto('/garage');
  await expect(page.getByRole('heading', { name: 'Garage' })).toBeVisible();
});
