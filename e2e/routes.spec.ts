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
  browserName,
}) => {
  await page.goto('/');
  const cta = page.getByRole('link', { name: 'Aller au Garage' });
  const box = await cta.boundingBox();
  expect(box?.width).toBeGreaterThanOrEqual(48);
  expect(box?.height).toBeGreaterThanOrEqual(48);
  // WebKit on macOS skips links on Tab by default (Option+Tab reaches them).
  const tabKey =
    browserName === 'webkit' && process.platform === 'darwin'
      ? 'Alt+Tab'
      : 'Tab';
  await page.keyboard.press(tabKey);
  await expect(cta).toBeFocused();
  const outline = await cta.evaluate((el) => {
    const style = getComputedStyle(el);
    return {
      style: style.outlineStyle,
      width: parseFloat(style.outlineWidth),
    };
  });
  expect(outline.style).not.toBe('none');
  expect(outline.width).toBeGreaterThanOrEqual(2);
  await page.keyboard.press('Enter');
  await expect(page).toHaveURL(/\/garage$/);
});

test('photos fully below the first screen are lazy-loaded', async ({
  page,
}) => {
  await page.setViewportSize({ width: 320, height: 568 });
  await page.goto('/');
  await expect(page.getByRole('listitem')).toHaveCount(8);
  const photos = await page.getByRole('img').evaluateAll((images) =>
    images.map((image) => ({
      top: image.getBoundingClientRect().top,
      loading: image.getAttribute('loading'),
    })),
  );
  expect(photos).toHaveLength(8);
  const offscreen = photos.filter((photo) => photo.top >= 568);
  expect(offscreen.length).toBeGreaterThan(0);
  for (const photo of offscreen) expect(photo.loading).toBe('lazy');
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
