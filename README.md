# SSH Server Setup — Complete Beginner-Friendly Guide (Codespaces VM)

This guide explains how to set up an SSH server **from scratch** inside a GitHub Codespaces VM.


You will learn:

* How to create and run a VM in GitHub Codespaces
* How to generate SSH keys
* How to configure SSH server (`sshd`)
* How to enforce **public key authentication only**
* How to disable passwords and root login
* How to fix Codespaces-specific SSH problems
* How to test SSH login
* How to export your `sshd_config` for submission

---

# 1. Starting Your VM in Codespaces

1. Create a new GitHub repository (any name).
2. Click **Code → Codespaces → Create Codespace on main**.
3. Wait for the Codespace to open in VS Code Online.
4. Open the built-in terminal:

```
Terminal → New Terminal
```

This is your **Linux VM**.

---

# 2. Install OpenSSH Server Inside the VM

Run the following:

```bash
sudo apt update
sudo apt install openssh-server -y
```

This installs the SSH server (`sshd`) inside the Codespaces container.

---

# 3. Generate SSH Keys (Inside the VM)

We will generate a new SSH key **inside the VM itself**.

```bash
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
```

When asked for a passphrase → press **Enter** twice.

This creates:

```
~/.ssh/id_ed283894 (its example)       (private key)
~/.ssh/id_ed283894.pub (its example)  (public key)
```

---

# 4. Enable Key Authentication for SSH

Add your **public key** to the server:

```bash
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

This tells the SSH server: **“Allow this VM's key to log in.”**

---

# 5. Edit the SSH Server Config File

Open the SSH configuration:

```bash
sudo nano /etc/ssh/sshd_config
```

Modify/add these lines:

```
PubkeyAuthentication yes
PasswordAuthentication no
PermitRootLogin no
Port 2200
```

Why port 2200?

* Codespaces uses **port 2222** internally, which conflicts with sshd.
* We choose **2200** because it's free and safe.

Save:

* Ctrl + O → Enter
* Ctrl + X

---

# 6. Fix Codespaces SSHD Startup Errors

Codespaces gives two common errors:

### ❗ Error 1:

`sshd re-exec requires execution with an absolute path`

### ❗ Error 2:

`Address already in use` (because port 2222 is taken)

### ✔ Fix:

Run sshd with an **absolute path** and on port **2200**:

```bash
sudo /usr/sbin/sshd -t     # test config
sudo /usr/sbin/sshd -p 2200
```

Now your SSH server is running.

---

# 7. Test SSH Login (VM → VM)

Run:

```bash
ssh -p 2200 -i ~/.ssh/id_ed25519 localhost
```

On first connection:

```
Are you sure you want to continue (yes/no)? → yes
```

You should be logged in **without any password**.

This confirms:

* ✔ Public key authentication works
* ✔ Password login is disabled
* ✔ Root login is disabled
* ✔ sshd is running on port 2200

---

# 8. Export Your sshd_config for Submission

Move the config file into your project folder:

```bash
cp /etc/ssh/sshd_config /workspaces/ssh-test/sshd_config
```

Now the file appears in the VS Code explorer so you can submit it.

---

# 9. Final Summary 

By following this guide, you learned:

* How to work inside a VM on GitHub Codespaces
* How to install and configure an SSH server
* How to secure SSH using public-key-only authentication
* How to disable password and root login
* How to fix Codespaces-specific SSHD issues
* How to test SSH logins
* How to export config files

This completes **Exercise 2** exactly as required.
