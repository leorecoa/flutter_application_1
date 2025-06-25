module.exports = {
  testEnvironment: 'node',
  collectCoverageFrom: [
    'lambda/**/*.js',
    '!lambda/**/node_modules/**',
    '!lambda/**/coverage/**'
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  testMatch: [
    '**/__tests__/**/*.js',
    '**/?(*.)+(spec|test).js'
  ],
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  testTimeout: 10000,
  verbose: true
};