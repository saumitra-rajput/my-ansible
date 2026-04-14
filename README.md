# ⚙️ Ansible + Terraform Lab

A hands-on infrastructure automation project that uses **Terraform** to provision EC2 instances on AWS and **Ansible** to configure them — installing Nginx and Docker across Ubuntu and Amazon Linux hosts.

Built as a learning project covering: IaC with Terraform, Ansible roles, OS-aware task execution, Ansible Vault, and custom inventories.

---

## 🏗️ Architecture Overview

```
                        ┌─────────────────────────────────┐
                        │            AWS Cloud            │
                        │                                 │
  terraform apply ────► │  EC2 (Ubuntu)  EC2 (Amazon Linux│
                        │       │               │         │
                        └───────┼───────────────┼─────────┘
                                │               │
  ansible-playbook ─────────────┴───────────────┘
        │
        ├── nginx role  →  installs Nginx on both (OS-aware)
        └── docker role →  installs Docker on Ubuntu only
```

---

## 📁 Project Structure

```
.
├── infra/                    # Terraform — provisions AWS infrastructure
│   ├── ec2.tf                # EC2 instance definitions (Ubuntu + Amazon Linux)
│   ├── key_pair.tf           # SSH key pair for Ansible access
│   ├── security_group.tf     # Opens ports 22 (SSH) and 80 (HTTP)
│   ├── providers.tf          # AWS provider config
│   ├── variables.tf          # Input variables (region, instance type, etc.)
│   └── terraform.tf          # Terraform version/backend config
│
├── inventories/              # Ansible inventories
│   ├── hosts.ini             # Flat inventory file (quick use)
│   ├── dev/                  # Dev environment inventory
│   └── prod/                 # Prod environment inventory
│
├── playbooks/                # Ansible playbooks
│   ├── run_role_nginx.yml    # Runs the nginx role
│   ├── run_role_docker.yml   # Runs the docker role
│   ├── install_nginx.yml     # Ad-hoc nginx install (no role)
│   ├── setup_nginx.yml       # Nginx setup with custom index.html
│   ├── hello.yml             # Basic connectivity test
│   ├── showdate.yml          # Shows date on remote hosts
│   ├── loop.yml              # Loop examples
│   ├── package_check.yml     # Checks installed packages
│   ├── secret.yml            # Creates an Ansible Vault secret
│   └── show_secret.yml       # Reads and displays vault secret
│
└── roles/
    ├── nginx/                # Nginx role (Ubuntu + Amazon Linux)
    │   ├── tasks/
    │   │   ├── main.yml          # OS detection + conditional include
    │   │   ├── install_ubuntu.yml
    │   │   └── install_amazon.yml
    │   ├── handlers/main.yml     # Restart Nginx handler
    │   ├── files/index.html      # Custom HTML page served by Nginx
    │   └── vars/main.yml
    │
    └── docker/               # Docker role (Ubuntu only)
        ├── tasks/main.yml        # Install, group, version, enable
        ├── handlers/main.yml     # Restart Docker handler
        └── vars/main.yml         # docker_user variable
```

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version |
|------|---------|
| Terraform | 1.0+ |
| Ansible | 2.9+ |
| AWS CLI | Configured with credentials |
| Python | 3.8+ (for Ansible) |

---

## Step 1 — Provision Infrastructure with Terraform

```bash
cd infra/

# Initialise providers
terraform init

# Preview what will be created
terraform plan

# Create the EC2 instances, key pair, and security group
terraform apply
```

This will spin up:
- 1x **Ubuntu** EC2 instance
- 1x **Amazon Linux** EC2 instance
- SSH key pair (`ansible.pub`) for Ansible access
- Security group with ports **22** and **80** open

> After `apply`, note the **public IPs** from the output and update your inventory files.

---

## Step 2 — Update Inventory

Edit `inventories/prod` or `inventories/hosts.ini` with the EC2 public IPs:

```ini
[ubuntu]
<ubuntu-ec2-public-ip> ansible_user=ubuntu ansible_ssh_private_key_file=../infra/ansible.pem

[amazon]
<amazon-ec2-public-ip> ansible_user=ec2-user ansible_ssh_private_key_file=../infra/ansible.pem
```

> 💡 Keep `ubuntu` and `amazon` as separate inventory groups so role targeting works correctly.

---

