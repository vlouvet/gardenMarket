import { defineConfig, devices } from "@playwright/test";

// Tests target the running nginx service. Set BASE_URL when running from
// outside the compose network (e.g. PLAYWRIGHT_BASE_URL=http://localhost:8881).
const baseURL = process.env.PLAYWRIGHT_BASE_URL || "http://nginx:80";

export default defineConfig({
  testDir: "./tests/e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 2 : undefined,
  reporter: [["list"]],
  use: {
    baseURL,
    trace: "retain-on-failure",
    screenshot: "only-on-failure",
    actionTimeout: 5_000,
    navigationTimeout: 10_000,
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
  ],
});
