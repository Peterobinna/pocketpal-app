import type { SavingsGoal } from "../types";

export const mockGoals: SavingsGoal[] = [
  {
    id: 1,
    name: "Laptop Fund",
    targetAmount: 500000,
    savedAmount: 150000,
    category: "Education",
  },
  {
    id: 2,
    name: "Emergency Savings",
    targetAmount: 200000,
    savedAmount: 50000,
    category: "Personal",
  },
];