import { useEffect, useState } from "react";

import "./App.css";

import GoalForm from "./components/GoalForm";
import GoalCard from "./components/GoalCard";

import { getGoals } from "./services/api";

function App() {

  // Stores all savings goals
  const [goals, setGoals] = useState<any[]>([]);

  /**
   * Loads all goals from backend
   */
  async function loadGoals() {
    try {

      const response = await getGoals();

      // Express returns:
      // {
      //   message: "...",
      //   data: [...]
      // }

      setGoals(response.data);

    } catch (error) {

      console.error(error);

    }
  }

  /**
   * Runs once when page loads
   */
  useEffect(() => {
    loadGoals();
  }, []);

  return (
    <main className="app">

      <section className="hero">
        <h1>PocketPal</h1>

        <p>
          A simple savings and budget tracker for African university students.
        </p>
      </section>

      <GoalForm refreshGoals={loadGoals} />

      <section className="goals-section">

        <h2>Your Savings Goals</h2>

        <div className="goals-grid">

          {goals.map((goal) => (

            <GoalCard
              key={goal.id}
              goal={goal}
            />

          ))}

        </div>

      </section>

    </main>
  );
}

export default App;