// This file handles communication between the frontend and backend.

// Backend URLs
const GOALS_URL = "http://localhost:5000/api/goals";
const TRANSACTIONS_URL = "http://localhost:5000/api/transactions";

/**
 * Fetch all savings goals from the backend.
 */
export async function getGoals() {
  const response = await fetch(GOALS_URL);

  if (!response.ok) {
    throw new Error("Failed to fetch goals.");
  }

  return response.json();
}

/**
 * Send a new savings goal to the backend.
 */
export async function createGoal(goal: unknown) {
  const response = await fetch(GOALS_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(goal),
  });

  if (!response.ok) {
    throw new Error("Failed to create goal.");
  }

  return response.json();
}

/**
 * Fetch all transactions from the backend.
 */
export async function getTransactions() {
  const response = await fetch(TRANSACTIONS_URL);

  if (!response.ok) {
    throw new Error("Failed to fetch transactions.");
  }

  return response.json();
}

/**
 * Send a new transaction to the backend.
 */
export async function createTransaction(transaction: unknown) {
  const response = await fetch(TRANSACTIONS_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(transaction),
  });

  if (!response.ok) {
    throw new Error("Failed to create transaction.");
  }

  return response.json();
}