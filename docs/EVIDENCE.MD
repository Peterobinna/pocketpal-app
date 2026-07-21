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

**Backend test finding:** `server/app.test.js` exists and is a real, working test, but fails to run because there is no `vitest.config` inside `server/`, so Vitest walks up and picks up the **root** `vitest.config.ts`, which explicitly sets `include: ["src/**/*.test.ts", "src/**/*.test.tsx"]` and `exclude: ["server/**", ...]`. 

## Terraform validation
| Test | Result |
|---|---|
| Formatting check | Not re-run this session, prior run (`terraform fmt -recursive -check`) returned no diffs |
| Initialisation | Not re-run this session, prior run (`terraform init`) succeeded |
| Validation | Not re-run this session, prior run (`terraform validate`) returned "Success! The configuration is valid." |
| Infrastructure provisioned | Not tested, no `terraform apply` evidence available |

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
