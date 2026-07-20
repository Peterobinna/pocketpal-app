#!/bin/bash

# GitHub CLI Script to Create Formative 3 Issues
# Run this script from the repository root

echo "Creating Formative 3 Issues..."

# Issue 2 - Terraform Network
gh issue create \
  --title "Design and provision the Terraform network infrastructure" \
  --body "## Objective

Use Terraform to provision the network infrastructure required by the application.

## Tasks

- [ ] Confirm the team's cloud provider and region
- [ ] Define the VPC or virtual network
- [ ] Define the public subnet
- [ ] Configure internet access
- [ ] Configure routing
- [ ] Create network security rules
- [ ] Restrict SSH access appropriately
- [ ] Allow only the required application ports
- [ ] Apply consistent resource names and tags
- [ ] Format and validate the Terraform configuration

## Acceptance criteria

- Terraform provisions a working virtual network/VPC
- The subnet and routing configuration provide the required connectivity
- Network security rules follow least privilege
- SSH and application access work as intended
- Terraform formatting and validation pass
- No credentials or private keys are committed

Internal due date: 20 July 2026" \
  --assignee "Sarah-kasande" \
  --label "formative-3,terraform,security,priority-high"

# Issue 3 - Compute Instance
gh issue create \
  --title "Provision the compute instance with Terraform variables and outputs" \
  --body "## Objective

Provision the Linux compute instance that Ansible will configure.

## Tasks

- [ ] Create the compute instance
- [ ] Attach it to the correct subnet
- [ ] Attach the correct security group or NSG
- [ ] Configure SSH key access safely
- [ ] Use variables for environment-specific values
- [ ] Avoid hardcoded secrets and repeated region values
- [ ] Add outputs for the public IP, private IP and resource IDs
- [ ] Review the Terraform plan before applying
- [ ] Apply the infrastructure
- [ ] Confirm manual SSH access

## Acceptance criteria

- The compute instance is successfully created
- The instance is reachable through the approved SSH method
- Variables are used for configurable values
- Outputs expose the information required by Ansible
- A post-apply plan shows no unintended changes
- No Terraform state, credentials or private keys are committed

Internal due date: 20 July 2026" \
  --assignee "Sarah-kasande" \
  --label "formative-3,terraform,priority-high"

# Issue 4 - Terraform Documentation
gh issue create \
  --title "Document Terraform setup, usage and cleanup" \
  --body "## Objective

Create clear documentation for initialising, validating, planning, applying and destroying the Terraform infrastructure.

## Tasks

- [ ] Explain the infrastructure architecture
- [ ] List prerequisites
- [ ] Document required variables
- [ ] Explain safe cloud authentication
- [ ] Document Terraform initialisation
- [ ] Document formatting and validation
- [ ] Document planning and applying
- [ ] Explain outputs and SSH connection
- [ ] Document infrastructure cleanup
- [ ] Add security and cloud-cost warnings
- [ ] Add troubleshooting guidance

## Acceptance criteria

