import express from "express";
import { goals } from "../data/goals.js";

// express.Router() helps us group related routes together.
// In this file, we are grouping all savings-goal routes.
const router = express.Router();

/**
 * GET /api/goals
 *
 * This route returns all savings goals.
 * Example response:
 * [
 *   {
 *     id: 1,
 *     name: "Laptop Fund",
 *     targetAmount: 500000,
 *     savedAmount: 150000,
 *     category: "Education"
 *   }
 * ]
 */
router.get("/", (req, res) => {
  res.status(200).json({
    message: "Savings goals fetched successfully",
    data: goals,
  });
});

/**
 * POST /api/goals
 *
 * This route creates a new savings goal.
 * The frontend will send goal details in the request body.
 *
 * Expected request body:
 * {
 *   "name": "School Fees",
 *   "targetAmount": 300000,
 *   "savedAmount": 50000,
 *   "category": "Education"
 * }
 */
router.post("/", (req, res) => {
  // Get the values sent from the frontend or Postman
  const { name, targetAmount, savedAmount, category } = req.body;

  // Simple validation: make sure all important fields are provided
  if (
    !name ||
    targetAmount === undefined ||
    savedAmount === undefined ||
    !category
  ) {
    return res.status(400).json({
      message: "Please provide name, targetAmount, savedAmount, and category.",
    });
  }

  // Convert amounts to numbers in case they come as strings
  const target = Number(targetAmount);
  const saved = Number(savedAmount);

  // Validate the numbers
  if (Number.isNaN(target) || Number.isNaN(saved)) {
    return res.status(400).json({
      message: "targetAmount and savedAmount must be valid numbers.",
    });
  }

  if (target <= 0) {
    return res.status(400).json({
      message: "targetAmount must be greater than zero.",
    });
  }

  if (saved < 0) {
    return res.status(400).json({
      message: "savedAmount cannot be negative.",
    });
  }

  // Create a new goal object
  const newGoal = {
    id: Date.now(),
    name,
    targetAmount: target,
    savedAmount: saved,
    category,
  };

  // Add the new goal to our temporary goals array
  goals.push(newGoal);

  // Send the newly created goal back as the response
  return res.status(201).json({
    message: "Savings goal created successfully",
    data: newGoal,
  });
});

export default router;
