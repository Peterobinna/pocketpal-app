// This file stores our savings goals temporarily.
// For now, we are using an array instead of a database.
// Later, this can be replaced with MongoDB, PostgreSQL, or another database.

export const goals = [
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
