import express from "express";
import { transactions } from "../data/transactions.js";

// Create a router for the pocketpal-app
const router = express.Router();

/*
=====================================================
GET /api/transactions

Returns every transaction.

Example:

[
   {
      id:1,
      type:"expense",
      amount:2500,
      ...
   }
]
=====================================================
*/

router.get("/", (req, res) => {
  res.status(200).json({
    message: "Transactions fetched successfully.",
    data: transactions,
  });
});

/*
=====================================================
POST /api/transactions

Creates a new transaction.

Expected request body:

{
   "type":"expense",
   "amount":5000,
   "category":"Food",
   "description":"Dinner",
   "date":"2026-06-26"
}
=====================================================
*/

router.post("/", (req, res) => {
  const {
    type,
    amount,
    category,
    description,
    date,
  } = req.body;

  /*
  Validate all required fields
  */

  if (
    !type ||
    amount === undefined ||
    !category ||
    !description ||
    !date
  ) {
    return res.status(400).json({
      message: "Please provide all transaction fields.",
    });
  }

  /*
  Only allow income or expense
  */

  if (type !== "income" && type !== "expense") {
    return res.status(400).json({
      message: "Transaction type must be income or expense.",
    });
  }

  /*
  Convert amount into a number
  */

  const numericAmount = Number(amount);

  if (Number.isNaN(numericAmount)) {
    return res.status(400).json({
      message: "Amount must be a number.",
    });
  }

  /*
  Create the transaction
  */

  const newTransaction = {
    id: Date.now(),
    type,
    amount: numericAmount,
    category,
    description,
    date,
  };

  /*
  Save it into our temporary array
  */

  transactions.push(newTransaction);

  /*
  Return success response
  */

  return res.status(201).json({
    message: "Transaction added successfully.",
    data: newTransaction,
  });
});

export default router;