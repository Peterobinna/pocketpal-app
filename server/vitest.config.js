import { defineConfig } from "vitest/config";

/**
 * Backend-specific Vitest configuration.
 *
 * The repository also contains a frontend Vitest configuration at the
 * project root. This file ensures backend tests use their own test pattern
 * instead of inheriting the frontend configuration, which excludes server/.
 */
export default defineConfig({
  test: {
    environment: "node",
    include: ["tests/**/*.test.js"],
    exclude: ["node_modules/**"],
    clearMocks: true,
    restoreMocks: true,
  },
});
