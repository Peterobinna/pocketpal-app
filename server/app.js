import express from "express";
import cors from "cors";

import goalsRouter from "./routes/goals.js";
import transactionsRouter from "./routes/transactions.js";

// Create the Express app.
// We keep this in app.js so tests can import the app without starting the server.
const app = express();

/**
 * Middleware
 *
 * express.json() allows the backend to read JSON request bodies.
 * cors() allows the frontend and backend to communicate on different ports.
 */
app.use(express.json());
app.use(cors());

/**
 * Health-check endpoint used by the load balancer,
 * deployment pipeline and operators.
 */
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    service: "pocketpal-backend",
    timestamp: new Date().toISOString(),
  });
});

/**
 * Health route
 *
 * This route confirms that the backend is running.
 * Our backend test will check this route.
 */
app.get("/", (req, res) => {
  res.status(200).json({
    message: "PocketPal backend is running successfully.",
  });
});

/**
 * API routes
 *
 * These connect the route files to the main Express app.
 */
app.use("/api/goals", goalsRouter);
app.use("/api/transactions", transactionsRouter);

export default app;
