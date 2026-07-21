# PocketPal Terraform Infrastructure

This directory contains the Terraform configuration used to provision the AWS infrastructure required by the PocketPal application.

## Infrastructure provisioned

The configuration creates:

- One AWS VPC
- One public subnet
- One internet gateway
- One public route table
- One default route to the internet
- One route-table association
- One security group
- One Ubuntu EC2 instance
- One encrypted EBS root volume
- One automatically assigned public IPv4 address

Terraform outputs expose the resource IDs, public IP address, public DNS name, application URLs and an example SSH command.

## Architecture

The EC2 instance is placed inside a public subnet. The subnet uses a route table that sends internet-bound traffic through the VPC internet gateway.

The security group permits:

- SSH on port 22 from one trusted IPv4 address
- Frontend traffic on port 5173
- Backend API traffic on port 5000
- Required outbound traffic for operating-system packages and container images

SSH is not open to the entire internet.

## Prerequisites

Before using this configuration, install:

- Terraform 1.5 or later
- AWS CLI version 2
- Git
- OpenSSH

You must also have:

- An AWS IAM user or role with the required EC2 and VPC permissions
- An existing EC2 key pair in the deployment region
- Your current public IPv4 address

Do not use the AWS root user for Terraform.

## AWS authentication

Authenticate using the approved AWS CLI profile:

```powershell
aws login --profile course
```

Set the profile for the current PowerShell terminal:

```powershell
$env:AWS_PROFILE="course"
```

Confirm the active identity:

```powershell
aws sts get-caller-identity
```

The returned ARN must identify an IAM user or assumed role. It must not end with `:root`.

Confirm the configured region:

```powershell
aws configure get region --profile course
```

## Prepare the variable file

From the repository root, enter the Terraform directory:

```powershell
cd terraform
```

Copy the example variable file:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and replace the example values.

The SSH CIDR should be one trusted public IPv4 address followed by `/32`:

```hcl
ssh_allowed_cidr = "203.0.113.10/32"
```

The EC2 key-pair name must already exist in the selected AWS region:

```hcl
ssh_key_name = "pocketpal-course-key"
```

Do not add AWS credentials to any Terraform file.

## Initialise Terraform

Download the required Terraform provider:

```powershell
terraform init
```

Terraform will create a local `.terraform` directory and a provider lock file.

## Format the configuration

```powershell
terraform fmt -recursive
```

To check formatting without changing files:

```powershell
terraform fmt -recursive -check
```

## Validate the configuration

```powershell
terraform validate
```

A valid configuration should return:

```text
Success! The configuration is valid.
```

## Review the execution plan

Create and save a Terraform plan:

```powershell
terraform plan -out=tfplan
```

Review the proposed resources carefully. The plan should create the PocketPal networking components, security group and EC2 instance.

It should not delete unrelated AWS resources.

## Apply the infrastructure

Apply the reviewed plan:

```powershell
terraform apply tfplan
```

Terraform will provision the AWS infrastructure and display the configured outputs.

## View outputs

Display all outputs:

```powershell
terraform output
```

Display only the public IP:

```powershell
terraform output -raw instance_public_ip
```

Display the example SSH command:

```powershell
terraform output -raw ssh_command
```

## Connect to the server

The EC2 instance uses the Ubuntu account:

```powershell
ssh -i "$HOME\.ssh\pocketpal-course-key.pem" ubuntu@PUBLIC_IP
```

Replace `PUBLIC_IP` with the value returned by:

```powershell
terraform output -raw instance_public_ip
```

The Ansible configuration in this repository will later install Docker, deploy PocketPal and apply operating-system security settings.

## Destroy the infrastructure

AWS resources may generate charges while they are running. Remove the coursework infrastructure when it is no longer required:

```powershell
terraform plan -destroy
```

Then run:

```powershell
terraform destroy
```

Review the destruction plan before confirming.

## Security precautions

Never commit:

- AWS access keys
- AWS secret access keys
- AWS session tokens
- SSH private keys
- `terraform.tfvars`
- Terraform state files
- Saved Terraform plan files
- The `.terraform` working directory

The SSH private key must remain outside this repository.

Terraform state can contain infrastructure information and must be protected. This coursework currently uses local state. A production implementation should use an encrypted remote backend with state locking and tightly controlled access.

## Important files

| File | Purpose |
|---|---|
| `providers.tf` | Defines Terraform and AWS provider requirements |
| `variables.tf` | Declares reusable input variables and validation |
| `main.tf` | Provisions the AWS networking, security and compute resources |
| `outputs.tf` | Exposes infrastructure identifiers and connection details |
| `terraform.tfvars.example` | Documents the expected environment-specific values |
| `README.md` | Explains how to validate, provision and remove the infrastructure |