# Formative 3 Validation Evidence

## Repository and branch
- Integration branch:
- Final testing branch: `test/documentation-evidence` (repo checked: `pocketpal-app-main` upload)
- Date tested: 2026-07-21
- Tester: SibahleD

## Application tests
| Test | Command | Result |
|---|---|---|
| Frontend lint | `npm run lint` | Pass, no errors |
| Frontend tests | `npm test` | Pass (1 file, 3/3 tests, `calculateProgress`) |
| Frontend build | `npm run build` | Pass, built in 445ms |
| Backend tests | `cd server && npm test` | **Fail**: "No test files found, exiting with code 1" |

**Backend test finding:** `server/app.test.js` exists and is a real, working test (verified `supertest` health-route check). It fails to run because there is no `vitest.config` inside `server/`, so Vitest walks up and picks up the **root** `vitest.config.ts`, which explicitly sets `include: ["src/**/*.test.ts", "src/**/*.test.tsx"]` and `exclude: ["server/**", ...]`. That config was written to keep the root test run frontend-only, but it also silently swallows the backend's own test command. Adding a local `server/vitest.config.js` with `include: ["**/*.test.js"]` fixes this: confirmed locally, the same test then passes (1/1). Note the CI workflow (`.github/workflows/ci.yml`) runs `npm test` in `./server` the same way, so this is likely failing in CI too, not just locally.

## Docker validation
| Test | Result |
|---|---|
| Compose validation | Not re-run this session, prior run (`docker compose config`) resolved cleanly |
| Backend image build | Not re-run this session, prior run built `pocketpal-app-backend` successfully |
| Frontend image build | Not re-run this session, prior run built `pocketpal-app-frontend` successfully |
| Containers running | Not re-run this session, prior run showed both containers `Up` |
| Frontend response | Not tested |
| Backend response | Not tested |

*(No Docker daemon was available in this validation environment, so these could not be re-executed here. Values above reflect the previously captured terminal session and should be re-confirmed in your Codespace before submission.)*

## Terraform validation
| Test | Result |
|---|---|
| Formatting check | Not re-run this session, prior run (`terraform fmt -recursive -check`) returned no diffs |
| Initialisation | Not re-run this session, prior run (`terraform init`) succeeded |
| Validation | Not re-run this session, prior run (`terraform validate`) returned "Success! The configuration is valid." |
| Infrastructure provisioned | Not tested, no `terraform apply` evidence available |

*(Terraform CLI was not available in this validation environment. Same caveat as Docker above: reuse the prior session's evidence, or re-run before submission.)*

## Ansible validation
| Test | Result |
|---|---|
| Inventory parsing | **Blocked**: `ansible.cfg` points to `inventory.ini`, which is not present in the repo (not committed, presumably because it would contain real server IPs/credentials) |
| Ping | Not tested, no inventory/target hosts available |
| Syntax check | Pass, `ansible-playbook --syntax-check playbook.yml` succeeded |
| Ansible Lint | **Fail**: 10 violations across 4 files: 2x `yaml[truthy]`, 1x `no-changed-when`, 7x `fqcn[action-core]` (unqualified module names like `git`, `apt`, `command`, `debug`, `service` instead of `ansible.builtin.*`) |
| First playbook run | Not tested, requires provisioned target host(s) |
| Idempotency run | Not tested, requires provisioned target host(s) |
| Docker deployment | Not tested, depends on playbook run above |
| UFW verification | Not tested, depends on playbook run above |
| SSH hardening | Not tested, depends on playbook run above |

## DevSecOps validation
| Scanner | Target | Result | Workflow URL |
|---|---|---|---|
| npm audit | Frontend dependencies | 1 high severity: `brace-expansion` (ReDoS), fix available via `npm audit fix` | |
| npm audit | Backend dependencies | 1 low severity: `body-parser` (DoS via invalid limit value), fix available via `npm audit fix` | |
| Trivy | Container images | Not tested, no Docker daemon available in this environment to build images to scan, and the Trivy vulnerability DB host is blocked by this sandbox's network egress rules | |
| Checkov | Terraform | **Ran successfully**: 34 passed, 6 failed. Failures: `aws_subnet.public` auto-assigns public IPs (CKV_AWS_130); `aws_instance.pocketpal` is not EBS-optimized (CKV_AWS_135), has a public IP (CKV_AWS_88), and has no IAM role attached (CKV2_AWS_41); `aws_vpc.main` has no flow logging (CKV2_AWS_11) and its default security group doesn't restrict all traffic (CKV2_AWS_12) | |

*(No CI workflow currently runs `npm audit`, Trivy, or Checkov: `.github/workflows/ci.yml` only covers lint, test, and Docker build. There is no workflow run URL to cite; these were run locally against the uploaded repo.)*

## Final conclusion
The repository does **not** yet fully satisfy Formative 3 requirements. Frontend lint, tests, and build pass cleanly. The backend test is written correctly but is never actually executed due to a Vitest config scoping bug, which likely means CI has been silently skipping backend tests, not just this local run. `npm audit` shows one unresolved high-severity (frontend) and one low-severity (backend) advisory, both with a fix available. Ansible cannot be fully validated without a checked-in (or securely supplied) inventory file and provisioned target host(s); syntax is valid, but lint failures (mostly FQCN naming and idempotency style) should be cleaned up regardless. Checkov against Terraform passed the majority of checks but flagged real, fixable AWS hardening gaps (public IP exposure, no IAM role, no VPC flow logs). Trivy container-image scanning could not be completed in this environment and still needs to be run where Docker and network access to the Trivy vulnerability DB are both available (e.g., your Codespace or CI).

**Remaining accepted risks / follow-ups before final submission:**
1. Fix the backend Vitest config so `cd server && npm test` actually runs `app.test.js`.
2. Run `npm audit fix` on both frontend and backend, or document why the flagged packages are being left as-is.
3. Add `inventory.ini` (or a documented process for supplying it) so Ansible ping/playbook/idempotency runs can be evidenced.
4. Resolve or explicitly accept the 6 Checkov findings on the Terraform AWS resources.
5. Add Trivy and Checkov steps to `.github/workflows/ci.yml` so DevSecOps scans are automated and produce a citable workflow URL, and re-run/confirm the Docker and Terraform CLI evidence (not re-executable in this particular environment).