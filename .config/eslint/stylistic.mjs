import stylistic from '@stylistic/eslint-plugin'

export default [
  {
    // Scope stylistic rules to JS/TS files only
    files: ['**/*.{js,mjs,cjs,ts,mts,cts}'],
    plugins: {
      '@stylistic': stylistic,
    },
    // Merge the recommended config and override specific rules
    rules: {
      ...stylistic.configs.recommended.rules,
      'no-irregular-whitespace': 'off',
      '@stylistic/array-element-newline': ['error', 'consistent'],
    },
  },
]
