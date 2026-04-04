import { defineConfig } from "vite";
import { resolve } from "path";
import { readdirSync } from "fs";

// Auto-discover all HTML entry points in frontend/
const frontendDir = resolve(__dirname, "frontend");
const htmlFiles = readdirSync(frontendDir).filter((f) => f.endsWith(".html"));
const input = Object.fromEntries(
  htmlFiles.map((f) => [f.replace(".html", ""), resolve(frontendDir, f)])
);

export default defineConfig({
  root: "frontend",
  build: {
    outDir: resolve(__dirname, "dist"),
    emptyOutDir: true,
    rollupOptions: {
      input,
    },
  },
  test: {
    environment: "jsdom",
    include: ["tests/**/*.test.js"],
    root: __dirname,
  },
});
