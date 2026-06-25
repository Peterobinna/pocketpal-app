import type { SavingsGoal } from "../types";
import { calculateProgress } from "../utils/calculateProgress";

type GoalCardProps = {
  goal: SavingsGoal;
};

function GoalCard({ goal }: GoalCardProps) {
  // Calculate how much progress the user has made
  const progress = calculateProgress(goal.savedAmount, goal.targetAmount);

  return (
    <div className="goal-card">
      <h3>{goal.name}</h3>

      <p>
        <strong>Category:</strong> {goal.category}
      </p>

      <p>
        <strong>Target:</strong> ₦{goal.targetAmount.toLocaleString()}
      </p>

      <p>
        <strong>Saved:</strong> ₦{goal.savedAmount.toLocaleString()}
      </p>

      <p>
        <strong>Progress:</strong> {progress}%
      </p>

      <div className="progress-bar">
        <div
          className="progress-fill"
          style={{ width: `${progress}%` }}
        ></div>
      </div>
    </div>
  );
}

export default GoalCard;