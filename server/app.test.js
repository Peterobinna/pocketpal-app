import { describe, expect, it } from "vitest";
import request from "supertest";
import app from "./app.js";

// This test checks the backend health route.
// It confirms that the Express server responds correctly at GET /.

describe("PocketPal backend health route", () => {
  it("returns a success message from GET /", async () => {
    const response = await request(app).get("/");

    expect(response.status).toBe(200);
    expect(response.body.message).toBe(
      "PocketPal backend is running successfully."
    );
  });
});