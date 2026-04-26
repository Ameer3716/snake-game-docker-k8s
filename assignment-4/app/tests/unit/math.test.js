const { multiply, divide } = require('../../server');

describe('Unit Tests - Math Functions', () => {
 test('multiply: 3 * 4 = 12', () => {
    expect(multiply(3, 4)).toBe(12);  // intentionally wrong
});
  test('multiply: negative numbers', () => {
    expect(multiply(-2, 5)).toBe(-10);
  });
  test('multiply: zero', () => {
    expect(multiply(0, 100)).toBe(0);
  });
  test('divide: 10 / 2 = 5', () => {
    expect(divide(10, 2)).toBe(5);
  });
  test('divide: by zero throws', () => {
    expect(() => divide(5, 0)).toThrow('Division by zero');
  });
});