import { defineConfig } from 'eslint/config'
import json from '@eslint/json'

export default defineConfig([
  {
    plugins: { json },
  },

  {
    files: ['**/*.json'],
    language: 'json/json',
    rules: {
      'json/no-duplicate-keys': 'error',
    },
  },

  {
    files: ['**/*.jsonc',
      '**/tsconfig*.json',
      '.vscode/*.json'],
    language: 'json/jsonc',
    rules: {
      'json/no-duplicate-keys': 'error',
    },
  },

  {
    files: ['**/*.json5'],
    language: 'json/json5',
    rules: {
      'json/no-duplicate-keys': 'error',
    },
  },
])
