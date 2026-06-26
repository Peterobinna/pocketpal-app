import { useState } from "react";
import { createTransaction } from "../services/api";

type TransactionFormProps = {
  refreshTransactions: () => void;
};

function TransactionForm({ refreshTransactions }: TransactionFormProps) {
  // Form state: these store what the user types/selects.
  const [type, setType] = useState<"income" | "expense">("expense");
  const [amount, setAmount] = useState("");
  const [category, setCategory] = useState("");
  const [description, setDescription] = useState("");
  const [date, setDate] = useState("");

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();

    // Basic validation before sending to backend.
    if (!amount || !category || !description || !date) {
      alert("Please fill in all transaction fields.");
      return;
    }

    const newTransaction = {
      type,
      amount: Number(amount),
      category,
      description,
      date,
    };

    try {
      // Send transaction to backend.
      await createTransaction(newTransaction);

      // Reload transactions so the new one appears on the page.
      refreshTransactions();

      // Clear form after successful submission.
      setType("expense");
      setAmount("");
      setCategory("");
      setDescription("");
      setDate("");
    } catch (error) {
      console.error(error);
      alert("Unable to save transaction.");
    }
  }

  return (
    <form className="transaction-form" onSubmit={handleSubmit}>
      <h2>Add Transaction</h2>

      <label>
        Transaction Type
        <select
          value={type}
          onChange={(event) =>
            setType(event.target.value as "income" | "expense")
          }
        >
          <option value="income">Income</option>
          <option value="expense">Expense</option>
        </select>
      </label>

      <label>
        Amount
        <input
          type="number"
          placeholder="Example: 2500"
          value={amount}
          onChange={(event) => setAmount(event.target.value)}
        />
      </label>

      <label>
        Category
        <input
          type="text"
          placeholder="Example: Food, Transport, Allowance"
          value={category}
          onChange={(event) => setCategory(event.target.value)}
        />
      </label>

      <label>
        Description
        <input
          type="text"
          placeholder="Example: Lunch on campus"
          value={description}
          onChange={(event) => setDescription(event.target.value)}
        />
      </label>

      <label>
        Date
        <input
          type="date"
          value={date}
          onChange={(event) => setDate(event.target.value)}
        />
      </label>

      <button type="submit">Add Transaction</button>
    </form>
  );
}

export default TransactionForm;