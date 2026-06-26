
import express from "express";
import cors from "cors";
import goalsRouter from "./routes/goals.js";
import transactionsRouter from "./routes/transactions.js";


// Create the Express app
const app = express();

// Choose the port for the backend server
const PORT = 5000;

/**
 * Middleware
 *
 * express.json() allows the backend to read JSON sent from the frontend.
 * cors() allows the frontend and backend to communicate even though
 * they run on different ports.
 */
app.use(express.json());
app.use(cors());

/**
 * Test route
 *
 * This helps us confirm that the backend server is running.
 * Visit: http://localhost:5000
 */
app.get("/", (req, res) => {
  res.status(200).json({
    message: "PocketPal backend is running successfully.",
  });
});

/**
 * Goals routes
 *
 * Any request that starts with /api/goals will be handled
 * by the goalsRouter from routes/goals.js
 *
 * GET  /api/goals
 * POST /api/goals
 */
app.use("/api/goals", goalsRouter);
app.use("/api/transactions", transactionsRouter);
// Start the backend server
app.listen(PORT, () => {
  console.log(`PocketPal backend is running on http://localhost:${PORT}`);
});
