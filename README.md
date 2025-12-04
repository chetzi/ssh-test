# SSH Setup & Secure Configuration – Full Guide

**Author:** Chetan Patil
**Platform Used:** GitHub Codespaces (Ubuntu Linux)
**Purpose:** Help juniors learn how to set up and secure an SSH server from scratch.

---

## 🚀 Overview

In this guide, I’ll walk you through everything I did to set up an SSH server, secure it properly, and test it locally.
This is the exact process I followed to complete my SSH configuration practice.

By the end, you will have:

* A running SSH server
* Public-key-only authentication
* Password login disabled
* Root login disabled
* Successful SSH test from another terminal

---

## 🖥️ 1. Creating the Linux VM (Codespaces)

I used **GitHub Codespaces** because it’s free, fast, and works directly in the browser.

Steps I followed:

1. Created a GitHub repo
2. Opened “Create Codespace”
3. Selected the repo and launched a new Ubuntu VM

**Screenshot:**

```
[ INSERT SCREENSHOT OF CODESPACE STARTING ]
```

---

## 🔧 2. Installing the SSH Server

Once the VM was running, I installed OpenSSH:

```bash
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh
```

Checked the service:

```bash
sudo systemctl status ssh
```

**Screenshot:**

```
[ INSERT SCREENSHOT OF SSH ACTIVE/RUNNING ]
```

---

## ✏️ 3. Configuring the SSH Server

The configuration file is located at:

```
/etc/ssh/sshd_config
```

I opened it using:

```bash
sudo nano /etc/ssh/sshd_config
```

Then I edited these three important lines:

### ✔ Enable public key authentication

```
PubkeyAuthentication yes
```

### ✔ Disable password login

```
PasswordAuthentication no
```

### ✔ Block root login

```
PermitRootLogin no
```

Saved and exited (`Ctrl+O`, `Ctrl+X`).

Restarted SSH to apply changes:

```bash
sudo systemctl restart ssh
```

**Screenshot:**

```
[ INSERT SCREENSHOT OF sshd_config ]
```

---

## 🔑 4. Generating SSH Keys

If no keys existed, I created them:

```bash
ssh-keygen
```

Pressed **Enter** for all defaults.

This generated:

* `~/.ssh/id_rsa` → private key
* `~/.ssh/id_rsa.pub` → public key

---

## 🧪 5. Testing SSH Locally

To verify everything, I opened a **second terminal** inside Codespaces.

Then tested SSH into localhost:

```bash
ssh -i ~/.ssh/id_rsa <your-username>@localhost
```

Expected results:

* Login works with keys
* No password prompt
* Root login blocked

**Screenshot:**

```
[ INSERT SCREENSHOT OF SUCCESSFUL SSH TEST ]
```

---

## ✅ Final Result

At the end of this setup, I had:

✔ SSH server running on Ubuntu
✔ Public key authentication working
✔ Password login disabled
✔ Root login blocked
✔ Verified login from a second terminal

This is a secure and professional SSH setup — exactly how real servers should be configured.

---

## 📎 Additional Notes

* Codespaces is great for practicing Linux and SSH.
* These settings make your server almost immune to brute-force attacks.
* You can reuse this configuration in future projects or cloud VMs.

---

If you need help with screenshots, configs, or want an automated script, feel free to ask!
