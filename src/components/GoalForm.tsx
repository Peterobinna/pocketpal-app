import { useState } from "react";
import type { SavingsGoal } from "../types";

type GoalFormProps = {
  onAddGoal: (goal: SavingsGoal) => void;
};

function GoalForm({ onAddGoal }: GoalFormProps) {
  // These states store what the user types into the form
  const [name, setName] = useState("");
  const [targetAmount, setTargetAmount] = useState("");
  const [savedAmount, setSavedAmount] = useState("");
  const [category, setCategory] = useState("");

  function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    // This prevents the page from refreshing when the form is submitted
    event.preventDefault();

    // Convert the amount values from text to numbers
    const target = Number(targetAmount);
    const saved = Number(savedAmount);

    // Simple validation to make sure the user fills important fields
    if (!name || !targetAmount || !savedAmount || !category) {
      alert("Please fill in all fields.");
      return;
    }

    if (target <= 0) {
      alert("Target amount must be greater than zero.");
      return;
    }

    if (saved < 0) {
      alert("Saved amount cannot be negative.");
      return;
    }

    // Create a new goal object
    const newGoal: SavingsGoal = {
      id: Date.now(),
      name,
      targetAmount: target,
      savedAmount: saved,
      category,
    };

    // Send the new goal to App.tsx
    onAddGoal(newGoal);

    // Clear the form after submission
    setName("");
    setTargetAmount("");
    setSavedAmount("");
    setCategory("");
  }

  return (
    <form className="goal-form" onSubmit={handleSubmit}>
      <h2>Create a Savings Goal</h2>

      <label>
        Goal Name
        <input
          type="text"
          placeholder="Example: Laptop Fund"
          value={name}
          onChange={(event) => setName(event.target.value)}
        />
      </label>

      <label>
        Target Amount
        <input
          type="number"
          placeholder="Example: 500000"
          value={targetAmount}
          onChange={(event) => setTargetAmount(event.target.value)}
        />
      </label>

      <label>
        Saved Amount
        <input
          type="number"
          placeholder="Example: 150000"
          value={savedAmount}
          onChange={(event) => setSavedAmount(event.target.value)}
        />
      </label>

      <label>
        Category
        <input
          type="text"
          placeholder="Example: Education"
          value={category}
          onChange={(event) => setCategory(event.target.value)}
        />
      </label>

      <button type="submit">Add Goal</button>
    </form>
  );
}

export default GoalForm;