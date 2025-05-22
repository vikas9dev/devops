# 🐧 Linux Basic Commands and File System

Before we dive into Linux internals, let's start with the basics: how to work inside a Linux VM, run essential commands, and understand the Linux file system layout.

## ✅ Starting the Vagrant VM

Ensure your CentOS-based Vagrant VM is ready. To check the status of all Vagrant-managed machines:

```bash
vagrant global-status
```

Navigate to the folder where your CentOS VM was created:

```bash
cd vagrant-vm/centos/
```

Start the VM with:

```bash
vagrant up
```

This boots the VM (if already created), and typically starts within a minute. To access it:

```bash
vagrant ssh
```

You're now inside the VM. Clear the screen with:

```bash
clear
```

## 🧰 Essential Linux Commands

Here are some basic commands to get started:

```bash
whoami     # Displays the current user
pwd        # Prints the working directory
ls         # Lists contents of the directory
cat /etc/os-release   # Displays OS name and version
```

You're logged in as the `vagrant` user, whose home directory is `/home/vagrant`.

## 💡 Understanding the Terminal Prompt

```bash
[vagrant@localhost ~]$
```

The command prompt tells you:

- **User**: `vagrant`
- **Host**: Usually `localhost`
- **~ (tilde)** : Represents home directory
- **$**: Indicates a regular user shell

## 🔐 Becoming the Root User

To switch to the root user:

```bash
sudo -i
```

This updates your prompt:

```bash
[root@localhost ~]#
```

- **User**: `root`
- **~**: Now refers to `/root` (root's home directory)
- **#**: Indicates root privileges

Check with:

```bash
whoami   # root
pwd      # /root
```

## 📂 `/` vs `/root` — What's the Difference?

- `/` → The **root directory**, top of the Linux filesystem hierarchy.
- `/root` → The **home directory of the root user**.

Examples:

```bash
cd /      # Takes you to root directory
cd        # Brings you back to the user's home directory
```

Use `ls` in `/` to list all top-level directories.

## 🗺️ Linux File System Layout

```bash
[root@vbox /]# ls

afs  boot  etc   lib    media  opt   root  sbin  sys  usr      var
bin  dev   home  lib64  mnt    proc  run   srv   tmp  vagrant
```

Here’s an overview of key directories:

| Directory        | Description                                             |
| ---------------- | ------------------------------------------------------- |
| `/`              | Root of the entire filesystem                           |
| `/home`          | Home directories for regular users                      |
| `/root`          | Home directory of the root user                         |
| `/bin`           | Essential user commands (e.g. `ls`, `mv`, `pwd`)        |
| `/sbin`          | System-level commands (for root, e.g. `reboot`, `mkfs`) |
| `/etc`           | System configuration files                              |
| `/tmp`           | Temporary files (deleted after reboot)                  |
| `/boot`          | Kernel and bootloader files                             |
| `/var`, `/srv`   | Logs and server-specific data                           |
| `/proc`, `/sys`  | Dynamic system information                              |
| `/opt`           | Optional third-party software                           |
| `/media`, `/mnt` | Mount points for external or temporary filesystems      |

## 🔎 Exploring Common Directories

### View Current Hostname

```bash
cat /etc/hostname
```

### Boot Directory Contents

```bash
cd /boot
ls
```

You'll find kernel files like `vmlinuz`, `initramfs`, and the `grub` directory here.

### Temporary Files

```bash
cd /tmp
ls
```

Use this directory only for short-term storage. It's wiped after reboot.

### System Info in `/proc`

```bash
cd /proc
ls
cat uptime        # System uptime
free -m           # Memory usage
```

Files in `/proc` are dynamic and update in real-time based on the system state.

## 🛤️ Absolute vs Relative Paths

- **Absolute Path**: Starts from root (`/`)  
  Example: `/etc/hostname`, `/bin/ls`
- **Relative Path**: Based on current directory  
  Example: `cd ../`, `ls foldername/`

Use `cd /` anytime to go to the root directory, or `cd` alone to return to your home directory.

## 🔁 Switching Between Users and Logging Out

To become the **root user**:

```bash
sudo -i
```

Your prompt will change (`#` instead of `$`), indicating root access.

To **exit root** and return to the `vagrant` user:

```bash
exit
```

To **log out of the VM entirely**, just run `exit` again. You’ll be back on your **host machine** (e.g., Windows). You can reconnect anytime with:

```bash
vagrant ssh
```

## 🗂️ Creating Directories and Files

Start in the home directory (`/home/vagrant`):

```bash
cd ~   # or simply cd
```

Create directories:

```bash
mkdir dev ops backupdir
```

Create a single file:

```bash
touch testfile.txt
```

Create multiple files using brace expansion:

```bash
touch devopsfile{1..10}.txt
```

This generates 10 files: `devopsfile1.txt` to `devopsfile10.txt`.

## 📋 Copying Files and Understanding Paths

Copy a file using **relative paths**: `cp <source> <destination>`

```bash
cp devopsfile1.txt dev/
```

Now check the contents:

```bash
ls dev/
```

You can also use **absolute paths**:

```bash
cp /home/vagrant/devopsfile2.txt /home/vagrant/dev/
```

Using absolute paths helps reinforce your understanding of Linux file structure.

## 📁 Copying Directories

Attempting to copy a directory without the right option fails:

```bash
cp dev backupdir/
# Error: omitting directory
```

To copy directories, use the `-r` (recursive) flag:

```bash
cp -r dev backupdir/
```

Now `dev` is successfully copied into `backupdir`.

## 🔤 Path Shortcuts

- `cd` or `cd ~` → takes you to your home directory
- `cd /` → takes you to the root directory
- Use `ls` with either **relative** or **absolute paths** to list contents

Example:

```bash
ls dev/                   # Relative
ls /home/vagrant/dev      # Absolute
```

## 🧱 Linux Command Syntax

Most Linux commands follow this pattern:

```
command [options] [arguments]
```

Examples:

- `ls -l /tmp` → long listing of `/tmp`
- `cp -r dev backupdir/` → copy directory recursively

To view available options for any command:

```bash
cp --help
```

You’ll see a list of flags like:

- `-a` → archive
- `-i` → interactive
- `-r` / `-R` / `--recursive` → recursive copy

## ✂️ Moving and Renaming Files or Directories

Move a file:

```bash
mv devopsfile3.txt ops/
```

Move a directory:

```bash
mv ops dev/
```

Rename a file:

```bash
mv testfile.txt testfile_renamed.txt
```

## ✨ Wildcards and Bulk Operations

To move all `.txt` files into a directory:

```bash
mkdir textdir
mv *.txt textdir/
```

Wildcard `*` matches everything in the current directory.

## 🗑️ Removing Files and Directories

Delete a single file:

```bash
rm devopsfile10.txt
```

Delete a directory:

```bash
rm -r mobile/
```

Delete everything in the current directory:

⚠️ **Warning: Dangerous!**

```bash
rm -rf *
```

This removes **all files and folders** in the current location **without confirmation**. If run in critical system directories, data loss is permanent. There's **no recycle bin** in Linux.

## 🕘 View Command History

Check all previous commands:

```bash
history
```

Use this to review and repeat past commands during practice. That wraps up our session on **basic Linux commands and file system navigation**. Practice using absolute paths, directory operations, and file manipulations until they become second nature.

---
