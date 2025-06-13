import js from '@eslint/js';
import markdown from '@eslint/markdown';
import eslintConfigPrettierFlat from 'eslint-config-prettier/flat';
import importPlugin from 'eslint-plugin-import';
import eslintPluginPrettierRecommended from 'eslint-plugin-prettier/recommended';
import { defineConfig } from 'eslint/config';
import globals from 'globals';
import { configs as tselintConfigs } from 'typescript-eslint';
import tsParser from '@typescript-eslint/parser';
import json from '@eslint/json';

const commonFormattingRules = {
  'array-bracket-newline': ['error', { multiline: true, minItems: 1 }],
  'object-curly-newline': [
    'error',
    {
      ObjectExpression: { multiline: true, minProperties: 1 },
      ObjectPattern: { multiline: true, minProperties: 1 },
      ImportDeclaration: { multiline: true, minProperties: 3 },
      ExportDeclaration: { multiline: true, minProperties: 3 },
    },
  ],
  'array-element-newline': ['error', { multiline: true, minItems: 3 }],
};

export default defineConfig([
  {
    // Global ignores, apply to all files
    ignores: [
      '**/node_modules/**',
      '**/dist/**',
      '**/package-lock.json',
      '**/package.json',
      'pnpm-lock.yaml',
    ],
  },

  {
    files: ['eslint.config.mjs'],
    rules: {
      'import/no-unresolved': 'off',
    },
  },

  // javascript and typescript
  js.configs.recommended,
  ...tselintConfigs.recommended,
  importPlugin.flatConfigs.recommended,
  importPlugin.flatConfigs.typescript,
  {
    files: ['**/*.{js,mjs,cjs,ts,mts,cts}'],
    languageOptions: {
      parser: tsParser,
      globals: { ...globals.node, ...globals.browser },
      sourceType: 'module',
    },
    rules: {
      ...commonFormattingRules,
    },
    settings: {
      'import/resolver': {
        typescript: true,
        node: true,
      },
    },
  },

  // markdown
  {
    files: ['**/*.md'],
    plugins: {
      markdown,
    },
    language: 'markdown/gfm',
    languageOptions: {
      frontmatter: 'yaml',
    },
  },

  // lint JSON files
  {
    files: ['**/*.json'],
    language: 'json/json',
    ...json.configs.recommended,
  },

  // lint JSONC files
  {
    files: ['**/*.jsonc', '.vscode/*.json', '**/tsconfig*.json'],
    language: 'json/jsonc',
    ...json.configs.recommended,
  },

  // lint JSON5 files
  {
    files: ['**/*.json5'],
    language: 'json/json5',
    ...json.configs.recommended,
  },

  // Disabling 'no-irregular-whitespace' rule
  {
    files: ['**/*.jsonc', '.vscode/*.json', '**/tsconfig*.json', 'cspell.json'],
    rules: {
      'no-irregular-whitespace': 'off',
    },
  },

  // prettier fixes
  eslintConfigPrettierFlat,
  eslintPluginPrettierRecommended,
]);
