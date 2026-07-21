# Formative 3 Validation Evidence
 
## Repository and branch
- Integration branch:
- Final testing branch: `test/documentation-evidence`
- Date tested: 2026-07-21
- Tester: SibahleD
## Application tests
| Test | Command | Result |
|---|---|---|
| Frontend lint | `npm run lint` | Pass |
| Frontend tests | `npm test` | Pass (3/3 tests passed — `calculateProgress`) |
| Frontend build | `npm run build` | Pass (built in 236ms) |
| Backend tests | `cd server && npm test` | Fail (no test files found matching `src/**/*.test.ts`) |
 
## Docker validation
| Test | Result |
|---|---|
| Compose validation | Pass (`docker compose config` resolved cleanly) |
| Backend image build | Pass (`pocketpal-app-backend` built successfully) |
| Frontend image build | Pass (`pocketpal-app-frontend` built successfully) |
| Containers running | Pass (both `pocketpal-backend` and `pocketpal-frontend` Up) |
| Frontend response | Not tested in this session |
| Backend response | Not tested in this session |
 
## Terraform validation
| Test | Result |
|---|---|
| Formatting check | Pass (`terraform fmt -recursive -check` returned no diffs) |
| Initialisation | Pass (`terraform init` succeeded) |
| Validation | Pass (`terraform validate` — "Success! The configuration is valid.") |

 
## DevSecOps validation
| Scanner | Target | Result | Workflow URL |
|---|---|---|---|
| npm audit | Dependencies | 1 high severity vulnerability (frontend), 1 low severity vulnerability (backend) — not remediated | |

## Final conclusion
Application-level checks (lint, unit tests, build) and Docker/Terraform validation pass, with the containers confirmed running locally. Remaining accepted risks: lock file drift was observed (`npm ci` initially failed due to missing `@emnapi/core`/`@emnapi/runtime` entries, resolved via `npm install`). This should be committed to the lock file rather than left as a manual fix step.
 