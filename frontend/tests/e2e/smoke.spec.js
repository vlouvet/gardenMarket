import { expect, test } from "@playwright/test";

test.describe("page-load smoke", () => {
  test("home page renders hero and metrics", async ({ page }) => {
    await page.goto("/index.html");
    await expect(page).toHaveTitle(/GardenMarket/);
    await expect(page.locator("h1")).toContainText("Bring the greenhouse");
    await expect(page.locator("#metric-listings")).toBeVisible();
  });

  test("gallery page renders carousel scaffolding", async ({ page }) => {
    await page.goto("/gallery.html");
    await expect(page.locator("section.carousel")).toBeVisible();
    await expect(page.locator('section.carousel[role="region"]')).toHaveCount(1);
    await expect(page.getByRole("button", { name: /Previous listing/i })).toBeVisible();
    await expect(page.getByRole("button", { name: /Next listing/i })).toBeVisible();
  });

  test("register page exposes both forms", async ({ page }) => {
    await page.goto("/register.html");
    await expect(page.locator("#register-form")).toBeVisible();
    await expect(page.locator("#login-form")).toBeVisible();
    await expect(page.locator('#register-form button[type="submit"]')).toContainText("Create account");
  });

  test("offline page renders fallback content", async ({ page }) => {
    await page.goto("/offline.html");
    await expect(page.locator("h1")).toContainText("offline");
    await expect(page.getByRole("button", { name: /Try again/i })).toBeVisible();
  });

  test("manifest is reachable and well-formed", async ({ request }) => {
    const response = await request.get("/manifest.json");
    expect(response.status()).toBe(200);
    const manifest = await response.json();
    expect(manifest.name).toBe("GardenMarket");
    expect(manifest.icons.length).toBeGreaterThanOrEqual(2);
    expect(manifest.theme_color).toBeDefined();
  });

  test("service worker is reachable and registers fields", async ({ request }) => {
    const response = await request.get("/service-worker.js");
    expect(response.status()).toBe(200);
    const body = await response.text();
    expect(body).toContain("OFFLINE_URL");
    expect(body).toContain("CACHE_NAME");
  });

  test("register form rejects empty submit (HTML validation)", async ({ page }) => {
    await page.goto("/register.html");
    const form = page.locator("#register-form");
    await form.locator('button[type="submit"]').click();
    // The form should still be visible (no navigation happened).
    await expect(form).toBeVisible();
    // Email input is required and should report invalid.
    const emailInput = form.locator('input[name="email"]');
    const isValid = await emailInput.evaluate((el) => el.checkValidity());
    expect(isValid).toBe(false);
  });
});
