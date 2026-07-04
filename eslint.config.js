// ESLint configuration for PocketPal.
// This checks both frontend TypeScript/React files and backend JavaScript files.

import js from "@eslint/js";
import globals from "globals";
import tseslint from "typescript-eslint";
import reactHooks from "eslint-plugin-react-hooks";
import reactRefresh from "eslint-plugin-react-refresh";

export default tseslint.config(
  // Files/folders ESLint should ignore
  {
    ignores: [
      "dist",
      "node_modules",
      "server/node_modules",
      "coverage",
      "*.config.js",
    ],
  },

  // Base JavaScript recommended rules
  js.configs.recommended,

  // TypeScript recommended rules
  ...tseslint.configs.recommended,

  // Frontend React/TypeScript rules
  {
    files: ["src/**/*.{ts,tsx}"],

    languageOptions: {
      ecmaVersion: 2020,
      globals: globals.browser,
    },

    plugins: {
      "react-hooks": reactHooks,
      "react-refresh": reactRefresh,
    },

    rules: {
      ...reactHooks.configs.recommended.rules,

      // Warn if components are not exported properly for Vite fast refresh
      "react-refresh/only-export-components": [
        "warn",
        { allowConstantExport: true },
      ],
    },
  },

  // Backend Node.js rules
  {
    files: ["server/**/*.js"],

    languageOptions: {
      ecmaVersion: 2020,
      globals: globals.node,
    },

    rules: {
      // Allow console.log in backend because we use it to show server status
      "no-console": "off",
    },
  }
);