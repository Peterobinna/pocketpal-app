import { useState } from "react";
import "./App.css";
import GoalForm from "./components/GoalForm";
import GoalCard from "./components/GoalCard";
import { mockGoals } from "./data/mockGoals";
import type { SavingsGoal } from "./types";

function App() {
  // This stores all the savings goals displayed on the page
  const [goals, setGoals] = useState<SavingsGoal[]>(mockGoals);

  function handleAddGoal(newGoal: SavingsGoal) {
    // This adds the new goal to the existing list of goals
    setGoals([newGoal, ...goals]);
  }

  return (
    <main className="app">
      <section className="hero">
        <h1>PocketPal</h1>
        <p>
          A simple savings and budget tracker for African university students.
        </p>
      </section>

      <GoalForm onAddGoal={handleAddGoal} />

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
    </main>
  );
}

export default App;