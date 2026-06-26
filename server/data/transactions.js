// ===============================================
// Temporary Transaction Data
// ===============================================
//
// For now, we are storing transactions in memory.
// Later, this file can be replaced with MongoDB.
//
// Each transaction contains:
//
// id
// type
// amount
// category
// description
// date
//
// ===============================================

export const transactions = [
  {
    id: 1,
    type: "expense",
    amount: 2500,
    category: "Food",
    description: "Lunch on campus",
    date: "2026-06-25",
  },

  {
    id: 2,
    type: "income",
    amount: 20000,
    category: "Allowance",
    description: "Weekly allowance",
    date: "2026-06-24",
  },
];