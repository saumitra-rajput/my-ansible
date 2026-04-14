# 🌐 Nginx Role

An Ansible role that installs and configures **Nginx** across multiple Linux distributions. It detects the OS automatically and runs the appropriate installation steps — serving a custom `index.html` on both **Ubuntu** and **Amazon Linux**.

---

## 📋 What This Role Does

| Step | Description |
|------|-------------|
| 🔍 OS Detection | Detects whether the host is Ubuntu or Amazon Linux |
| 📦 Install Nginx | Runs the correct install task for the detected OS |
| 📄 Deploy Custom Page | Copies `files/index.html` to the web root |
| ✅ Enable & Start | Enables Nginx on boot and ensures the service is running |
| 🔁 Handler | Restarts Nginx automatically when a change is detected |

---

## 🗂️ Role Structure

```
roles/nginx/
├── defaults/
│   └── main.yml          # Default variables (overridable)
├── files/
│   └── index.html        # Custom HTML page served by Nginx
├── handlers/
│   └── main.yml          # Restart Nginx handler
├── meta/
│   └── main.yml          # Role metadata
├── tasks/
│   ├── main.yml          # Entry point — detects OS and includes correct task file
│   ├── install_ubuntu.yml    # Ubuntu-specific install steps (apt)
│   └── install_amazon.yml    # Amazon Linux-specific install steps (yum/dnf)
├── templates/            # (reserved for future Jinja2 templates)
├── tests/
│   ├── inventory
│   └── test.yml
└── vars/
    └── main.yml          # Role-level variables
```

---

## ⚙️ How It Works

### OS Detection (`tasks/main.yml`)

The main task file uses `ansible_facts['distribution']` to conditionally include the right install file:

```yaml
# Runs on Ubuntu hosts
- include_tasks: install_ubuntu.yml
  when: ansible_facts['distribution'] == "Ubuntu"

# Runs on Amazon Linux hosts
- include_tasks: install_amazon.yml
  when: ansible_facts['distribution'] == "Amazon"
```

### Ubuntu (`install_ubuntu.yml`)
- Uses `apt` to install Nginx
- Copies `files/index.html` to `/var/www/html/index.html`
- Enables and starts the `nginx` service
- Notifies the **Restart Nginx** handler on change

### Amazon Linux (`install_amazon.yml`)
- Uses `yum` / `dnf` to install Nginx
- Copies `files/index.html` to the appropriate web root
- Enables and starts the `nginx` service
- Notifies the **Restart Nginx** handler on change

### Handler (`handlers/main.yml`)
```yaml
- name: Restart Nginx
  service:
    name: nginx
    state: restarted
```
The handler only fires when a task explicitly notifies it — avoiding unnecessary restarts.

---

## 🚀 How to Run

Make sure you are in the `playbooks/` directory, then run:

```bash
# Using the prod inventory
ansible-playbook -i ../inventories/prod run_role_nginx.yml

# Using the dev inventory
ansible-playbook -i ../inventories/dev run_role_nginx.yml

# Using the flat hosts.ini file
ansible-playbook -i ../inventories/hosts.ini run_role_nginx.yml
```

### The Playbook (`playbooks/run_role_nginx.yml`)

```yaml
- name: Install and configure Nginx
  hosts: all
  become: true
  roles:
    - nginx
```

---

## 📦 Requirements

| Requirement | Detail |
|-------------|--------|
| Ansible | 2.9+ recommended |
| Target OS | Ubuntu 20.04/22.04 or Amazon Linux 2/2023 |
| SSH Access | Key-based auth configured (via Terraform key pair) |
| Privilege | `become: true` required (sudo) |

---

## 🔧 Variables

### `vars/main.yml`
Role-level variables that apply across all distributions.

### `defaults/main.yml`
Default variables with the lowest precedence — can be overridden from inventory, playbook, or command line.

```bash
# Override a variable at runtime
ansible-playbook -i ../inventories/prod run_role_nginx.yml -e "nginx_port=8080"
```

---

## ✅ Verifying the Deployment

After the playbook runs, grab the public IP of your EC2 instance and open it in a browser:

```
http://<your-ec2-public-ip>
```

You should see your custom `index.html` page served by Nginx.

Or verify via terminal:

```bash
curl http://<your-ec2-public-ip>
```

---

## 📝 Notes

- The `files/index.html` is a **static file** copied as-is. For dynamic content, move it to `templates/` and use Jinja2 (`.j2` extension).
- Handlers run **once at the end** of the play, even if notified multiple times.
- To force a restart without changes, use `--extra-vars "force_restart=true"` with a conditional task.
