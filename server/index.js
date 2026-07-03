import app from "./app.js";

// Choose the port for the backend server.
// If an environment variable PORT exists, use it.
// Otherwise, default to 5000.
const PORT = process.env.PORT || 5000;

// Start the backend server.
app.listen(PORT, () => {
  console.log(`PocketPal backend is running on http://localhost:${PORT}`);
});