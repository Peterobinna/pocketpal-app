import { describe, expect, it } from "vitest";
import request from "supertest";
import app from "../app.js";

describe("PocketPal backend", () => {
  describe("GET /health", () => {
    it("returns a healthy service response", async () => {
      const response = await request(app).get("/health");

      expect(response.status).toBe(200);
      expect(response.body.status).toBe("healthy");
      expect(response.body.service).toBe("pocketpal-backend");
      expect(response.body.timestamp).toBeDefined();
    });
  });

  describe("GET /", () => {
    it("confirms that the backend is running", async () => {
      const response = await request(app).get("/");

      expect(response.status).toBe(200);
      expect(response.body).toEqual({
        message: "PocketPal backend is running successfully.",
      });
    });
  });

  describe("GET /api/goals", () => {
    it("returns the current savings goals", async () => {
      const response = await request(app).get("/api/goals");

      expect(response.status).toBe(200);
      expect(response.body.message).toBe("Savings goals fetched successfully");
      expect(Array.isArray(response.body.data)).toBe(true);
    });
  });

  describe("POST /api/goals", () => {
    it("creates a valid savings goal", async () => {
      const newGoal = {
        name: "CI Test Goal",
        targetAmount: 100000,
        savedAmount: 25000,
        category: "Education",
      };

      const response = await request(app).post("/api/goals").send(newGoal);

      expect(response.status).toBe(201);
      expect(response.body.message).toBe("Savings goal created successfully");
      expect(response.body.data).toMatchObject(newGoal);
      expect(response.body.data.id).toBeDefined();
    });

    it("rejects a goal with missing required fields", async () => {
      const response = await request(app).post("/api/goals").send({
        name: "Incomplete goal",
      });

      expect(response.status).toBe(400);
      expect(response.body.message).toBe(
        "Please provide name, targetAmount, savedAmount, and category.",
      );
    });

    it("rejects a non-positive target amount", async () => {
      const response = await request(app).post("/api/goals").send({
        name: "Invalid goal",
        targetAmount: 0,
        savedAmount: 0,
        category: "Testing",
      });

      expect(response.status).toBe(400);
      expect(response.body.message).toBe(
        "targetAmount must be greater than zero.",
      );
    });
  });

  describe("GET /api/transactions", () => {
    it("returns the current transactions", async () => {
      const response = await request(app).get("/api/transactions");

      expect(response.status).toBe(200);
      expect(response.body.message).toBe("Transactions fetched successfully.");
      expect(Array.isArray(response.body.data)).toBe(true);
    });
  });

  describe("POST /api/transactions", () => {
    it("creates a valid transaction", async () => {
      const newTransaction = {
        type: "expense",
        amount: 5000,
        category: "Food",
        description: "CI test transaction",
        date: "2026-07-29",
      };

      const response = await request(app)
        .post("/api/transactions")
        .send(newTransaction);

      expect(response.status).toBe(201);
      expect(response.body.message).toBe("Transaction added successfully.");
      expect(response.body.data).toMatchObject(newTransaction);
      expect(response.body.data.id).toBeDefined();
    });

    it("rejects an invalid transaction type", async () => {
      const response = await request(app).post("/api/transactions").send({
        type: "transfer",
        amount: 5000,
        category: "Other",
        description: "Invalid transaction",
        date: "2026-07-29",
      });

      expect(response.status).toBe(400);
      expect(response.body.message).toBe(
        "Transaction type must be income or expense.",
      );
    });

    it("rejects a transaction with missing fields", async () => {
      const response = await request(app).post("/api/transactions").send({
        type: "income",
        amount: 5000,
      });

      expect(response.status).toBe(400);
      expect(response.body.message).toBe(
        "Please provide all transaction fields.",
      );
    });
  });

  describe("Unknown routes", () => {
    it("returns 404 for a route that does not exist", async () => {
      const response = await request(app).get("/does-not-exist");

      expect(response.status).toBe(404);
    });
  });
});
