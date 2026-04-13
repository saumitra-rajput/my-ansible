# Ansible Commands — Topic-wise Reference Notes

---

## 1. SSH Key Setup

```bash
cd ~/.ssh/
ssh-keygen                          # Generate SSH key pair
cat ansible.pub                     # View the public key
```

---

## 2. Ansible Inventory (Hosts File)

```bash
cd /etc/ansible/
vim hosts                           # Edit the default hosts inventory file
cat hosts | tail -10                # View last 10 lines of hosts file
sudo chmod 644 hosts                # Set correct permissions on hosts file
```

---

## 3. Ad-hoc Commands (Ping & System Info)

```bash
ansible server -m ping              # Ping 'server' group
ansible amazon -m ping              # Ping 'amazon' group
ansible all -m ping                 # Ping all hosts

ansible server -a "uptime"          # Check uptime
ansible server -a "date"            # Check date
ansible server -a "uname"           # Check kernel info
ansible server -a "cat /etc/os-release"   # Check OS release info
```

---

## 4. Ansible Facts / Setup Module

```bash
ansible server -m setup                              # Gather all facts from server group
ansible server -m setup | grep "ansible_os_family"  # Filter OS family fact
ansible server -m setup | grep distribution          # Filter distribution info
```

---

## 5. Playbook — Basic Examples

```bash
# showdate.yml
ansible-playbook showdate.yml
ansible-playbook showdate.yml -v        # Verbose output

# hello.yml
ansible-playbook hello.yml
ansible-playbook hello.yml -v
ansible-playbook hello.yml --check      # Dry run (no changes applied)
```

---

## 6. Playbook — Package Management (Conditional)

```bash
vim package_check.yml
ansible-playbook package_check.yml
ansible-playbook package_check.yml -v

# Useful for checking installed packages
apt list | grep docker
```

---

## 7. Playbook — Nginx Setup

```bash
vim install_nginx.yml
ansible-playbook install_nginx.yml     # Install nginx via playbook

vim setup_nginx.yml
ansible-playbook setup_nginx.yml       # Full nginx setup with config/index.html

# Ad-hoc nginx install using inventory file
ansible -i hosts.ini server -a "apt-get install nginx" --become
ansible -i hosts.ini server -a "apt-get install nginx" --become -v
```

---

## 8. Playbook — Loops

```bash
vim loop.yml
ansible-playbook loop.yml              # Run loop-based playbook
```

---

## 9. Custom Inventory (inventories/)

```bash
mkdir inventories
vim dev.yml                            # Create dev inventory (YAML format)
mv dev.yml dev                         # Rename to plain inventory file

ansible -i dev dev -m ping             # Use custom inventory for ping

vim hosts.ini                          # INI-format custom inventory
mv hosts.ini inventories/              # Move to inventories folder
```

---

## 10. Ansible Vault (Secrets Management)

```bash
vim secret.yml                         # Create secret variables file
vim vault_password.txt                 # Create vault password file

ansible-vault encrypt secret.yml --vault-password-file vault_password.txt   # Encrypt secrets

vim show_secret.yml                    # Playbook that uses secrets
ansible-playbook show_secret.yml --vault-password-file vault_password.txt   # Run with vault
```

---

## 11. Ansible Roles

```bash
ansible-galaxy init role/docker        # Initialize a new role structure

# Edit role files
vim roles/docker/tasks/main.yml        # Define tasks
vim roles/docker/handlers/main.yml     # Define handlers
vim roles/docker/vars/main.yml         # Define variables

# Playbook using a role
vim install_docker_with_role.yml
ansible-playbook install_docker_with_role.yml

mv role/ roles                         # Rename role directory to 'roles' (Ansible convention)
mv roles/ playbooks/                   # Move roles inside playbooks directory
```

---

## Notes

- Always use `--check` flag for a **dry run** before applying changes.
- Use `-v` or `-vv` for **verbose** output when debugging playbooks.
- Keep secrets in **Ansible Vault**; never store plaintext passwords in YAML files.
- Follow Ansible **role directory structure** (`tasks/`, `handlers/`, `vars/`, `defaults/`, `templates/`) when using `ansible-galaxy init`.
- Use **custom inventories** (`-i`) instead of editing `/etc/ansible/hosts` for environment-specific configs (dev, staging, prod).
- `--become` flag is required for commands that need **sudo/root** privileges on remote hosts.

---

