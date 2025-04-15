# 🏗️ Understanding File Types in Linux

In this section, we’ll explore the different types of files in Linux. You might already know about basic file types like **text files** and **directories**, but in Linux, **everything is treated as a file**—your keyboard, mouse, terminal sessions, and more.

Let’s dive deeper.

## File Identification with `ls -l`

```bash
ls -l /dev
```

When you run the `ls -l` command, it shows a **long listing** format. The first character in the output reveals the **file type**:

- `-` : Regular file (can be text or binary)
- `d` : Directory
- `l` : Symbolic (soft) link
- `c` : Character device file (e.g., keyboard, tty)
- `b` : Block device file (e.g., hard disks)
- `s` : Socket file (used for inter-process communication)
- `p` : Named pipe (FIFO)

The color coding in tools like Git Bash can help, but it's the first character of the `ls -l` output that truly defines the type.

## Identifying File Content with `file`

To confirm if a file is a text file, script, or binary, use the `file` command:

```bash
file filename
```

Examples:

```bash
file /bin/pwd        # Outputs: ELF 64-bit LSB executable (binary)
file yum             # Outputs: Python script or ASCII text
```

## Exploring Special Files

Check out the `/dev` directory using `ls -l /dev`. You’ll see:

- **Character files (c)** – e.g., `/dev/tty` for terminal sessions
- **Block files (b)** – e.g., `/dev/sda` for hard disks

These are device files, used by the kernel for hardware I/O.

## Working with Symbolic Links

You can create shortcuts using symbolic (soft) links:

```bash
ln -s /path/to/original /path/to/link
```

First create the directory ` mkdir -p /opt/dev/ops/devops/test/`. Create the file `vim /opt/dev/ops/devops/test/commands.txt`.

Example of creating symbolic link:

```bash
ln -s /opt/dev/ops/devops/test/commands.txt cmds
```

This creates a `cmds` shortcut to a deeply nested file, see `file cmds`. Check file content using `cat cmds`. If the original file is deleted or moved (e.g., `mv /opt/dev/ops/devops/test/commands.txt /tmp/`), the link becomes a **dead link** (it will appear broken in `ls -l`).

To remove a link:

```bash
rm linkname
# or
unlink linkname
```

## Sorting with `ls`

The `ls` command can be enhanced with useful flags:

- `-l` : Long listing format
- `-t` : Sort by modification time
- `-r` : Reverse the sort order

Example:

```bash
ls -ltr /etc
```

This shows the contents of `/etc`, sorted by last modification time in reverse—useful for tracking recent changes.

## Changing Hostname (Example Use Case)

To change the hostname on a CentOS system:

1. Edit the `/etc/hostname` file:
   ```bash
   vim /etc/hostname
   ```
   Update it to:
   ```
   centos.devops.in
   ```
2. Save and quit, then run:
   ```bash
   $ hostname
   ```
   It should reflect the new name.
3. Re-login to see the new hostname applied in the terminal.

## Viewing Command History

- For the current user:
  ```bash
  history
  ```
- For root:
  ```bash
  sudo -i
  history
  ```

---
