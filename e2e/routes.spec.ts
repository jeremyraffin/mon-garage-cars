import { expect, test } from '@playwright/test';

test('direct load of the Vitrine at /', async ({ page }) => {
  await page.goto('/');
  await expect(
    page.getByRole('heading', { name: 'Mon Garage de Miniatures' }),
  ).toBeVisible();
});

test('direct load of the Garage shell at /garage', async ({ page }) => {
  await page.goto('/garage');
  await expect(page.getByRole('heading', { name: 'Garage' })).toBeVisible();
});

test('the Vitrine links to the Garage', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('link', { name: 'Aller au Garage' }).click();
  await expect(page).toHaveURL(/\/garage$/);
});
