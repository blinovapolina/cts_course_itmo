import { calculate } from "../src/index.js"

describe("calculate", () => {
  test("Тест сложения положительных чисел", () => {
    expect(calculate(2, 3)).toBe(5)
  })

  test("Тест сложения отрицательных чисел", () => {
    expect(calculate(-2, -3)).toBe(-5)
  })

  test("Тест сложения положительных и отрицательных чисел", () => {
    expect(calculate(5, -3)).toBe(2)
  })
})
