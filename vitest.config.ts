import { defineConfig } from "vitest/config";

// This config tells Vitest at the root level to only run frontend tests.
// Without this, Vitest may also find backend tests inside the server folder.
export default defineConfig({
  test: {
    include: ["src/**/*.test.ts", "src/**/*.test.tsx"],
    exclude: ["server/**", "node_modules/**", "dist/**"],
  },
});
