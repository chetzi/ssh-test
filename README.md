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
cat ~/.ssh/id_ed283894.pub >> ~/.ssh/authorized_keys
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
ssh -p 2200 -i ~/.ssh/id_ed283894 localhost
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


  ## Exercise 5 – Private Equality Testing (PEQ)

This exercise implements the protocol from Section 4.8, where Alice and Bob want to check if their private values `x` and `y` are equal **without revealing anything else** when they differ. The protocol uses a **PRF** built from a **block cipher (AES)** via OpenSSL.

---

### PRF Construction

We define a pseudorandom function (F_k(m)) using a shared secret key `k` stored in `key.bin`:

1. Compute SHA-256 of the message `m`.
2. Take the first 16 bytes (32 hex chars) of the hash.
3. Encrypt that 16-byte block with **AES-128-ECB** under key `k`.
4. The ciphertext is interpreted as the PRF output:

[
F_k(m) = \text{AES-128-ECB}_k(\text{first 16 bytes of SHA256}(m))
]

This matches the idea from Section 4.4.3 that a block cipher can be used as a PRF.

---

### Protocol Overview

**Shared setup**

* Alice and Bob both have the same secret key `k` in `key.bin`.

**Alice (input `x`)**

1. Generate a fresh 16-byte random nonce `r` (hex string).
2. Compute:

   ```text
   token = F_k(x || r)
   ```
3. Send **`r`** and **`token`** to Bob.
4. Alice never sends `x` directly.

**Bob (input `y`)**

1. Receive `r` and `token` from Alice.
2. Compute:

   ```text
   token_b = F_k(y || r)
   ```
3. Compare:

   * If `token_b == token` → conclude `x == y`.
   * Else → conclude `x != y`.

Bob only learns whether the values are equal; he does not learn anything else about `x` when they differ.

---

### Security Intuition

* The PRF output looks random to anyone who does not know `k`.
* The nonce `r` ensures that even if the same `x` is used twice, the resulting tokens look unrelated.
* Alice cannot cheat and force equality unless `x == y`, because she does not know `y` or the PRF output on `y || r`.
* Bob cannot recover `x` from `token`, since reversing AES-128-ECB as a PRF is computationally infeasible.

Overall, the protocol leaks only **one bit** of information: whether `x == y`.

---

### How to Run `peq.sh`

From inside the project directory:

1. Make the script executable (once):

   ```bash
   chmod +x peq.sh
   ```

2. Generate the shared key:

   ```bash
   ./peq.sh genkey
   ```

   This creates a random 16-byte key in `key.bin`.

3. Alice’s side:

   ```bash
   ./peq.sh alice <x>
   ```

   Example output:

   ```text
   Alice output (send this to Bob):
   r      = d6eafff96c090c43874d5ee3b1e0a5df
   token  = e62085f16475871280e238062386d550d8b4
   ```

4. Bob’s side (same value):

   ```bash
   ./peq.sh bob <y> <r> <token>
   ```

   If `y` is the same as `x`, the script prints:

   ```text
   Result: x == y (values are equal).
   ```

5. Bob’s side (different value):

   If `y` is different from `x`, the script prints:

   ```text
   Result: x != y (values differ).
   ```

This demonstrates a complete working implementation of private equality testing using a PRF built from AES and OpenSSL.



