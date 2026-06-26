import { useState } from "react";
import { createGoal } from "../services/api";

type GoalFormProps = {
  refreshGoals: () => void;
};

function GoalForm({ refreshGoals }: GoalFormProps) {
  const [name, setName] = useState("");
  const [targetAmount, setTargetAmount] = useState("");
  const [savedAmount, setSavedAmount] = useState("");
  const [category, setCategory] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();

    const newGoal = {
      name,
      targetAmount: Number(targetAmount),
      savedAmount: Number(savedAmount),
      category,
    };

    try {
      // Send the goal to Express backend
      await createGoal(newGoal);

      // Refresh the goals list after saving
      refreshGoals();

      // Clear form
      setName("");
      setTargetAmount("");
      setSavedAmount("");
      setCategory("");
    } catch (error) {
      console.error(error);
      alert("Unable to save goal.");
    }
  }

  return (
    <form className="goal-form" onSubmit={handleSubmit}>
      <h2>Create Savings Goal</h2>

      <input
        placeholder="Goal Name"
        value={name}
        onChange={(e) => setName(e.target.value)}
      />

      <input
        type="number"
        placeholder="Target Amount"
        value={targetAmount}
        onChange={(e) => setTargetAmount(e.target.value)}
      />

      <input
        type="number"
        placeholder="Saved Amount"
        value={savedAmount}
        onChange={(e) => setSavedAmount(e.target.value)}
      />

      <input
        placeholder="Category"
        value={category}
        onChange={(e) => setCategory(e.target.value)}
      />

      <button>Add Goal</button>
    </form>
  );
}

export default GoalForm;