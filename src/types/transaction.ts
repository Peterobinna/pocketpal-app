// This describes what one transaction should look like.
// We use this type so TypeScript can help us catch mistakes.

export type Transaction = {
  id: number;
  type: "income" | "expense";
  amount: number;
  category: string;
  description: string;
  date: string;
};