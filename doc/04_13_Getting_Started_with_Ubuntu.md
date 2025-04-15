# 🐧 Getting Started with Ubuntu – Key Differences from CentOS

Welcome! In this section, we’ll explore the **Ubuntu operating system** and highlight how it compares to CentOS. While most Linux commands work similarly across both distributions, there are a few important differences worth noting. Let's dive into setting up and working with Ubuntu using **Vagrant**, and explore its unique tools and behavior.

## 🔧 Spinning Up Ubuntu with Vagrant

We’re using Vagrant to manage our virtual machines. If you've followed our VM setup lecture, you should already have an Ubuntu VM configuration.

1. Navigate to your Ubuntu Vagrant directory:

   ```bash
   cd vagrant-vms/ubuntu
   ```

2. Check the VM status:

   ```bash
   vagrant global-status
   ```

3. Start the Ubuntu VM:

   ```bash
   vagrant up
   ```

4. Log in:
   ```bash
   vagrant ssh
   ```

Clear the screen and verify the OS:

```bash
cat /etc/os-release
```

You'll see you're working on **Ubuntu 22.x**.

Switch to the root user and check your current user and directory:

```bash
sudo -i
whoami
pwd
```

## 👥 Creating Users – `useradd` vs `adduser`

On CentOS, `useradd` creates a user **along with** a home directory and mail spool. In Ubuntu, however:

```bash
useradd devops
```

- Creates the user, **but not** the home directory or mail spool.
- Logging into the new user will drop you into `/` instead of `/home/devops`.

```bash
# su - devops
su: warning: cannot change directory to /home/devops: No such file or directory
```

To delete this incomplete user:

```bash
userdel -r devops
```

You’ll see a warning about the missing home directory and mail spool.

```bash
# userdel -r devops
userdel: devops mail spool (/var/mail/devops) not found
userdel: devops home directory (/home/devops) not found
```

✅ **Better approach in Ubuntu**: Use `adduser`, which is more user-friendly.

```bash
adduser devops
```

This command:

- Creates the user and group
- Sets a password
- Copies default files from `/etc/skel` to the user’s home
- Prompts for optional user info

```bash
# id devops
uid=1002(devops) gid=1002(devops) groups=1002(devops)
```

## 📝 Default Editor for `visudo`

When running:

```bash
visudo
```

Ubuntu opens the file in **nano** by default. If you prefer **Vim**:

1. Temporarily set Vim as your default editor:

   ```bash
   export EDITOR=vim
   visudo
   ```

2. To quit Vim: `:q`

> Note: This change only affects the current shell. We'll cover how to make it permanent in the Bash scripting section.

## 📦 Installing Packages – `dpkg` and `apt`

Ubuntu uses `.deb` packages, unlike `.rpm` on CentOS. You can install software two ways:

## 🛠 Manual Install (using `dpkg`):

1. Download a package (example: `tree`):

   ```bash
   wget <tree-package-url>
   dpkg -i tree_<version>.deb
   ```

Tree package [URL](https://ubuntu.pkgs.org/20.04/ubuntu-universe-amd64/tree_1.8.0-1_amd64.deb.html) =>: http://archive.ubuntu.com/ubuntu/pool/universe/t/tree/tree_1.8.0-1_amd64.deb

2. Verify installation:

   ```bash
   tree
   ```

3. List installed packages:

   ```bash
   dpkg -l
   ```

4. Search for a package:

   ```bash
   dpkg -l | grep tree
   ```

5. Remove a package:

   ```bash
   dpkg -r tree
   ```

## 🚀 Install via `apt`

Ubuntu’s default package manager is `apt`, which is more robust and convenient.

1. Check repositories:

   ```bash
   cat /etc/apt/sources.list
   ```

   You can add more repositories in this file. After that you have to update the package list.

2. Update package list:

   ```bash
   apt update
   ```

3. Search for a package:

   ```bash
   apt search tree
   ```

4. Install a package:

   ```bash
   apt install tree
   ```

5. Install a service (e.g. Apache):
   ```bash
   apt install apache2
   ```

- Installs with all dependencies
- Starts and enables the service automatically

The `apache2` is same as `httpd` in CentOS.

In ubuntu, if we install any service then it will start it automatically and also enabled it.

6. Verify service status:

   ```bash
   systemctl status apache2
   systemctl is-enabled apache2
   ```

7. Remove a package (keeping config):

   ```bash
   apt remove apache2
   ```

8. Remove a package **completely** (including config/data):
   ```bash
   apt purge apache2
   ```

🔥 Ubuntu Firewall (UFW)

Ubuntu uses **UFW (Uncomplicated Firewall)** to manage firewall rules. When installing services like Apache, UFW rules are updated automatically.

## 🧠 Summary

Here are the key differences to remember when working with Ubuntu:

| Feature                | CentOS           | Ubuntu                |
| ---------------------- | ---------------- | --------------------- |
| Package Manager        | `yum`            | `apt`                 |
| User Creation          | `useradd`        | `adduser` (preferred) |
| Text Editor for visudo | `vim` by default | `nano` by default     |
| Firewall Tool          | `firewalld`      | `ufw`                 |

Ubuntu offers an extensive range of available software, easier package management, and quick service setup — all of which make it beginner-friendly.

🧪 **Practice these commands to build confidence working on Ubuntu systems.** You’ll encounter both Ubuntu and CentOS in real-world environments, so it's great to be fluent with both!

---
