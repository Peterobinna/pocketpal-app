# PocketPal

## A simple savings and budget tracker for African university students.

---

# Project Overview

PocketPal is a full-stack web application that helps African university students monitor their finances by setting savings goals and recording income and expenses.

The application allows users to create savings goals, monitor their savings progress, and keep a simple transaction history. It was developed as part of a DevOps course project to demonstrate collaborative software development, version control, backend API development, and frontend integration.

---

# Live Application

| Environment | URL | Status |
|---|---|---|
| Production (AWS ALB) | http://pocketpal-dev-alb-1527388168.us-east-1.elb.amazonaws.com | Verified live — `/health` returned `{"status":"healthy","service":"pocketpal-backend"}` on 2026-07-31 |

Verified endpoints (tested 2026-07-31):

```
GET /health                → status: healthy, service: pocketpal-backend
GET /api/goals             → Savings goals fetched successfully
GET /api/transactions      → Transactions fetched successfully
```

---

# Architecture

```
                        Internet
                            |
                            v
                 ┌─────────────────────┐
                 │   AWS ALB            │  aws_lb.main
                 │   (public, HTTP)     │  SEC-004: no TLS listener yet
                 └─────────┬───────────┘
                            │
              ┌─────────────┴─────────────┐
              v                             v
   ┌─────────────────────┐      ┌─────────────────────┐
   │ Target Group:        │      │ Target Group:        │
   │ frontend :5173/8080  │      │ backend  :5000       │
   └─────────┬───────────┘      └─────────┬───────────┘
              └─────────────┬─────────────┘
                             v
                  ┌─────────────────────────┐
                  │ EC2: aws_instance.       │
                  │ pocketpal (private)      │
                  │ ── Docker ──             │
                  │  pocketpal-frontend      │
                  │  pocketpal-backend       │
                  └─────────┬───────────────┘
                             │ SSH (restricted SG)
                  ┌─────────┴───────────────┐
                  │ EC2: aws_instance.       │
                  │ bastion (public subnet)  │
                  │ SSH jump host only       │
                  └──────────────────────────┘

   Images pulled from: 387362988747.dkr.ecr.us-east-1.amazonaws.com
   Provisioning: Terraform (infra) + Ansible (Docker deploy/config)
```

This reflects the real Terraform resource names in `terraform/security-groups.tf`, `outputs.tf`, and `SECURITY.md` (`aws_lb.main`, `aws_instance.bastion`, frontend/backend target groups), and the container layout confirmed via `docker ps` on the production host (`pocketpal-frontend`, `pocketpal-backend`, image tag `manual-20260731002208`).

---

# Team Members

| Team Member   | Role                                   |
| ------------- | -------------------------------------- |
| Peter Nnamchukwu | Team Lead / Repository & Documentation |
| Olivier Ishimwe | Frontend Developer                     |
| Sarah Kasande | Backend Developer                      |
| Sibahle Dlamini | DevOps & QA                            |

## Team Tracker Sheet 

