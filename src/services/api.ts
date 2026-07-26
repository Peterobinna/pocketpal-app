// Use the configured URL when supplied.
// In production, an empty value makes the browser call the same
// Application Load Balancer that served the frontend.
const API_BASE_URL = import.meta.env.VITE_API_URL || "";

const GOALS_URL = `${API_BASE_URL}/api/goals`;
const TRANSACTIONS_URL = `${API_BASE_URL}/api/transactions`;

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
 * Create a new savings goal.
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
 * Fetch all transactions.
 */
export async function getTransactions() {
  const response = await fetch(TRANSACTIONS_URL);

  if (!response.ok) {
    throw new Error("Failed to fetch transactions.");
  }

  return response.json();
}

/**
 * Create a new transaction.
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