## Step 3 — Run Ansible Playbooks

All playbook commands are run from the `playbooks/` directory:

```bash
cd playbooks/
```

### 🌐 Deploy Nginx (Ubuntu + Amazon Linux)

```bash
ansible-playbook -i ../inventories/prod run_role_nginx.yml
```

Installs Nginx on all hosts, serves a custom `index.html`, and enables the service.

### 🐳 Deploy Docker (Ubuntu only)

```bash
ansible-playbook -i ../inventories/prod run_role_docker.yml
```

Installs Docker, adds the user to the `docker` group, and enables the service.

### 🔍 Test Connectivity

```bash
ansible-playbook -i ../inventories/prod hello.yml
```

---

## 🎭 Ansible Roles

### `roles/nginx` — Multi-distro Nginx

Detects the OS using `ansible_facts['distribution']` and runs the correct install tasks automatically.

| Feature | Detail |
|---------|--------|
| Supported OS | Ubuntu, Amazon Linux |
| Custom page | `files/index.html` copied to web root |
| Handler | Restarts Nginx on config change |
| Service | Enabled on boot |

→ See [`roles/nginx/README.md`](roles/nginx/README.md) for full details.

---

### `roles/docker` — Docker on Ubuntu

| Feature | Detail |
|---------|--------|
| Supported OS | Ubuntu only |
| User group | Adds user to `docker` group (no sudo required) |
| Version check | Prints installed Docker version |
| Handler | Restarts Docker on config change |
| Variable | `docker_user` (default: `ubuntu`) |

→ See [`roles/docker/README.md`](roles/docker/README.md) for full details.

---

## 🔐 Ansible Vault

Sensitive variables (passwords, secrets) are encrypted using **Ansible Vault**.

```bash
# Create/encrypt a secret
ansible-playbook -i ../inventories/prod secret.yml --ask-vault-pass

# View a secret (decrypted at runtime)
ansible-playbook -i ../inventories/prod show_secret.yml --ask-vault-pass

# Or use the vault password file (do NOT commit this)
ansible-playbook -i ../inventories/prod show_secret.yml --vault-password-file vault_password.txt
```

> ⚠️ `vault_password.txt` is listed in `.gitignore` and should **never** be committed to version control.

---

## 🧪 Other Playbooks

| Playbook | What it does |
|----------|-------------|
| `hello.yml` | Ping all hosts — sanity check |
| `showdate.yml` | Print date/time on remote hosts |
| `loop.yml` | Demonstrates Ansible loop syntax |
| `package_check.yml` | Lists installed packages on hosts |
| `install_nginx.yml` | Installs Nginx without using a role |
| `setup_nginx.yml` | Installs Nginx and deploys `index.html` ad-hoc |

Run any of them with:

```bash
ansible-playbook -i ../inventories/prod <playbook-name>.yml
```

---

## 🧹 Teardown

When done, destroy the infrastructure to avoid AWS charges:

```bash
cd infra/
terraform destroy
```

---

## 💡 Things to Add Next

Ideas to extend this project further:

- [ ] **Dynamic inventory** — Auto-pull EC2 IPs from AWS instead of updating `hosts.ini` manually (`aws_ec2` plugin)
- [ ] **Ansible Vault best practices** — Store all secrets in a `group_vars/all/vault.yml` file
- [ ] **Tags** — Add `--tags` to playbooks to run only specific steps (e.g., `--tags install`)
- [ ] **Docker Compose role** — Extend docker role to deploy a `docker-compose.yml`
- [ ] **HTTPS with Certbot** — Add an SSL role using Let's Encrypt
- [ ] **GitHub Actions CI** — Lint playbooks with `ansible-lint` on every push
- [ ] **Multiple environments** — Fully flesh out `dev/` and `prod/` inventory directories with `group_vars`

---

## 📚 What I Learned

- Provisioning cloud infrastructure with Terraform (EC2, key pairs, security groups)
- Writing reusable Ansible **roles** with handlers, vars, and files
- **OS-aware** task execution using `ansible_facts['distribution']`
- Encrypting secrets with **Ansible Vault**
- Structuring inventories for multiple environments (`dev`, `prod`)
- Idempotent playbook design — safe to run multiple times

---

## 🛠️ Tech Stack

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=flat&logo=ansible&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat&logo=amazon-aws&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat&logo=ubuntu&logoColor=white)