- \`terraform/README.md\` is complete
- Another team member can follow the instructions
- No real secrets appear in examples
- Commands and output names match the actual configuration

Internal due date: 21 July 2026" \
  --assignee "Sarah-kasande" \
  --label "formative-3,terraform,documentation"

# Issue 5 - Ansible Inventory
gh issue create \
  --title "Create Ansible inventory and verify server connectivity" \
  --body "## Objective

Configure Ansible to connect securely to the VM provisioned by Terraform.

## Dependencies

Blocked until Terraform provides a working VM and public IP.

## Tasks

- [ ] Confirm manual SSH access to the VM
- [ ] Create the Ansible inventory
- [ ] Configure the correct SSH user
- [ ] Reference the private key safely
- [ ] Confirm remote Python availability
- [ ] Run an Ansible connectivity test
- [ ] Record successful connectivity evidence

## Acceptance criteria

- Ansible connects successfully to the Terraform-provisioned server
- The inventory is valid and understandable
- No private key or password is committed
- Connectivity instructions are reproducible

Internal due date: 20 July 2026" \
  --assignee "IshimweOlivier-20" \
  --label "formative-3,ansible,priority-high,blocked"

# Issue 6 - Docker Deployment
gh issue create \
  --title "Install Docker and deploy the containerised application with Ansible" \
  --body "## Objective

Use Ansible to prepare the server and deploy the containerised Formative 2 application.

## Tasks

- [ ] Update the server package index
- [ ] Install required system dependencies
- [ ] Install Docker
- [ ] Enable and start the Docker service
- [ ] Configure the deployment user appropriately
- [ ] Obtain or build the application image using the agreed deployment method
- [ ] Start the application container
- [ ] Configure required port mappings
- [ ] Supply environment variables securely
- [ ] Configure a restart policy
- [ ] Verify that the application is available

## Acceptance criteria

- Docker is installed and running
- The application container is running
- The application is reachable through the expected address and port
- Secrets are not hardcoded
- Running the playbook again does not create duplicate containers

Internal due date: 21 July 2026" \
  --assignee "IshimweOlivier-20" \
  --label "formative-3,ansible,integration,priority-high"

# Issue 7 - Firewall Hardening
gh issue create \
  --title "Configure server firewall and SSH hardening with Ansible" \
  --body "## Objective

Apply basic operating-system security to the provisioned server.

## Tasks

- [ ] Deny unnecessary inbound traffic
- [ ] Allow SSH before enabling the firewall
- [ ] Allow the required application port
- [ ] Avoid exposing internal service ports
- [ ] Disable direct root SSH login
- [ ] Disable empty passwords
- [ ] Confirm key-based SSH access
- [ ] Disable password authentication only after key access is verified
- [ ] Validate SSH configuration before reloading the service
- [ ] Confirm a new SSH connection works after hardening

## Acceptance criteria

- Firewall rules allow only required access
- SSH remains accessible through key authentication
- Root and insecure password access are restricted
- Security changes are idempotent
- The application remains available

Internal due date: 21 July 2026" \
  --assignee "IshimweOlivier-20" \
  --label "formative-3,ansible,security,priority-high"

# Issue 8 - Ansible Documentation
gh issue create \
  --title "Document Ansible configuration and deployment process" \
  --body "## Objective

Document how to configure and deploy the application using Ansible.

## Tasks

- [ ] Explain what the playbook configures
- [ ] List prerequisites and required collections
- [ ] Explain inventory configuration
- [ ] Explain SSH key requirements
- [ ] Document the connectivity test
- [ ] Document playbook execution
- [ ] Explain secret handling
- [ ] Document application verification
- [ ] Document the idempotency test
- [ ] Explain firewall and SSH changes
- [ ] Add troubleshooting and recovery guidance

## Acceptance criteria

- \`ansible/README.md\` is complete
- Another team member can follow the instructions
- No secrets appear in the documentation
- Instructions match the actual playbook and inventory

Internal due date: 21 July 2026" \
  --assignee "IshimweOlivier-20" \
  --label "formative-3,ansible,documentation"

# Issue 9 - Audit CI Pipeline
gh issue create \
  --title "Audit and preserve the existing Formative 2 CI pipeline" \
  --body "## Objective

Confirm that the existing Formative 2 CI checks remain functional before security scanning is added.

## Tasks

- [ ] Confirm the workflow triggers correctly
- [ ] Confirm dependencies install successfully
- [ ] Confirm linting runs
- [ ] Confirm tests run
- [ ] Confirm the Docker image builds
- [ ] Confirm failures produce a failed workflow
- [ ] Record a successful baseline workflow run
- [ ] Identify the correct locations of frontend and backend package files

## Acceptance criteria

- Existing Formative 2 CI functionality remains operational
- Baseline evidence is recorded
- The locations requiring dependency scanning are documented
- No existing quality gate is accidentally removed

Internal due date: 20 July 2026" \
  --assignee "Peterobinna" \
  --label "formative-3,devsecops,testing"

# Issue 10 - Dependency Scanning
gh issue create \
  --title "Add dependency and container image scanning to pull requests" \
  --body "## Objective

Add automated dependency and container vulnerability scanning to the existing CI pipeline.

## Tasks

- [ ] Select and document the dependency scanning command
- [ ] Scan all relevant frontend and backend dependencies
- [ ] Define a defensible failure threshold
- [ ] Build the application image in CI
- [ ] Scan the built image with Trivy or the approved equivalent
- [ ] Define container vulnerability severity thresholds
- [ ] Confirm scans run automatically on pull requests
- [ ] Confirm serious findings fail the workflow
- [ ] Record findings for SECURITY.md

## Acceptance criteria

- Dependency scanning runs on every pull request
- Container scanning runs on every pull request
- Both scans inspect the correct targets
- Serious findings block the pull request
- Scan results are visible in GitHub Actions
- No secrets are exposed in logs

Internal due date: 21 July 2026" \
  --assignee "Peterobinna" \
  --label "formative-3,devsecops,security,priority-high"

# Issue 11 - Terraform Scanning
gh issue create \
  --title "Add Terraform security scanning and required CI checks" \
  --body "## Objective

Scan the Terraform configuration automatically and enforce security checks during pull requests.

## Tasks

- [ ] Select Checkov, tfsec or the approved IaC scanner
- [ ] Scan the \`terraform/\` directory
- [ ] Confirm the scanner runs on pull requests
- [ ] Review findings with the Terraform owner
- [ ] Fix valid misconfigurations
- [ ] Document any accepted risks
- [ ] Ensure required CI checks appear in branch protection
- [ ] Confirm failed scans block merging
- [ ] Record a failed scan and corrected rerun

## Acceptance criteria

- IaC scanning runs on every pull request
- Findings are reviewed rather than automatically ignored
- Valid security problems are corrected
- Accepted risks contain a documented rationale
- Security checks are required before merging

Internal due date: 21 July 2026" \
  --assignee "Peterobinna" \
  --label "formative-3,devsecops,terraform,security,priority-high"

# Issue 12 - Security Documentation
gh issue create \
  --title "Create SECURITY.md and document security findings" \
  --body "## Objective

Document the project's security scanning approach, genuine findings, remediation and accepted risks.

## Tasks

- [ ] Document every security scanning tool
- [ ] Record scan targets and pull-request triggers
- [ ] Record severity thresholds
- [ ] Collect genuine findings from the team
- [ ] Record actions taken to resolve findings
- [ ] Record verification results
- [ ] Explain accepted risks
- [ ] Explain how security concerns should be reported
- [ ] Document the project's secret-management approach
- [ ] Review the document with the team

## Acceptance criteria

- \`SECURITY.md\` exists in the repository root
- It documents genuine findings
- Resolved, mitigated and accepted findings are clearly distinguished
- Accepted risks include a rationale
- No vulnerability or result is invented

Internal due date: 21 July 2026" \
  --assignee "SibahleD" \
  --label "formative-3,security,documentation,priority-high"

# Issue 13 - End-to-End Testing
gh issue create \
  --title "Conduct end-to-end testing and collect Formative 3 evidence" \
  --body "## Objective

Verify that Terraform, Ansible, Docker and GitHub Actions work together and preserve evidence of the process.

## Tasks

- [ ] Record Terraform formatting and validation
- [ ] Record Terraform plan and apply
- [ ] Record infrastructure outputs
- [ ] Record the cloud resources
- [ ] Record successful SSH access
- [ ] Record successful Ansible connectivity
- [ ] Record the first Ansible playbook run
- [ ] Record the second idempotent run
- [ ] Record the running application
- [ ] Record all security scan results
- [ ] Record one failed scan and its correction
- [ ] Record branch-protection enforcement
- [ ] Confirm multiple team members contributed and reviewed work

## Acceptance criteria

- Every rubric requirement has supporting evidence
- Evidence does not expose credentials or private keys
- End-to-end deployment succeeds
- Failed and corrected security checks are visible
- Collaboration is visible through issues, commits and reviews

Internal due date: 21 July 2026" \
  --assignee "SibahleD" \
  --label "formative-3,testing,evidence,integration,priority-high"

# Issue 14 - Final Integration
gh issue create \
  --title "Complete final integration, review and Formative 3 submission" \
  --body "## Objective

Integrate all completed Formative 3 work, conduct the final rubric review and merge the approved result into \`main\`.

## Dependencies

This issue cannot be completed until the Terraform, Ansible, security scanning, documentation and evidence issues are complete.

## Tasks

- [ ] Merge approved work into \`formative-3-integration\`
- [ ] Resolve merge conflicts
- [ ] Run the complete local test process
- [ ] Provision the infrastructure
- [ ] Configure the server
- [ ] Deploy and open the application
- [ ] Run all CI and security scans
- [ ] Confirm both specialised READMEs are accurate
- [ ] Confirm SECURITY.md is complete
- [ ] Audit the repository for secrets and Terraform state
- [ ] Open a pull request from \`formative-3-integration\` into \`main\`
- [ ] Obtain at least one approving review
- [ ] Confirm all required checks pass
- [ ] Merge into \`main\`
- [ ] Confirm all required files are visible on \`main\`
- [ ] Submit the repository URL

## Acceptance criteria

- \`terraform/\`, \`ansible/\`, the updated CI workflow and \`SECURITY.md\` are on \`main\`
- All required checks pass
- Branch protection was followed
- No secrets or state files are committed
- The final repository URL is accessible
- Every team member can explain their contribution

## Team participants
**@Sarah-kasande, @IshimweOlivier-20, @SibahleD**

Internal due date: 21 July 2026, internal target: 8:00pm" \
  --assignee "Peterobinna" \
  --label "formative-3,integration,testing,priority-high"

echo "✅ All 13 Formative 3 issues have been created successfully!"
