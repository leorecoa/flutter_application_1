module.exports = {
  env: {
    node: true,
    es2021: true,
    jest: true
  },
  extends: [
    'eslint:recommended'
  ],
  parserOptions: {
    ecmaVersion: 12,
    sourceType: 'module'
  },
  rules: {
    'indent': ['error', 2],
    'linebreak-style': ['error', 'unix'],
    'quotes': ['error', 'single'],
    'semi': ['error', 'always'],
    'no-unused-vars': ['error', { 'argsIgnorePattern': '^_' }],
    'no-console': 'off',
    'prefer-const': 'error',
    'no-var': 'error',
    'object-shorthand': 'error',
    'prefer-arrow-callback': 'error',
    'arrow-spacing': 'error',
    'no-duplicate-imports': 'error',
    'no-useless-return': 'error',
    'consistent-return': 'error',
    'no-magic-numbers': ['warn', { 'ignore': [0, 1, -1, 200, 400, 401, 403, 404, 500] }],
    'max-len': ['error', { 'code': 120 }],
    'complexity': ['warn', 10]
  },
  overrides: [
    {
      files: ['**/*.test.js', '**/*.spec.js'],
      rules: {
        'no-magic-numbers': 'off'
      }
    }
  ]
};