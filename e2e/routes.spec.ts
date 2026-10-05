import { expect, test } from '@playwright/test';

test('direct load of the Vitrine at /', async ({ page }) => {
  await page.goto('/');
  await expect(
    page.getByRole('heading', { name: 'Mon Garage de Miniatures' }),
  ).toBeVisible();
  await expect(
    page.getByText('sans affiliation avec Disney/Pixar'),
  ).toBeVisible();
  await expect(page.getByRole('listitem')).toHaveCount(8);
});

test('the Vitrine has no horizontal overflow at 320 px', async ({ page }) => {
  await page.setViewportSize({ width: 320, height: 640 });
  await page.goto('/');
  await expect(page.getByRole('listitem')).toHaveCount(8);
  const overflow = await page.evaluate(
    () =>
      document.documentElement.scrollWidth -
      document.documentElement.clientWidth,
  );
  expect(overflow).toBeLessThanOrEqual(0);
});

test('the Vitrine CTA is at least 48 px and reachable by keyboard', async ({
  page,
}) => {
  await page.goto('/');
  const cta = page.getByRole('link', { name: 'Aller au Garage' });
  const box = await cta.boundingBox();
  expect(box?.width).toBeGreaterThanOrEqual(48);
  expect(box?.height).toBeGreaterThanOrEqual(48);
  await cta.focus();
  await page.keyboard.press('Enter');
  await expect(page).toHaveURL(/\/garage$/);
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
