import type { Transaction } from "../types/transaction";

type TransactionListProps = {
  transactions: Transaction[];
};

function TransactionList({ transactions }: TransactionListProps) {
  return (
    <section className="transactions-section">
      <h2>Transaction History</h2>

      {transactions.length === 0 ? (
        <p>No transactions yet. Add your first income or expense.</p>
      ) : (
        <div className="transaction-list">
          {transactions.map((transaction) => (
            <div className="transaction-card" key={transaction.id}>
              <div>
                <h3>{transaction.description}</h3>
                <p>
                  <strong>Category:</strong> {transaction.category}
                </p>
                <p>
                  <strong>Date:</strong> {transaction.date}
                </p>
              </div>

              <div className={`transaction-amount ${transaction.type}`}>
                {transaction.type === "income" ? "+" : "-"}₦
                {transaction.amount.toLocaleString()}
              </div>
            </div>
          ))}
        </div>
      )}
    </section>
  );
}

export default TransactionList;