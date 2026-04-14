# 🐳 Docker Role

An Ansible role that installs and configures **Docker** on **Ubuntu** hosts. It handles the full setup — installation, user group configuration, service management — and uses handlers and variables for a clean, idiomatic Ansible structure.

> ⚠️ **Ubuntu Only** — This role is intentionally scoped to Ubuntu. It will not run on Amazon Linux or other distributions.

---

## 📋 What This Role Does

| Step | Description |
|------|-------------|
| 📦 Install Docker | Installs Docker Engine on Ubuntu using `apt` |
| 👤 Add User to Group | Adds the target user to the `docker` group (no sudo needed for docker commands) |
| 🔢 Show Version | Prints the installed Docker version to confirm successful install |
| ✅ Enable & Restart | Enables Docker on boot and restarts the service |
| 🔁 Handler | Restarts Docker when a configuration change is detected |

---

## 🗂️ Role Structure

```
roles/docker/
├── defaults/
│   └── main.yml          # Default variables (overridable)
├── files/                # (reserved for static files)
├── handlers/
│   └── main.yml          # Restart Docker handler
├── meta/
│   └── main.yml          # Role metadata
├── tasks/
│   └── main.yml          # All Docker install and config tasks
├── templates/            # (reserved for future Jinja2 templates)
├── tests/
│   ├── inventory
│   └── test.yml
└── vars/
    └── main.yml          # Role-level variables (e.g., docker_user)
```

---

## ⚙️ How It Works

### Tasks (`tasks/main.yml`)

The role runs sequentially on Ubuntu hosts:

1. **Install Docker** — Uses `apt` to install `docker.io` (or `docker-ce` depending on your setup)
2. **Add user to docker group** — Uses the `docker_user` variable defined in `vars/main.yml`
3. **Show Docker version** — Runs `docker --version` and prints the output using `debug`
4. **Enable & restart Docker** — Uses the `service` module, and notifies the handler

```yaml
- name: Add user to docker group
  user:
    name: "{{ docker_user }}"
    groups: docker
    append: true
  notify: Restart Docker
```

### Handler (`handlers/main.yml`)

```yaml
- name: Restart Docker
  service:
    name: docker
    state: restarted
    enabled: true
```

The handler fires **only when notified** — keeping restarts minimal and intentional.

### Variables (`vars/main.yml`)

```yaml
docker_user: ubuntu   # The OS user to be added to the docker group
```

You can override this at runtime (see below).

---

## 🚀 How to Run

Make sure you are in the `playbooks/` directory, then run:

```bash
# Using the prod inventory
ansible-playbook -i ../inventories/prod run_role_docker.yml

# Using the dev inventory
ansible-playbook -i ../inventories/dev run_role_docker.yml

# Using the flat hosts.ini file
ansible-playbook -i ../inventories/hosts.ini run_role_docker.yml
```

### The Playbook (`playbooks/run_role_docker.yml`)

```yaml
- name: Install and configure Docker
  hosts: ubuntu       # Target only Ubuntu hosts in your inventory
  become: true
  roles:
    - docker
```

> 💡 Make sure your inventory groups Ubuntu and Amazon Linux hosts separately so this role only targets the right machines.

---

## 📦 Requirements

| Requirement | Detail |
|-------------|--------|
| Ansible | 2.9+ recommended |
| Target OS | Ubuntu 20.04 / 22.04 **only** |
| SSH Access | Key-based auth configured (via Terraform key pair) |
| Privilege | `become: true` required (sudo) |

---

## 🔧 Variables

### `vars/main.yml` (higher precedence)

```yaml
docker_user: ubuntu
```

### `defaults/main.yml` (lowest precedence — safe to override)

Override variables without editing the role files:

```bash
# Change the docker user at runtime
ansible-playbook -i ../inventories/prod run_role_docker.yml -e "docker_user=ec2-user"
```

---

## ✅ Verifying the Deployment

SSH into your Ubuntu EC2 instance and run:

```bash
# Check Docker service status
sudo systemctl status docker

# Verify Docker version
docker --version

# Run a test container (no sudo needed if group was applied)
docker run hello-world
```

> 📝 **Note:** Group changes (`docker` group) take effect on the **next login session**. If you SSH in immediately after the playbook, you may still need `sudo` for Docker commands until you log out and back in.

---

## 📝 Notes

- This role is **Ubuntu-scoped by design**. If you ever need to extend it to Amazon Linux, create separate task files (`install_ubuntu.yml`, `install_amazon.yml`) similar to the Nginx role pattern.
- The `docker` group addition uses `append: true` to avoid removing the user from other existing groups.
- Handlers run **once at the end** of the play, even if notified multiple times during the run.
