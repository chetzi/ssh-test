# SSH Setup & Secure Configuration – Full Guide

**Author:** Chetan Patil
**Platform Used:** GitHub Codespaces (Ubuntu Linux)
**Purpose:** Help juniors learn how to set up a Linux VM and configure SSH securely.

---

## 🚀 Overview

This guide explains every step I followed to:

* Create a Linux virtual machine using **GitHub Codespaces**
* Install OpenSSH server
* Configure secure SSH authentication
* Test SSH in a safe environment
* Understand why these settings matter

This is perfect for beginners who want to practice Linux + SSH without using a real server.

---

# 🖥️ 1. Creating a Linux VM in GitHub Codespaces

GitHub Codespaces gives you a **free cloud-based Ubuntu VM** that runs directly in your browser. No installation needed.

### **Steps I followed:**

### **1️⃣ Create a GitHub repository**

Any name works (example: `ssh-test`).

### **2️⃣ Add at least one file (Important!)**

Because Codespaces **cannot launch on an empty repo**, I added a simple README file.

### **3️⃣ Open Codespace**

* Go to your repo
* Click **Code** → **Codespaces** → **Create codespace on main**
* A full Ubuntu VM starts in ~10 seconds

You will see something like **VS Code running in your browser**.

### **4️⃣ Open the terminal**

Click:
**Terminal → New Terminal**

This gives you full Linux shell access.

**Screenshot:**

```
[ INSERT SCREENSHOT OF CODESPACE STARTING ]
```

---

# 🔧 2. Installing the SSH Server in Codespaces

Once inside the Linux VM terminal, I installed OpenSSH server:

```bash
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh
```

Then I checked status:

```bash
sudo systemctl status ssh
```

You should see **active (running)**.

**Screenshot:**

```
[ INSERT SCREENSHOT OF SSH ACTIVE/RUNNING ]
```

---

# ✏️ 3. Configuring the SSH Server

The SSH config file is located at:

```
/etc/ssh/sshd_config
```

I opened it using:

```bash
sudo nano /etc/ssh/sshd_config
```

Then I modified these lines:

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

Saved + exited:

* `Ctrl + O` → Save
* `Ctrl + X` → Exit

Restarted SSH:

```bash
sudo systemctl restart ssh
```

**Screenshot:**

```
[ INSERT SCREENSHOT OF sshd_config ]
```

---

# 🔑 4. Generating SSH Keys (If Not Already Present)

```bash
ssh-keygen
```

Pressed **Enter** for all defaults.

This created:

* `~/.ssh/id_rsa` → private key
* `~/.ssh/id_rsa.pub` → public key

These keys allow secure login without passwords.

---

# 🧪 5. Testing SSH Locally Inside Codespaces

Codespaces allows multiple terminals, so I tested SSH from a second one.

1. Open another terminal tab
2. Run:

```bash
ssh -i ~/.ssh/id_rsa $(whoami)@localhost
```

If everything is correct:

✔ No password prompt
✔ Login succeeds
✔ Root login blocked

**Screenshot:**

```
[ INSERT SCREENSHOT OF SUCCESSFUL SSH TEST ]
```

---

# 🚨 Notes for Beginners

* You cannot SSH *into* the Codespace from your laptop, because GitHub blocks port 22.
* But testing via **localhost** inside Codespaces is totally valid.
* This is the easiest way to practice SSH server configuration safely.

---

# ✅ Final Result

After following these steps, I achieved:

✔ A fully working Ubuntu VM inside GitHub Codespaces
✔ SSH server installed
✔ Public key authentication enabled
✔ Password authentication disabled
✔ Root login disabled
✔ Successful SSH test
✔ Security settings similar to real production servers

---

# 📎 Additional Advice for Juniors

* Try breaking and fixing the `sshd_config` file to learn more.
* Understanding SSH security helps in cloud jobs and DevOps.
* Codespaces is a great free environment for practicing Linux commands.

---

If you want, I can also create:
📄 A **PDF report**
🛠️ An **automation script**
📦 A **zip file with all configs**

Just ask!