[BSE Team Task Sheet - Advanced DevOps](https://docs.google.com/spreadsheets/d/1Zg4m-Mq2uBONXfw4mRRhndXJrH9SZFlJd-Z36j7nMSE/edit?usp=sharing)



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
- Nginx (production container web server, hardened/unprivileged)

  Confirmed via the repo: PR #62 (merged 2026-07-30) includes commit [`527559e` — "fix: serve frontend with hardened unprivileged Nginx"](https://github.com/Peterobinna/pocketpal-app/pull/62/commits/527559e094493c05e1667a8c3ff6bed2bcf4722d), which adds a new `nginx.conf` and updates the `Dockerfile`. This matches the production evidence: the deployed `pocketpal-frontend` container exposes port 8080 in addition to 5173 (see `docker ps` output in `EVIDENCE.MD`), consistent with an Nginx listener alongside the original Vite/`serve` port.
## Backend

- Node.js
- Express.js

## Version Control

- Git
- GitHub

## Project Management

- GitHub Projects (Kanban Board)

## Infrastructure & Deployment

- Terraform (AWS VPC, EC2, ALB, security groups)
- Ansible (Docker install/config, container deployment)
- Docker / Docker Compose
- Amazon ECR (image registry)
- GitHub Actions (CI)

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
├── terraform/
│   ├── outputs.tf
│   ├── providers.tf
│   ├── security-groups.tf
│   └── variables.tf
│
├── README.md
└── .gitignore
```

---

# API Endpoints

## Health

```
GET /health
```

Returns service health status. Verified live response (2026-07-31):
```json
{ "status": "healthy", "service": "pocketpal-backend", "timestamp": "2026-07-31T00:25:28.099Z" }
```

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
git clone https://github.com/Peterobinna/pocketpal-app.git
```

Move into the project.

```bash
cd pocketpal-app
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
- Live production deployment on AWS (EC2 + ALB), verified reachable and healthy


---

# Future Improvements

Future versions of PocketPal may include:

- User authentication
- Database integration (MongoDB)
- Mobile Money integration
- Budget analytics
- Charts and spending insights
- Monthly reports
- HTTPS/TLS on the ALB listener (see SECURITY.md SEC-004)
- AWS WAF on the ALB (see SECURITY.md SEC-003)
- CI/CD pipeline

---

# Rollback Instructions

**Two image tagging schemes are in play, and it matters which one you're rolling back from:**
- The automated `cd.yml` pipeline tags images by commit SHA: `${{ github.sha }}` — e.g. an image built from commit `527559e` would be tagged `527559e...` (the full SHA) in ECR.
- The production host you validated on 2026-07-31 is running images tagged `manual-20260731002208` — a manual/ad-hoc tag, not one the `cd.yml` pipeline produces. This suggests that deployment was done by hand (or by a script outside `cd.yml`), not through the automated pipeline itself.

**To roll back a `cd.yml`-driven deployment:**
1. Find the previous known-good commit SHA (`git log` on `main`, or the SHA tag of the last working image in ECR).
2. Re-run the deployment manually for that SHA using `workflow_dispatch` on the `PocketPal Production Deployment` workflow — but note the current `cd.yml` always builds and pushes from the checked-out `main`, it doesn't accept an arbitrary tag to redeploy. To roll back to an old image without rebuilding, you'd need to either check out that older commit first, or extend `cd.yml` with an input for `image_tag` that skips the build/push steps and goes straight to the Ansible deploy step.
3. Alternatively, run the Ansible deploy step directly against production with the old tag:
   ```bash
   ansible-playbook -i ansible/inventory.production.ini ansible/playbook.yml \
     --extra-vars "ecr_registry=<registry> image_tag=<previous-sha-or-manual-tag> aws_region=<region>"
   ```
4. Confirm with the same health check the pipeline uses:
   ```bash
   curl --fail --silent --show-error "$LIVE_APPLICATION_URL/health"
   docker ps   # on the production host, confirm the older image tag is running
   ```
5. If the rollback itself fails, restore from the most recent `terraform.tfstate.backup` and re-provision rather than patching a broken host in place.

---

# Git Workflow

# Running with Docker Compose

PocketPal can be run locally using Docker Compose.

### Build and start all services

```bash
docker compose up --build
```

The command builds the Docker images (if required) and starts both the frontend and backend containers.

### Frontend

```text
http://localhost:5173
```

### Backend

```text
http://localhost:5000
```

### Stop the containers

```bash
docker compose down
```

This stops and removes all running containers created by Docker Compose.

---

# CI/CD Pipeline

PocketPal uses two **GitHub Actions** workflows, confirmed directly from the repository:

## `ci.yml` — PocketPal CI and Security (runs on every PR)

Two jobs, both required to merge:

- **Application Quality and Container Security** — frontend lint/test/build, `npm audit --audit-level=high` for frontend and backend, Docker image builds, Trivy scan of both images (`severity: HIGH,CRITICAL`, `exit-code: "1"`)
- **Terraform and Ansible Validation** — `terraform fmt -check`, `terraform validate`, Checkov scan (`soft_fail: false`), Ansible syntax check

Real evidence from the repo (see `EVIDENCE.MD` for full detail):
- [**PR #61**](https://github.com/Peterobinna/pocketpal-app/pull/61) merged with **0 of 2 checks passing** — [run #38](https://github.com/Peterobinna/pocketpal-app/actions/runs/30484145267) failed because a pinned Trivy action version didn't exist, plus real unresolved Checkov findings.
- [**PR #62**](https://github.com/Peterobinna/pocketpal-app/pull/62) merged with **2 of 2 checks passing** — [run #46](https://github.com/Peterobinna/pocketpal-app/actions/runs/30507646105) fixed the Trivy pin, patched the npm vulnerabilities, and added the production deployment workflow below.

## `cd.yml` — PocketPal Production Deployment (runs on push to `main`, or manually via `workflow_dispatch`)

Confirmed from the actual workflow file (added in PR #62):

1. Re-runs the full application CI checks (lint, test, build, `npm audit`) for frontend and backend
2. Re-runs Terraform validation and Checkov
3. Runs the Ansible syntax check
4. Builds the frontend and backend Docker images, tagged `${{ github.sha }}`
5. Scans both images with Trivy (`HIGH,CRITICAL`, `exit-code: "1"`) — a vulnerable image is never pushed
6. Authenticates to AWS and pushes both images to Amazon ECR
7. **Temporarily** opens port 22 on the bastion's security group to the GitHub runner's own public IP (via `aws ec2 authorize-security-group-ingress`)
8. Builds a one-off Ansible inventory pointing at the production host through the bastion (`ProxyJump`)
9. Confirms Ansible connectivity with `ansible -m ping`
10. Deploys the newly-pushed, versioned images with `ansible-playbook`, passing `image_tag=${{ github.sha }}`
11. Verifies `/health` through the load balancer, retrying every 10s for up to 3 minutes
12. Verifies the frontend is reachable through the load balancer
13. **Always** (even on failure) revokes the temporary bastion SSH rule it opened in step 7

This is a real, working deployment pipeline — not a template — confirmed from the workflow YAML itself.

---

# Docker Files

The project includes the following Docker-related files:

```text
Dockerfile
docker-compose.yml
.dockerignore
.github/workflows/ci.yml
```

These files provide containerization and automated continuous integration for the application.

---

# DevOps Evidence

See `EVIDENCE.MD` for the full validation log (application tests, Terraform, Ansible, and DevSecOps scans) and `SECURITY.md` for the full security review and accepted-risk register.

The `main` branch is protected using branch protection rules. Pull requests are required before merging, at least one approval is required, conversations must be resolved, and branches must be up to date before merge.

# License

This project is intended for educational purposes as part of the DevOps course at African Leadership University.
