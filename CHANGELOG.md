# Changelog

All notable changes to PocketPal, reconstructed from real merged pull requests and CI runs in [github.com/Peterobinna/pocketpal-app](https://github.com/Peterobinna/pocketpal-app), retrieved 2026-07-31.

---

## Formative 1 (F1) and Formative 2 (F2)

> 🔶 **Not reconstructed.** The repository's Actions history goes back to run #22 ("Add Ansible server configuration and deployment") within the timeframe pulled here; earlier F1/F2-era commits and PRs exist in the repo but weren't fetched in this pass to stay within a reasonable scope. If you want these filled in for real, share the F1/F2 PR numbers (or ask me to page further back through `github.com/Peterobinna/pocketpal-app/actions?page=2` onward) and I'll pull the same kind of real detail as below instead of guessing.

---

## Formative 3 — documentation and evidence (2026-07-21 to 2026-07-29)

- **PR #55/#56/#58** — `test/documentation-evidence` branch work by SibahleD: added Ansible server configuration and deployment, Formative 3 security findings, and validation evidence; one commit explicitly titled "Fixed Github Actions testing error" and another "Evidence fix", indicating the CI/evidence documentation itself needed iteration to get right.
- **PR #57** — "Merge Formative 3 integration to main", by SibahleD, merging the `formative-3-integration` branch.

## Summative — infrastructure and deployment automation (2026-07-29 to 2026-07-30)

- **PR #59** — "feat: provision production AWS infrastructure", by Sarah-kasande, `feature/summative-terraform` branch.
- **PR #60** — "feat: deploy versioned ECR images with Ansible", by IshimweOlivier-20, `feature/summative-ansible` branch.
- **PR #61** — "fix: harden CI infrastructure and Ansible configuration", by Peterobinna, `feature/summative-hardening` branch. Per its own description, this PR:
  - Repaired frontend and backend dependency lockfiles
  - Replaced the legacy CI workflow with deterministic `npm ci` installs
  - Added frontend/backend dependency scans, Trivy scanning, Terraform formatting/validation, enforced (non-soft-fail) Checkov, and Ansible syntax validation
  - Removed hardcoded Ansible firewall values and explicitly enabled SSH public-key authentication
  - **Merged with 0 of 2 CI checks passing** — [run #38](https://github.com/Peterobinna/pocketpal-app/actions/runs/30484145267) failed: the pinned `aquasecurity/trivy-action@0.28.0` didn't resolve (nonexistent version), and Checkov reported real unresolved findings (`CKV_AWS_88`, `CKV_AWS_135`, `CKV_AWS_126`, plus RDS-related findings from a newly-added `database.tf`). The team merged anyway rather than waiting for green CI.
- **PR #62** — "feat: add production deployment workflow", by Peterobinna, `feature/production-cd` branch, 8 commits:
  - `c31a518` feat: add production deployment workflow (adds `.github/workflows/cd.yml`, a full build→scan→push→deploy→verify pipeline)
  - `cf17a44` fix: repair security scans and document accepted risks
  - `b9de8b7` fix: patch backend dependencies and add API tests (adds `server/vitest.config.js` and `server/tests/app.test.js`, fixing the backend test-discovery issue from the 2026-07-21 evidence pass)
  - `1da4f10` fix: remediate and document Checkov infrastructure findings
  - `80a2505` fix: make backend install portable and repair Ansible syntax
  - `0265b85` fix: patch npm vulnerabilities in runtime images
  - `8f240db` fix: remove vulnerable npm tooling from runtime images
  - `527559e` fix: serve frontend with hardened unprivileged Nginx (adds `nginx.conf`, updates `Dockerfile`)
  - **Merged with 2 of 2 CI checks passing** — [run #46](https://github.com/Peterobinna/pocketpal-app/actions/runs/30507646105), confirming the Trivy pin, npm vulnerabilities, and Checkov findings from PR #61's failure were genuinely fixed, not just documented around.

## Summative — production deployment verified (2026-07-31)

- Ansible playbook run against `pocketpal-production`: `ok=24 changed=1 unreachable=0 failed=0 skipped=3`.
- Docker containers confirmed running and healthy: `pocketpal-frontend` and `pocketpal-backend`, pulled from `387362988747.dkr.ecr.us-east-1.amazonaws.com`, tag `manual-20260731002208`.
- Live verification against the production ALB (`pocketpal-dev-alb-1527388168.us-east-1.elb.amazonaws.com`): `/health`, `/api/goals`, `/api/transactions` all returned healthy, real data.
- `README.md`, `SECURITY.md`, and `EVIDENCE.MD` updated to reflect all of the above, replacing earlier template placeholders with real, sourced data pulled directly from the repository.

### Still open
- No rollback job/script exists in `cd.yml` — see the Rollback section in `README.md` for what a real one would need.
- F1/F2 history not yet reconstructed (see note above).
- No OpenSSL-specific scan exists anywhere in the pipeline or repo.
- The `nginx.conf` hardening (commit `527559e`) is merged into `summative-integration`, not yet into `main`.

### Correction
- Earlier drafts of this changelog referenced work by "Ewing." No contributor by that name appears anywhere in this repository's commits, pull requests, or Actions runs — the real contributors are Peterobinna, SibahleD, IshimweOlivier-20, and Sarah-kasande. That reference has been removed rather than guessed at.
