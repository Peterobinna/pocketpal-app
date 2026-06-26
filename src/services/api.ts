// This file contains all communication between
// the frontend and backend.

// Backend URL
const BASE_URL = "http://localhost:5000/api/goals";

/**
 * Fetch all savings goals from the backend
 */
export async function getGoals() {
  const response = await fetch(BASE_URL);

  if (!response.ok) {
    throw new Error("Failed to fetch goals.");
  }

  return response.json();
}

/**
 * Send a new savings goal to the backend
 */
export async function createGoal(goal: any) {
  const response = await fetch(BASE_URL, {
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