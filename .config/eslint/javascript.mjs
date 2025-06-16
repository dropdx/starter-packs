import tseslint, { configs } from 'typescript-eslint'
import js from '@eslint/js'
import importPlugin from 'eslint-plugin-import'

export default tseslint.config(js.configs.recommended, configs.recommended, {
  files: ['**/*.{js,mjs,cjs,ts,mts,cts}'],
  extends: [importPlugin.flatConfigs.recommended, importPlugin.flatConfigs.typescript],
  settings: {
    'import/resolver': {
      typescript: true,
      node: true,
    },
  },
  rules: {
    'import/consistent-type-specifier-style': ['error', 'prefer-top-level'],
    'import/no-duplicates': 'error',
    '@typescript-eslint/no-import-type-side-effects': 'error',
  },
})
