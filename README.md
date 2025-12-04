# Exercise 2 – SSH Server Setup (GitHub Codespaces)

This README documents every step I followed to set up an SSH server inside a GitHub Codespaces VM as required:

* ✔ Enable **public key authentication**
* ✔ Disable **password authentication**
* ✔ Disable **root login**
* ✔ Fix Codespaces SSHD issues
* ✔ Run SSHD on a non-conflicting port
* ✔ Test SSH login using keys
* ✔ Export sshd_config for submission

---

## 1. Generate SSH Key Pair *inside the Codespaces VM*

I chose to generate the SSH key pair directly inside the VM:

```bash
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
```

When prompted:

* Pressed **Enter** to accept default path
* Pressed **Enter** twice for no passphrase

This created:

* `~/.ssh/id_ed25519` — private key
* `~/.ssh/id_ed25519.pub` — public key

---

## 2. Install the Public Key into the SSH Server

I added the public key to `authorized_keys`:

```bash
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

This allows the server to authenticate me via SSH without a password.

---

## 3. Edit `/etc/ssh/sshd_config`

I opened the SSH server configuration:

```bash
sudo nano /etc/ssh/sshd_config
```

I made sure these settings are present (uncommented and correct):

```text
PubkeyAuthentication yes
PasswordAuthentication no
PermitRootLogin no
Port 2200
```

I used **Port 2200** because Codespaces internally uses port **2222**, which conflicts with sshd.

Saved using:

* Ctrl + O → Enter
* Ctrl + X

---

## 4. Fix Codespaces “re-exec requires absolute path” error

Codespaces containers cannot restart sshd using `service ssh` due to systemd restrictions.

I tested config:

```bash
sudo /usr/sbin/sshd -t
```

Then started sshd using an absolute path:

```bash
sudo /usr/sbin/sshd -p 2200
```

This successfully launched the SSH server on port 2200.

---

## 5. Test SSH Using Keys (Local VM → VM)

I verified that the SSH server works and only accepts keys:

```bash
ssh -p 2200 -i ~/.ssh/id_ed25519 localhost
```

After typing `yes` on the first connection prompt, SSH logged me in **without a password**:

* ✔ Public Key Authentication works
* ✔ Password Authentication is disabled
* ✔ Root Login disabled
* ✔ SSHD successfully running on port 2200

---

## 6. Export `sshd_config` for submission

To submit the config file, I exported it into my workspace:

```bash
cp /etc/ssh/sshd_config /workspaces/ssh-test/sshd_config
```

Now `sshd_config` appears in VS Code Explorer and can be submitted.

---

## Final Result

SSH server inside Codespaces was successfully configured with:

* Public key authentication only
* Password authentication disabled
* Root login disabled
* SSHD running properly on port 2200
* Absolute path execution (`/usr/sbin/sshd`)
* `sshd_config` exported for submission


