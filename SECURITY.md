# Security Review

## Scope

This review covers:

- Frontend dependencies
- Backend dependencies
- Docker container images
- Terraform infrastructure
- GitHub Actions security checks

## Security tools

| Scan category       | Tool      | Target                            | Trigger            |
| ------------------- | --------- | ---------------------------------- | ------------------ |
| Dependency scanning | npm audit | Frontend and backend dependencies | Every pull request |
| Container scanning  | Trivy     | PocketPal Docker images           | Every pull request — HIGH/CRITICAL findings block the build (`exit-code: "1"`, `ignore-unfixed: true`) |
| IaC scanning        | Checkov   | terraform/                        | Every pull request, enforced (`soft_fail: false`) |
| TLS/library scanning | OpenSSL  | Container base images             | 🔶 See note below   |

> 🔶 **TEMPLATE — OpenSSL row added per request, but no OpenSSL scan output exists anywhere in the repo.** None of the workflow files (`ci.yml`, `cd.yml`), npm audit, Trivy, or Checkov output reference OpenSSL specifically, and no separate OpenSSL version/CVE check appears in any file pulled from GitHub. If your base images use Alpine/Debian, check the OpenSSL version baked into your `pocketpal-frontend`/`pocketpal-backend` images (`docker exec <container> openssl version`) and note any known CVEs for that version here. Until that's run and pasted in, treat this row as a placeholder, not a completed check.

## Findings summary

