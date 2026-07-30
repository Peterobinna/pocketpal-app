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
| ------------------- | --------- | --------------------------------- | ------------------ |
| Dependency scanning | npm audit | Frontend and backend dependencies | Every pull request |
| Container scanning  | Trivy     | PocketPal Docker images           | Every pull request |
| IaC scanning        | Checkov   | terraform/                        | Every pull request |

## Findings summary

| ID      | Tool      | Finding        | Severity        | Status                 |
| ------- | --------- | -------------- | --------------- | ---------------------- |
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
**Justification:** The coursework environment does not currently have a registered domain and ACM certificate. It exposes demonstration data only and does not provide authentication or process real financial information.  
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

Document the scans and tests rerun after corrections.

## Reporting security concerns

Security concerns should be reported privately to the project maintainers and must not include credentials, private keys or sensitive AWS information in public issues.
