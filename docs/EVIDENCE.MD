# Formative 3 / Summative Validation Evidence

## Repository and branch
- Integration branch: `summative-integration`
- Final testing branch: `test/documentation-evidence` (repo checked: `pocketpal-app-main` upload)
- Date tested: 2026-07-21 (initial pass), updated 2026-07-31 with production deployment + real CI evidence
- Tester: SibahleD

## Application tests
| Test | Command | Result |
|---|---|---|
| Frontend lint | `npm run lint` | Pass, no errors |
| Frontend tests | `npm test` | Pass (1 file, 3/3 tests, `calculateProgress`) |
| Frontend build | `npm run build` | Pass, built in 445ms |
| Backend tests | `cd server && npm test` | **Fail** (2026-07-21): "No test files found, exiting with code 1" — **Fixed** in PR #62 (see below) |

**Backend test finding (2026-07-21):** `server/app.test.js` exists and is a real, working test, but fails to run because there is no `vitest.config` inside `server/`, so Vitest walks up and picks up the **root** `vitest.config.ts`, which explicitly sets `include: ["src/**/*.test.ts", "src/**/*.test.tsx"]` and `exclude: ["server/**", ...]`.

**Resolution:** PR #62 (commit `b9de8b7`, "fix: patch backend dependencies and add API tests") adds `server/vitest.config.js` and `server/tests/app.test.js`, giving the backend its own scoped Vitest config so tests are discovered correctly.

## Terraform validation
| Test | Result |
|---|---|
| Formatting check | Not re-run this session, prior run (`terraform fmt -recursive -check`) returned no diffs |
| Initialisation | Not re-run this session, prior run (`terraform init`) succeeded |
| Validation | Not re-run this session, prior run (`terraform validate`) returned "Success! The configuration is valid." |
| Infrastructure provisioned | Confirmed — see Production Deployment Evidence below |

## Ansible validation
| Test | Result |
|---|---|
| Inventory parsing | **Blocked** at time of original test: `ansible.cfg` points to `inventory.ini`, which is not present in the repo (not committed, presumably because it would contain real server IPs/credentials) |
| Ping | **Pass** (later run) — `ansible -i ansible/inventory.ini web -m ping` returned `pocketpal-production | SUCCESS => { "changed": false, "ping": "pong" }` |
| Syntax check | Pass, `ansible-playbook --syntax-check playbook.yml` succeeded |
| Ansible Lint | **Fail** (2026-07-21): 10 violations across 4 files: 2x `yaml[truthy]`, 1x `no-changed-when`, 7x `fqcn[action-core]` (unqualified module names like `git`, `apt`, `command`, `debug`, `service` instead of `ansible.builtin.*`) |
| First playbook run | **Pass** — full run against `pocketpal-production` completed, see Production Deployment Evidence below |
| Idempotency run | Not formally tested, but a second `ansible-galaxy collection install` run reported "Nothing to do. All requested collections are already installed" |
| Docker deployment | **Pass** — confirmed via `docker ps` on the production host, see below |
| UFW verification | Not tested this session |
| SSH hardening | Not tested this session |

## Production Deployment Evidence (added 2026-07-31)

**Ansible playbook run against `pocketpal-production`:**
```
TASK [application : Create application directory] ... ok
TASK [application : Authenticate Docker with Amazon ECR] ... ok
TASK [application : Render production Docker Compose file] ... ok
TASK [application : Pull and start PocketPal containers] ... changed
TASK [application : Wait for backend health endpoint] ... ok
TASK [application : Show running PocketPal containers] ... ok

PLAY RECAP
pocketpal-production : ok=24  changed=1  unreachable=0  failed=0  skipped=3  rescued=0  ignored=0
```

**Containers confirmed running on the production host (`docker ps`):**
| Container | Image | Status | Ports |
|---|---|---|---|
| `pocketpal-frontend` | `387362988747.dkr.ecr.us-east-1.amazonaws.com/pocketpal-frontend:manual-20260731002208` | Up (healthy) | `5173->5173/tcp`, `8080/tcp` |
| `pocketpal-backend` | `387362988747.dkr.ecr.us-east-1.amazonaws.com/pocketpal-backend:manual-20260731002208` | Up (healthy) | `5000->5000/tcp` |

