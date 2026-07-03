import { describe, expect, it } from "vitest";
import { calculateProgress } from "./calculateProgress";

// This test file checks the savings progress calculation logic.
// It helps CI confirm that our core financial calculation still works.

describe("calculateProgress", () => {
  it("returns 50 when saved amount is 50 and target amount is 100", () => {
    const result = calculateProgress(50, 100);

    expect(result).toBe(50);
  });

  it("does not return more than 100 when saved amount is higher than target amount", () => {
    const result = calculateProgress(120, 100);

    expect(result).toBe(100);
  });

  it("returns 0 when target amount is 0", () => {
    const result = calculateProgress(50, 0);

    expect(result).toBe(0);
  });
});