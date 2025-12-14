import { calculate } from '../src/index.js';

describe('calculate', () => {
  test('should add two positive numbers', () => {
    expect(calculate(2, 3)).toBe(5);
  });

  test('should add negative numbers', () => {
    expect(calculate(-2, -3)).toBe(-5);
  });

  test('should add positive and negative numbers', () => {
    expect(calculate(5, -3)).toBe(2);
  });
});
