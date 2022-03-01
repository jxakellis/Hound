module.exports = {
  env: {
    browser: true,
    commonjs: true,
    es2021: true,
  },
  extends: [
    'airbnb-base',
  ],
  parserOptions: {
    ecmaVersion: 12,
  },
  rules: {
    'max-len': ['error', { code: 9999, ignoreComments: true }],
    'brace-style': ['error', 'stroustrup', { allowSingleLine: false }],
    'no-console': 'off',
    'no-else-return': 'off',
    'no-await-in-loop': 'off',
    'no-use-before-define': 'off',
    'prefer-destructuring': 'off',
    'no-restricted-syntax': 'off',
  },
};
