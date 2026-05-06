import { defineConfig } from "vite";
import { resolve } from "node:path";
import { readdirSync } from "node:fs";

const root = resolve(import.meta.dirname);

// MPA: every .html file at the project root is a build entry.
const htmlEntries = Object.fromEntries(
  readdirSync(root)
    .filter((f) => f.endsWith(".html"))
    .map((f) => [f.replace(/\.html$/, ""), resolve(root, f)])
);

export default defineConfig({
  root,
  publicDir: "public",
  build: {
    outDir: "dist",
    emptyOutDir: true,
    rollupOptions: {
      input: htmlEntries,
    },
    target: "es2022",
    sourcemap: false,
    cssCodeSplit: true,
  },
  server: {
    host: "0.0.0.0",
    port: 5173,
    strictPort: true,
    proxy: {
      "/api": "http://web:8000",
      "/admin": "http://web:8000",
    },
  },
});
