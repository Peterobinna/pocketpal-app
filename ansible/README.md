# Ansible Deployment Guide

## Overview

This directory contains the Ansible configuration used to automate the deployment of the PocketPal application on an AWS EC2 Ubuntu server.

The playbook installs Docker, deploys the PocketPal application using Docker Compose, configures the server firewall, and verifies that the application containers are running.

---

# Directory Structure

```
ansible/
├── ansible.cfg
├── inventory.ini
├── playbook.yml
├── README.md
├── group_vars/
│   └── all.yml
└── roles/
    ├── docker/
    │   └── tasks/
    │       └── main.yml
    ├── application/
    │   └── tasks/
    │       └── main.yml
    └── security/
        └── tasks/
            └── main.yml
```

---

# Prerequisites

Before running the playbook, ensure the following requirements are met:

- Ubuntu Linux or Windows with WSL
- Ansible installed
- community.docker collection installed
- community.general collection installed
- Docker installed on the target server (or installed by the playbook)
- Access to the AWS EC2 instance
- SSH private key (.pem)
- EC2 public IP address

---

# Required Ansible Collections

Install the required collections before running the playbook.

```bash
ansible-galaxy collection install community.docker
ansible-galaxy collection install community.general
```

---

# Configure the Inventory

Update `inventory.ini` with the correct server information.

Example:

```ini
[web]
pocketpal ansible_host=YOUR_EC2_PUBLIC_IP

[web:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/YOUR_KEY_NAME.pem
ansible_python_interpreter=/usr/bin/python3
```

Replace:

- `YOUR_EC2_PUBLIC_IP`
- `YOUR_KEY_NAME.pem`

with the actual deployment values.

---

# Verify Connectivity

Test communication with the server before deployment.

```bash
ansible -i inventory.ini web -m ping
```

A successful response should return:

```
SUCCESS => {
    "ping": "pong"
}
```

---

# Validate the Playbook

Run a syntax check before deployment.

```bash
ansible-playbook --syntax-check -i inventory.ini playbook.yml
```

---

# Deploy the Application

Run the playbook using:

```bash
ansible-playbook -i inventory.ini playbook.yml
```

The playbook performs the following tasks:

- Updates package repositories
- Installs Docker
- Enables and starts the Docker service
- Clones the PocketPal repository
- Builds and starts the application containers
- Configures the firewall
- Verifies that the containers are running

---

# Verify the Deployment

After deployment, verify the application.

Check running containers:

```bash
docker ps
```

Open the application in a browser.

Frontend:

```
http://EC2_PUBLIC_IP:5173
```

Backend:

```
http://EC2_PUBLIC_IP:5000
```

---

# Idempotency

The playbook is designed to be idempotent.

Running it multiple times should not create duplicate resources or cause unnecessary configuration changes.

Run the deployment again using:

```bash
ansible-playbook -i inventory.ini playbook.yml
```

---

# Security

This deployment follows several security practices:

- SSH authentication uses a private key.
- Root login is disabled through the operating system configuration.
- Only required ports are opened.
- Secrets are not stored in the repository.
- Docker runs as a managed service.

---

# Troubleshooting

## Unable to connect

Verify:

- EC2 instance is running
- Public IP address is correct
- SSH key is correct
- Security Group allows SSH access

## Docker deployment fails

Check Docker status.

```bash
sudo systemctl status docker
```

View container logs.

```bash
docker compose logs
```

## Firewall blocks access

Verify UFW rules.

```bash
sudo ufw status
```

---


