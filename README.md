# PocketPal

## A simple savings and budget tracker for African university students.

---

# Project Overview

PocketPal is a full-stack web application that helps African university students monitor their finances by setting savings goals and recording income and expenses.

The application allows users to create savings goals, monitor their savings progress, and keep a simple transaction history. It was developed as part of a DevOps course project to demonstrate collaborative software development, version control, backend API development, and frontend integration.

---

# Problem Statement

Many university students struggle to manage their finances effectively. Weekly allowances, mobile money transactions, irregular income, and daily expenses make it difficult to save consistently and monitor spending.

Most existing budgeting applications are either too complex, require paid subscriptions, or are designed for users with more advanced financial needs.

PocketPal provides a simple, lightweight budgeting tool designed specifically for African university students.

---

# Target Users

- University students
- Student entrepreneurs
- Interns
- Fresh graduates

---

# Core Features

## Savings Goals

- Create savings goals
- Set a target amount
- Record current savings
- View savings progress

## Transactions

- Add income
- Add expenses
- View transaction history
- Categorize transactions
- Record transaction dates

---

# Technology Stack

## Frontend

- React
- TypeScript
- Vite
- CSS

## Backend

- Node.js
- Express.js

## Version Control

- Git
- GitHub

## Project Management

- GitHub Projects (Kanban Board)

---

# Project Structure

```
PocketPal
│
├── src/
│   ├── components/
│   │   ├── GoalCard.tsx
│   │   ├── GoalForm.tsx
│   │   ├── TransactionForm.tsx
│   │   └── TransactionList.tsx
│   │
│   ├── services/
│   │   └── api.ts
│   │
│   ├── types/
│   │   ├── index.ts
│   │   └── transaction.ts
│   │
│   ├── utils/
│   │   └── calculateProgress.ts
│   │
│   ├── App.tsx
│   ├── App.css
│   ├── main.tsx
│   └── index.css
│
├── server/
│   ├── data/
│   │   ├── goals.js
│   │   └── transactions.js
│   │
│   ├── routes/
│   │   ├── goals.js
│   │   └── transactions.js
│   │
│   ├── index.js
│   └── package.json
│
├── README.md
└── .gitignore
```

---

# API Endpoints

## Savings Goals

### GET

```
GET /api/goals
```

Returns all savings goals.

---

### POST

```
POST /api/goals
```

Creates a new savings goal.

Example:

```json
{
  "name": "Laptop Fund",
  "targetAmount": 500000,
  "savedAmount": 150000,
  "category": "Education"
}
```

---

## Transactions

### GET

```
GET /api/transactions
```

Returns all transactions.

---

### POST

```
POST /api/transactions
```

Creates a new transaction.

Example:

```json
{
  "type": "expense",
  "amount": 2500,
  "category": "Food",
  "description": "Lunch on campus",
  "date": "2026-06-25"
}
```

---

# How to Run the Frontend

Clone the repository.

```bash
git clone <repository-url>
```

Move into the project.

```bash
cd pocketpal
```

Install dependencies.

```bash
npm install
```

Run the frontend.

```bash
npm run dev
```

The frontend will run on:

```
http://localhost:5173
```

---

# How to Run the Backend

Open another terminal.

Move into the server folder.

```bash
cd server
```

Install backend dependencies.

```bash
npm install
```

Start the Express server.

```bash
npm run dev
```

The backend will run on:

```
http://localhost:5000
```

---

# Git Workflow

This project follows a collaborative Git workflow.

Each team member:

- Pulls the latest code from `main`
- Creates a new feature branch
- Makes changes
- Commits changes
- Pushes the branch
- Opens a Pull Request
- Receives code review
- Merges into `main`

Example:

```bash
git checkout main

git pull origin main

git checkout -b feature/example-feature
```

---

# Branch Protection

The `main` branch is protected using GitHub Branch Protection Rules.

The repository requires:

- Pull Requests before merging
- At least one approval before merge
- Branches to be up to date before merging
- Conversation resolution before merging
- Protection applied to administrators

These practices help maintain code quality and encourage collaborative development.

---

# GitHub Project Board

Project management is handled using GitHub Projects in Kanban view.

The board contains:

- Backlog
- In Progress
- Done

Tasks are assigned to individual team members with labels for:

- Frontend
- Backend
- DevOps
- Documentation
- Security
- Testing

GitHub Project Board:

```
Paste your GitHub Project Board link here.
```

---

# Current Working Features

The current version of PocketPal supports:

- Creating savings goals
- Viewing savings goals
- Automatic savings progress calculation
- Adding income transactions
- Adding expense transactions
- Viewing transaction history
- Frontend connected to backend APIs
- Express REST API
- GitHub collaboration workflow

---

# Team Members

| Team Member   | Role                                   |
| ------------- | -------------------------------------- |
| Team Member 1 | Team Lead / Repository & Documentation |
| Team Member 2 | Frontend Developer                     |
| Team Member 3 | Backend Developer                      |
| Team Member 4 | DevOps & QA                            |

Replace the names above with your actual team members.

---

# Future Improvements

Future versions of PocketPal may include:

- User authentication
- Database integration (MongoDB)
- Mobile Money integration
- Budget analytics
- Charts and spending insights
- Monthly reports
- Cloud deployment
- Docker support
- CI/CD pipeline
- Terraform infrastructure

---

# License

This project is intended for educational purposes as part of the DevOps course at African Leadership University.
