import { describe, it, expect, beforeEach, vi } from "vitest";
import { readFileSync } from "fs";
import { resolve } from "path";

const frontendDir = resolve(__dirname, "..", "frontend");

const loadHTML = (filename) => {
  const html = readFileSync(resolve(frontendDir, filename), "utf-8");
  document.documentElement.innerHTML = "";
  document.write(html);
  document.close();
};

describe("Page load smoke tests", () => {
  const pages = [
    "index.html",
    "gallery.html",
    "register.html",
    "cart.html",
    "checkout.html",
    "orders.html",
    "profile.html",
    "dashboard.html",
    "community.html",
    "centers.html",
    "grow-with-us.html",
    "privacy.html",
    "terms.html",
    "seller-agreement.html",
    "offline.html",
  ];

  it.each(pages)("%s loads without errors", (page) => {
    expect(() => loadHTML(page)).not.toThrow();
    expect(document.querySelector("title")).not.toBeNull();
    expect(document.title).toContain("GardenMarket");
  });
});

describe("PWA meta tags", () => {
  const pwaPages = [
    "index.html",
    "gallery.html",
    "register.html",
    "cart.html",
    "checkout.html",
    "orders.html",
    "profile.html",
    "dashboard.html",
    "community.html",
    "centers.html",
    "grow-with-us.html",
    "privacy.html",
    "terms.html",
    "seller-agreement.html",
  ];

  it.each(pwaPages)("%s has theme-color meta", (page) => {
    loadHTML(page);
    const meta = document.querySelector('meta[name="theme-color"]');
    expect(meta).not.toBeNull();
    expect(meta.getAttribute("content")).toBe("#2d6f65");
  });

  it.each(pwaPages)("%s has manifest link", (page) => {
    loadHTML(page);
    const link = document.querySelector('link[rel="manifest"]');
    expect(link).not.toBeNull();
    expect(link.getAttribute("href")).toBe("manifest.json");
  });

  it.each(pwaPages)("%s has apple-touch-icon", (page) => {
    loadHTML(page);
    const link = document.querySelector('link[rel="apple-touch-icon"]');
    expect(link).not.toBeNull();
  });
});

describe("Accessibility basics", () => {
  it("index.html has nav with aria-label", () => {
    loadHTML("index.html");
    const nav = document.querySelector("nav.nav-links");
    expect(nav).not.toBeNull();
    expect(nav.getAttribute("aria-label")).toBe("Main navigation");
  });

  it("index.html footer uses nav with aria-label", () => {
    loadHTML("index.html");
    const footerNav = document.querySelector("nav.footer-links");
    expect(footerNav).not.toBeNull();
    expect(footerNav.getAttribute("aria-label")).toBe("Legal links");
  });

  it("gallery.html carousel has ARIA attributes", () => {
    loadHTML("gallery.html");
    const carousel = document.querySelector(".carousel");
    expect(carousel.getAttribute("role")).toBe("region");
    expect(carousel.getAttribute("aria-roledescription")).toBe("carousel");

    const prev = document.getElementById("prev-item");
    expect(prev.getAttribute("aria-label")).toBe("Previous item");

    const next = document.getElementById("next-item");
    expect(next.getAttribute("aria-label")).toBe("Next item");

    const label = document.getElementById("carousel-label");
    expect(label.getAttribute("aria-live")).toBe("polite");
  });

  it("register.html forms have aria-label", () => {
    loadHTML("register.html");
    const regForm = document.getElementById("register-form");
    expect(regForm.getAttribute("aria-label")).toBe("Registration form");

    const loginForm = document.getElementById("login-form");
    expect(loginForm.getAttribute("aria-label")).toBe("Sign in form");
  });
});

describe("Manifest file", () => {
  it("manifest.json is valid and has required fields", () => {
    const manifest = JSON.parse(
      readFileSync(resolve(frontendDir, "manifest.json"), "utf-8")
    );
    expect(manifest.name).toBe("GardenMarket");
    expect(manifest.short_name).toBeTruthy();
    expect(manifest.start_url).toBeTruthy();
    expect(manifest.display).toBe("standalone");
    expect(manifest.theme_color).toBe("#2d6f65");
    expect(manifest.icons.length).toBeGreaterThanOrEqual(3);
  });
});

describe("Service worker", () => {
  it("service-worker.js contains offline fallback URL", () => {
    const sw = readFileSync(resolve(frontendDir, "service-worker.js"), "utf-8");
    expect(sw).toContain("offline.html");
    expect(sw).toContain("CACHE_VERSION");
    expect(sw).toContain("skipWaiting");
    expect(sw).toContain("clients.claim");
  });
});

describe("Form submission prevention", () => {
  beforeEach(() => {
    vi.stubGlobal("fetch", vi.fn(() => Promise.resolve({ ok: true, json: () => Promise.resolve({}) })));
    vi.stubGlobal("localStorage", {
      getItem: vi.fn(),
      setItem: vi.fn(),
      removeItem: vi.fn(),
    });
  });

  it("register form has required fields", () => {
    loadHTML("register.html");
    const form = document.getElementById("register-form");
    const emailInput = form.querySelector('input[type="email"]');
    const passwordInput = form.querySelector('input[type="password"]');

    expect(emailInput.hasAttribute("required")).toBe(true);
    expect(passwordInput.hasAttribute("required")).toBe(true);
    expect(passwordInput.getAttribute("minlength")).toBe("8");
  });

  it("checkout form has required fields", () => {
    loadHTML("checkout.html");
    const form = document.getElementById("checkout-form");
    const center = form.querySelector("#center-select");
    const date = form.querySelector('input[name="pickup_date"]');

    expect(center.hasAttribute("required")).toBe(true);
    expect(date.hasAttribute("required")).toBe(true);
  });
});