**Live ALB verification** (against `pocketpal-dev-alb-1527388168.us-east-1.elb.amazonaws.com`):
```
GET /health              → status: healthy, service: pocketpal-backend, timestamp: 2026-07-31T00:25:28.099Z
GET /api/goals           → Savings goals fetched successfully (e.g. Laptop Fund, target 500000, saved 150000)
GET /api/transactions    → Transactions fetched successfully (e.g. expense, 2500, Food, "Lunch on campus")
```

## DevSecOps validation (2026-07-21 pass)
| Scanner | Target | Result |
|---|---|---|
| npm audit | Frontend dependencies | 1 high severity: `brace-expansion` (ReDoS), fix available via `npm audit fix` — **patched in PR #62** |
| npm audit | Backend dependencies | 1 low severity: `body-parser` (DoS via invalid limit value), fix available via `npm audit fix` — **patched in PR #62** |
| Trivy | Container images | Not tested in this environment (no Docker daemon, DB host blocked by egress rules) — **now enforced in CI**, see below |
| Checkov | Terraform | Ran successfully: 34 passed, 6 failed (public subnet auto-assigns public IPs; EC2 instance not EBS-optimized, has public IP, no IAM role; VPC missing flow logs; default SG doesn't restrict all traffic) — **addressed in PR #62**, see below |

## CI Pipeline Evidence (real GitHub Actions data, retrieved 2026-07-31 from the repo)

Repo: [github.com/Peterobinna/pocketpal-app](https://github.com/Peterobinna/pocketpal-app), workflow **PocketPal CI and Security** (`ci.yml`).

### PR #61 — earlier run where CI caught real issues

- **PR:** [`fix: harden CI infrastructure and Ansible configuration`](https://github.com/Peterobinna/pocketpal-app/pull/61) — opened and merged 2026-07-29 by Peterobinna
- **Merged with 0 of 2 checks passed** (team merged into `summative-integration` before CI was green)
- **Run:** [PocketPal CI #38](https://github.com/Peterobinna/pocketpal-app/actions/runs/30484145267) — **Status: Failure**, total duration 44s
- **Job "Application Quality and Container Security" — failed in 2s:** could not resolve the pinned action `aquasecurity/trivy-action@0.28.0` (that version doesn't exist)
- **Job "Terraform and Ansible Validation" — failed:** Checkov reported real, uncorrected findings including `CKV_AWS_88` (EC2 public IP), `CKV_AWS_135` (EC2 not EBS-optimized), `CKV_AWS_126` (EC2 detailed monitoring), plus several RDS-related findings (`CKV_AWS_161`, `CKV_AWS_118`, `CKV_AWS_353`, `CKV_AWS_157`, `CKV_AWS_226`, `CKV_AWS_129`) from newly-added `terraform/database.tf`

This confirms the CI pipeline genuinely caught two independent real problems — a broken pinned action version and unresolved infrastructure findings — rather than passing blindly.

### PR #62 — later successful run after fixes

- **PR:** [`feat: add production deployment workflow`](https://github.com/Peterobinna/pocketpal-app/pull/62) — opened 2026-07-29, merged 2026-07-30 by Peterobinna, 8 commits merged into `summative-integration`
- **Merged with 2 of 2 checks passed**
- **Run:** [PocketPal CI #46](https://github.com/Peterobinna/pocketpal-app/actions/runs/30507646105) — **Status: Success**, total duration 1m21s
- Job "Application Quality and Container Security" — passed in 1m13s
- Job "Terraform and Ansible Validation" — passed in 1m9s
- Fix for the PR #61 failure: commits `0265b85`/`8f240db` and a `ci.yml` diff that bumps `aquasecurity/trivy-action@0.28.0` → `aquasecurity/trivy-action@v0.36.0`
- Also adds `.github/workflows/cd.yml`, a full production deployment workflow (see `README.md`), and commit `527559e` ("fix: serve frontend with hardened unprivileged Nginx") which adds `nginx.conf` and updates the `Dockerfile`
