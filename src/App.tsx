import { useEffect, useState } from "react";

import "./App.css";

import GoalForm from "./components/GoalForm";
import GoalCard from "./components/GoalCard";
import TransactionForm from "./components/TransactionForm";
import TransactionList from "./components/TransactionList";

import { getGoals, getTransactions } from "./services/api";

import type { SavingsGoal } from "./types";
import type { Transaction } from "./types/transaction";

function App() {
  // Stores all savings goals from the backend.
  const [goals, setGoals] = useState<SavingsGoal[]>([]);

  // Stores all transactions from the backend.
  const [transactions, setTransactions] = useState<Transaction[]>([]);

  // Stores loading state so the user knows data is being fetched.
  const [loading, setLoading] = useState(true);

  /**
   * Load savings goals from Express backend.
   */
  async function loadGoals() {
    try {
      const response = await getGoals();
      setGoals(response.data);
    } catch (error) {
      console.error("Error loading goals:", error);
    }
  }

  /**
   * Load transactions from Express backend.
   */
  async function loadTransactions() {
    try {
      const response = await getTransactions();
      setTransactions(response.data);
    } catch (error) {
      console.error("Error loading transactions:", error);
    }
  }

  /**
   * Load all app data when the page first opens.
   */
  useEffect(() => {
    async function loadAppData() {
      setLoading(true);

      await loadGoals();
      await loadTransactions();

      setLoading(false);
    }

    loadAppData();
  }, []);

  return (
    <main className="app">
      <section className="hero">
        <h1>PocketPal</h1>
        <p>
          A simple savings and budget tracker for African university students.
        </p>
      </section>

      {loading ? (
        <p className="loading-text">Loading PocketPal data...</p>
      ) : (
        <>
          <GoalForm refreshGoals={loadGoals} />

          <section className="goals-section">
            <h2>Your Savings Goals</h2>

            {goals.length === 0 ? (
              <p>No savings goals yet. Create your first goal above.</p>
            ) : (
              <div className="goals-grid">
                {goals.map((goal) => (
                  <GoalCard key={goal.id} goal={goal} />
                ))}
              </div>
            )}
          </section>

          <TransactionForm refreshTransactions={loadTransactions} />

          <TransactionList transactions={transactions} />
        </>
      )}
    </main>
  );
}

export default App;