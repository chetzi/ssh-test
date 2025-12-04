# SSH Setup & Secure Configuration – Step-by-Step (GitHub Codespaces)

**Author:** Chetan Patil
**Platform:** GitHub Codespaces (Ubuntu Linux container)
**Goal:** Show every exact step + command I used to install, configure, and test an SSH server in Codespaces, including how to fix the `systemd` error.

---

## 0. Prerequisites

1. GitHub account
2. A repository to host this setup (example: `ssh-test`)

---

## 1. Create Repo & Start Codespace

### 1.1 Create repository

In GitHub:

1. Click **New repository**
2. Name it: `ssh-test`
3. Check **“Add a README file”**
4. Click **Create repository**

### 1.2 Open Codespace

1. Go to the repo: `https://github.com/<your-username>/ssh-test`
2. Click the green **Code** button
3. Go to the **Codespaces** tab
4. Click **“Create codespace on main”**

Wait until the online VS Code editor opens.

---

## 2. Open Terminal in Codespaces

In the top menu:

* Click **Terminal → New Terminal**

You should see a prompt similar to:

```bash
@<username> ➜ /workspaces/ssh-test (main) $
```

---

## 3. Install OpenSSH Server

Run these commands **in order**:

```bash
# 1) Update package list
sudo apt update

# 2) Install OpenSSH server
sudo apt install openssh-server -y
```

---

## 4. Handle the “systemd is not running” Error

If you try:

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

you will see:

```text
"systemd" is not running in this container due to its overhead.
Use the "service" command to start services instead.
```

This is **normal** in Codespaces.

### Use `service` instead of `systemctl`:

```bash
# Start SSH server
sudo service ssh start

# (Optional) Restart SSH server
sudo service ssh restart

# Check SSH server status
sudo service ssh status
```

You should see something like:

```text
* OpenBSD Secure Shell server sshd
   ...
   [ OK ] sshd is running
```

---

## 5. Generate SSH Keys (If Needed)

Check if you already have keys:

```bash
ls ~/.ssh
```

If you do **not** see `id_rsa` and `id_rsa.pub`, create them:

```bash
ssh-keygen
```

Just press **Enter** for all prompts to accept defaults.

This creates:

* `~/.ssh/id_rsa`      → private key
* `~/.ssh/id_rsa.pub`  → public key

---

## 6. Allow Your Own Key to Log In (authorized_keys)

Add your public key to `authorized_keys`:

```bash
# Make sure .ssh directory exists
mkdir -p ~/.ssh

# Append your public key to authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Set correct permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

---

## 7. Configure the SSH Server (sshd_config)

The main config file is:

```text
/etc/ssh/sshd_config
```

### 7.1 Open the config file

```bash
sudo nano /etc/ssh/sshd_config
```

### 7.2 Minimal secure configuration

Inside `nano`, scroll and either **edit existing lines** or **add these lines** (near the top or bottom is fine):

```text
# --- Custom secure SSH settings (added by Chetan) ---

# Only allow public key authentication
PubkeyAuthentication yes

# Explicitly disable password-based logins
PasswordAuthentication no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no

# Disallow root login over SSH
PermitRootLogin no

# Optional: restrict to IPv4 only (comment out if not needed)
# AddressFamily inet
```

> If any of these lines already exist with different values, update them instead of adding duplicates.

### 7.3 Save and exit

* Press **Ctrl + O**, then **Enter** to save
* Press **Ctrl + X** to exit `nano`

### 7.4 Restart SSH to apply config

```bash
sudo service ssh restart
sudo service ssh status
```

Make sure it’s still **running** and there are **no errors**.

---

## 8. Test SSH Login (Localhost Inside Codespaces)

Open a **second** terminal tab:

* **Terminal → New Terminal**

In the new terminal, run:

```bash
ssh -i ~/.ssh/id_rsa $(whoami)@localhost
```

Explanation:

* `-i ~/.ssh/id_rsa` → use your private key
* `$(whoami)`       → your current username
* `localhost`       → connect to the same container

### Expected behavior

* You **do not** get a password prompt
* You **successfully log in** using your SSH key
* Root login is **not** allowed (you can verify by trying:)

```bash
ssh root@localhost
```

You should see a **“Permission denied”** message.

---

## 9. Summary of All Commands (Cheat Sheet)

For quick copy-paste:

```bash
# --- Install SSH server ---
sudo apt update
sudo apt install openssh-server -y

# --- Start/Restart/Status (Codespaces uses service, not systemctl) ---
sudo service ssh start
sudo service ssh restart
sudo service ssh status

# --- Generate SSH keys (if needed) ---
ssh-keygen

# --- Add public key to authorized_keys ---
mkdir -p ~/.ssh
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# --- Edit SSH config ---
sudo nano /etc/ssh/sshd_config
# (then add the snippet shown above)

# --- Restart SSH after config changes ---
sudo service ssh restart
sudo service ssh status

# --- Test SSH locally inside Codespaces ---
ssh -i ~/.ssh/id_rsa $(whoami)@localhost
```

---

## 10. Final Notes for Juniors

* In **real cloud VMs** (AWS, Azure, etc.) you usually **can** use `systemctl`.
* In **GitHub Codespaces**, you must use `service` because `systemd` is not running.
* Always restart SSH after editing `sshd_config`.
* Public-key-only + no root login is standard hardening for production SSH servers.

You can now reuse this README as a template for your own projects or to help other students.
