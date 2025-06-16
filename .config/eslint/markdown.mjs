import markdown from '@eslint/markdown'

export default [
  {
    files: ['**/*.md'],
    plugins: {
      markdown,
    },
    language: 'markdown/gfm',
    languageOptions: {
      frontmatter: 'yaml',
    },
    rules: {
      'no-irregular-whitespace': 'off',
    },
  },
]
