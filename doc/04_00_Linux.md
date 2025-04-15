# 🚀 Linux: Foundation of DevOps

Linux is the bedrock upon which DevOps practices stand. If you're serious about mastering DevOps, this section is absolutely essential - it's not optional.

If you're already a seasoned Linux administrator, feel free to skim through. But if you're not, it's time to level up. This section is designed to make you efficient. You'll learn a lot in a short amount of time.

Here’s what we’ll cover:

## 🔍 What You’ll Learn

- Introduction to Linux: What it is, and why it matters in IT and DevOps.
- Basic commands: Copying files, moving directories, navigating the filesystem, etc.
- File system fundamentals: Understanding Linux directory structure, file types, and text file management.
- Permissions: File permissions, ownership, and how to modify them.
- Filters & Redirection: Powerful tools every DevOps engineer should know.
- Users and Groups: Managing access and system users.
- Superuser privileges: What is `sudo`, and how to use it responsibly.
- Package management: Working with RPM, Debian, Yum, Apt, and more.
- Services and Processes: Managing services, background processes, and system monitoring.
- Server management: Setting up web and database servers.
- Hands-on commands every DevOps engineer should be fluent in.

We’ll focus on four main areas: **commands, files, software, and servers**—skills that are non-negotiable for anyone serious about IT.

## a. 🌐 What is Open Source, and Why Linux?

When you hear "open source," you might think “free software.” But open source is so much more.

Open source means the **source code is freely available** to inspect, improve, and redistribute. This model invites collaboration from thousands of contributors across the globe, often resulting in better security, innovation, and faster progress than traditional closed development.

Linux is the most prominent example of an open source success story. In 1991, **Linus Torvalds** developed a Unix-like open source kernel—the **Linux kernel**. Since then, the world has built entire operating systems around it.

Today, Linux powers everything from desktops to data centers, smartphones to supercomputers.

## b. 🧠 Key Principles of Linux

To understand Linux is to understand its design philosophy:

- **Everything is a file**: Including devices like keyboards, mice, and network interfaces.
- **Small, modular programs**: Each tool does one thing well. Combine them to perform complex tasks.
- **Avoiding captive interfaces**: GUI is optional. CLI is king, especially for automation and scripting.
- **Text-based configuration**: Settings are in simple text files, not buried in menus—perfect for automation.
- **Stability and flexibility**: You can fine-tune Linux to work exactly how you want it to.

## c.💡 Why Linux for DevOps?

Here’s why Linux dominates the DevOps and server space:

- It's open source with massive community support.
- Highly customizable and lightweight.
- Easily automatable compared to Windows.
- Considered more secure (though that’s a debated topic).
- Supports a wide range of hardware and platforms.
- Powers most of the world's servers—and yes, your Android phone too.

## d. 🏗️ Linux Architecture: A Simple Overview

At a high level, Linux looks like this:

1. **Hardware** – CPU, RAM, disk, network.
2. **Linux Kernel** – Talks to hardware, manages resources.
3. **Shell** – CLI interface to issue commands.
4. **Tools & Utilities** – Like `ls`, `cat`, or even GUI tools like browsers.
5. **Users** – People like you, using the system.

## e. 🎯 Popular Linux Distros: Desktop vs Server

### Desktop Linux

If you're trying Linux on your personal machine, consider:

- **Ubuntu** – Most popular, user-friendly.
- **Linux Mint** – Great for beginners.
- **Fedora**, **Debian**, **openSUSE**, **Arch** – Each with its own philosophy and strengths.

We recommend **dual-booting** your laptop and using Linux as often as possible to build comfort.

### Server Linux

In DevOps, server distros are more relevant:

- **Red Hat Enterprise Linux (RHEL)** – Enterprise-grade, stable, and secure (not open source).
- **CentOS / AlmaLinux / Rocky Linux** – Open source alternatives to RHEL.
- **Ubuntu Server** – Open source, user-friendly, and very popular in cloud environments.
- **SUSE Enterprise Linux** – Popular in some enterprise setups.

## f. 🧩 RPM vs DEB: Packaging Systems

Most Linux distros fall into two major packaging families:

- **RPM-based** (Red Hat, CentOS, Fedora, Amazon Linux)

  - Packages use `.rpm` extension
  - Install with `rpm`, `yum`, or `dnf`

- **Debian-based** (Ubuntu, Debian, Kali)
  - Packages use `.deb` extension
  - Install with `dpkg`, `apt`

Example:

- Ubuntu: `sudo dpkg -i google-chrome.deb`
- Red Hat: `sudo rpm -ivh google-chrome.rpm`

Each system has its own commands and tools, so being familiar with both is a huge plus in DevOps.

## g. 📁 Understanding Linux Directory Structure

Let’s quickly look at some important directories:

| Path                 | Purpose                                                |
| -------------------- | ------------------------------------------------------ |
| `/root`              | Home directory of the root (admin) user                |
| `/home/user`         | Home directory for a normal user                       |
| `/bin`, `/usr/bin`   | User-level executable commands (e.g., `ls`, `cat`)     |
| `/sbin`, `/usr/sbin` | Admin-level commands (e.g., `useradd`, `rpm`)          |
| `/etc`               | Configuration files (network, services, users)         |
| `/tmp`               | Temporary files, often deleted on reboot               |
| `/boot`              | Kernel and bootloader files                            |
| `/var`, `/srv`       | Variable data like logs, website files, database files |
| `/lib`, `/usr/lib`   | Libraries used by commands and software                |
| `/media`, `/mnt`     | Mount points for USB drives or CDs                     |
| `/proc`, `/sys`      | Virtual files with system and kernel info              |

---