| ID      | Tool      | Finding                                                              | Severity | Status   |
| ------- | --------- | --------------------------------------------------------------------- | -------- | -------- |
| SEC-001 | Checkov   | Public IP assigned to bastion host (`aws_instance.bastion`)          | Medium   | Accepted |
| SEC-002 | Checkov   | Bastion host has no IAM role (`aws_instance.bastion`)                 | Low      | Accepted |
| SEC-003 | Checkov   | ALB has no AWS WAF (`aws_lb.main`)                                    | Medium   | Accepted |
| SEC-004 | Checkov   | Public listener uses HTTP, not HTTPS (`aws_lb_listener.http`)         | High     | Accepted |
| SEC-005 | Checkov   | Internal target-group traffic uses HTTP                              | Low      | Accepted |
| SEC-006 | Checkov   | Detailed monitoring disabled on bastion (`aws_instance.bastion`)      | Low      | Resolved |
| SEC-007 | npm audit | `brace-expansion` — ReDoS vulnerability (frontend dependencies)      | High     | **Resolved** (PR #62) |
| SEC-008 | npm audit | `body-parser` — DoS via invalid limit value (backend dependencies)   | Low      | **Resolved** (PR #62) |
| SEC-009 | Checkov   | `aws_subnet.public` auto-assigns public IPs                          | Medium   | Addressed in PR #62 — see note |
| SEC-010 | Checkov   | `aws_instance.pocketpal` not EBS-optimized                            | Low      | Addressed in PR #62 — see note |
| SEC-011 | Checkov   | `aws_instance.pocketpal` has a public IP, no IAM role                | Medium   | Addressed in PR #62 — see note |
| SEC-012 | Checkov   | `aws_vpc.main` has no flow logging, default SG doesn't restrict all traffic | Medium | Addressed in PR #62 — see note |
| SEC-013 | Trivy     | Container image scan                                                  | —        | **Now enforced and passing** — see below |

Checkov overall result (application infrastructure, run referenced in `EVIDENCE.MD`, tested 2026-07-21): **34 passed, 6 failed** (SEC-009 through SEC-012 above).

**On SEC-007–SEC-012:** PR #62 (merged 2026-07-30, [run #46 passed 2/2 checks](https://github.com/Peterobinna/pocketpal-app/actions/runs/30507646105)) includes commits `0265b85` ("fix: patch npm vulnerabilities in runtime images"), `8f240db` ("fix: remove vulnerable npm tooling from runtime images"), and `1da4f10` ("fix: remediate and document Checkov infrastructure findings"). The npm audit fixes are confirmed resolved because the CI job that runs `npm audit --audit-level=high` for both frontend and backend now passes. The exact post-fix Checkov pass/fail counts for SEC-009–012 weren't pulled from the PR diff itself — 🔶 if you want the precise before/after numbers, share the Checkov step's log output from run #46 and I'll fill in the exact counts instead of "addressed."

## Detailed findings

### SEC-007 — `brace-expansion` ReDoS vulnerability

**Tool:** npm audit
**Affected component:** Frontend dependencies
**Severity:** High
**Description:** A regular-expression denial-of-service (ReDoS) vulnerability in the `brace-expansion` package, a transitive dependency.
**Evidence:** `npm audit` run against frontend dependencies (see `EVIDENCE.MD`), 1 high-severity finding reported.
**Remediation:** Patched in PR #62, commits `0265b85` and `8f240db`.
**Validation:** The `ci.yml` job "Application Quality and Container Security" runs `npm audit --audit-level=high` on every PR and passed in [run #46](https://github.com/Peterobinna/pocketpal-app/actions/runs/30507646105) (2026-07-30), confirming the fix.
**Status:** Resolved

### SEC-008 — `body-parser` DoS via invalid limit value

**Tool:** npm audit
**Affected component:** Backend dependencies
**Severity:** Low
**Description:** Denial-of-service risk in `body-parser` when an invalid `limit` value is supplied.
**Evidence:** `npm audit` run against backend dependencies (see `EVIDENCE.MD`), 1 low-severity finding reported.
**Remediation:** Patched in PR #62, commits `0265b85` and `8f240db`.
**Validation:** The `ci.yml` job "Application Quality and Container Security" runs `npm audit --audit-level=high` on every PR and passed in [run #46](https://github.com/Peterobinna/pocketpal-app/actions/runs/30507646105) (2026-07-30), confirming the fix.
**Status:** Resolved

### SEC-013 — Trivy container scanning now enforced and passing

**Tool:** Trivy
**Affected component:** `pocketpal-frontend`, `pocketpal-backend` images
**Severity:** N/A (gate, not a specific finding)
**Description (original, 2026-07-21):** Trivy could not be run in the development/testing environment: no Docker daemon was available to build images for scanning, and the Trivy vulnerability database host was blocked by the sandbox's network egress rules.
**Update (PR #61, 2026-07-29):** The team pinned `aquasecurity/trivy-action@0.28.0`, a version that doesn't exist, so CI [run #38](https://github.com/Peterobinna/pocketpal-app/actions/runs/30484145267) failed immediately in the "Application Quality and Container Security" job before Trivy could even run.
**Remediation:** PR #62 bumps the pin to `aquasecurity/trivy-action@v0.36.0` in both `ci.yml` and the new `cd.yml`. Both workflows scan the frontend and backend images with `severity: HIGH,CRITICAL`, `ignore-unfixed: true`, and `exit-code: "1"` — meaning a HIGH/CRITICAL finding with a fix available blocks the build/deploy.
**Validation:** [Run #46](https://github.com/Peterobinna/pocketpal-app/actions/runs/30507646105) (2026-07-30) — "Application Quality and Container Security" passed in 1m13s, which includes the Trivy scan step against both images.
**Status:** Resolved — Trivy now runs and gates every PR and every production deployment. (The underlying per-CVE Trivy report itself wasn't pulled from the run logs — 🔶 share that step's log if you want the specific package/CVE list included here.)

## Accepted risks

Document any finding the team has chosen not to remediate.

For every accepted risk, explain:

- Why it remains
- Why the risk is acceptable for this coursework environment
- What a production implementation should change
- Any compensating control

### SEC-001 — Public IP assigned to bastion host

**Checkov ID:** CKV_AWS_88
**Affected component:** `aws_instance.bastion`
**Status:** Accepted
**Justification:** The bastion is intentionally deployed in a public subnet and requires a public IP to provide controlled SSH access to the private application server. SSH is restricted by a security group to approved `/32` addresses. The application EC2 instance remains private and accepts SSH only from the bastion security group.
**Production improvement:** Replace direct bastion SSH with AWS Systems Manager Session Manager where possible.

### SEC-002 — Bastion does not have an IAM role

**Checkov ID:** CKV2_AWS_41
**Affected component:** `aws_instance.bastion`
**Status:** Accepted
**Justification:** The bastion does not need to access AWS APIs. Assigning an IAM role without an operational requirement would introduce unnecessary permissions.
**Compensating control:** The bastion provides SSH forwarding only and has restricted network access.

### SEC-003 — Application Load Balancer does not use AWS WAF

**Checkov ID:** CKV2_AWS_28
**Affected component:** `aws_lb.main`
**Status:** Accepted
**Justification:** AWS WAF is outside the cost and scope of the coursework environment.
**Production improvement:** Associate the public ALB with an AWS WAF web ACL using managed rules, rate limiting and logging.

### SEC-004 — Public listener uses HTTP

**Checkov ID:** CKV_AWS_103
**Affected component:** `aws_lb_listener.http`
**Status:** Accepted
**Justification:** The coursework environment does not currently have a registered domain and ACM certificate. It exposes demonstration data only and does not provide authentication or process real financial information. This is also why the live URL in `README.md` is `http://`, not `https://`.
**Production improvement:** Provision an ACM certificate, create an HTTPS listener using TLS 1.2 or newer, and redirect HTTP traffic to HTTPS.

### SEC-005 — Internal target-group traffic uses HTTP

**Checkov ID:** CKV_AWS_378
**Affected components:** Frontend and backend target groups
**Status:** Accepted
**Justification:** Target-group traffic travels between the ALB and application EC2 instance inside the controlled VPC.
**Production improvement:** Use end-to-end TLS between the load balancer and application targets where required.

### SEC-006 — Detailed monitoring was disabled on the bastion

**Checkov ID:** CKV_AWS_126
**Affected component:** `aws_instance.bastion`
**Status:** Resolved
**Remediation:** Enabled EC2 detailed monitoring by setting `monitoring = true`.
**Validation:** Terraform validation and enforced Checkov scanning are rerun in CI.

## Infrastructure security controls

- SSH is restricted to approved `/32` addresses
- Root SSH login is disabled
- Password authentication is disabled
- Public-key authentication is enabled
- UFW is enabled
- EC2 metadata requires IMDSv2
- The EC2 root volume is encrypted
- Terraform state and local variable files are excluded from Git
- AWS credentials and SSH keys are not stored in the repository

## Remediation validation

| Finding | Rerun scan | Result |
|---|---|---|
| SEC-006 (bastion monitoring) | Checkov | Resolved — confirmed via CI |
| SEC-007 (`brace-expansion`) | npm audit | Resolved — passed in [run #46](https://github.com/Peterobinna/pocketpal-app/actions/runs/30507646105) |
| SEC-008 (`body-parser`) | npm audit | Resolved — passed in [run #46](https://github.com/Peterobinna/pocketpal-app/actions/runs/30507646105) |
| SEC-013 (Trivy) | Trivy | Resolved — now enforced and passing in [run #46](https://github.com/Peterobinna/pocketpal-app/actions/runs/30507646105), after failing in [run #38](https://github.com/Peterobinna/pocketpal-app/actions/runs/30484145267) due to a bad action version pin |

## Reporting security concerns

Security concerns should be reported privately to the project maintainers and must not include credentials, private keys or sensitive AWS information in public issues.
