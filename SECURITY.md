# Security Review

## Scope

This review covers:

- Frontend dependencies
- Backend dependencies
- Docker container images
- Terraform infrastructure
- GitHub Actions security checks

## Security tools

| Scan category | Tool | Target | Trigger |
|---|---|---|---|
| Dependency scanning | npm audit | Frontend and backend dependencies | Every pull request |
| Container scanning | Trivy | PocketPal Docker images | Every pull request |
| IaC scanning | Checkov | terraform/ | Every pull request |

## Findings summary

| ID | Tool | Finding | Severity | Status |
|---|---|---|---|---|
| SEC-001 | Tool name | Actual finding | High/Medium/Low | Resolved/Accepted/Open |

## Detailed findings

### SEC-001 — Finding title

**Tool:**  
**Affected component:**  
**Severity:**  
**Description:**  
**Evidence:**  
**Remediation:**  
**Validation:**  
**Status:**  

## Accepted risks

Document any finding the team has chosen not to remediate.

For every accepted risk, explain:

- Why it remains
- Why the risk is acceptable for this coursework environment
- What a production implementation should change
- Any compensating control

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

Document the scans and tests rerun after corrections.

## Reporting security concerns

Security concerns should be reported privately to the project maintainers and must not include credentials, private keys or sensitive AWS information in public issues.