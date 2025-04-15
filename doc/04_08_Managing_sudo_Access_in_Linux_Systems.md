# Managing `sudo` Access in Linux Systems

In this section, we’ll explore how the `sudo` command works in Linux and how to configure user access to execute privileged operations.

The `sudo` command allows a regular user to execute commands with root (administrator) privileges. It's commonly used to perform system-level tasks without logging in as the root user. For example, `sudo -i` opens a root shell, and `sudo yum install git` installs software packages with elevated permissions.

## Default Behavior of `sudo`

By default, only users listed in the `sudoers` file (usually members of the `sudo` or `wheel` group, depending on the distribution) can execute commands using `sudo`. If a user without proper permissions attempts to use `sudo`, they will receive an error message indicating they are not in the `sudoers` file.

## Granting `sudo` Access to a User

To allow a user to run commands with `sudo`, their privileges must be defined in the `/etc/sudoers` file or a configuration file under the `/etc/sudoers.d/` directory. It's important **not** to edit `/etc/sudoers` directly using regular text editors, as a syntax error can break access to administrative tasks.

Instead, always use the `visudo` command to safely edit the sudoers configuration:

```bash
sudo visudo
```

This command opens the `/etc/sudoers` file in a safe mode that performs syntax checking before saving changes. To grant a specific user full sudo access, add a line like the following:

```bash
username ALL=(ALL) ALL
```

If you want the user to be able to execute sudo commands **without being prompted for their password**, modify the entry as:

```bash
username ALL=(ALL) NOPASSWD: ALL
```

Example:-

```bash
[vagrant@centos ~]$ sudo -i

[root@centos ~]# passwd ansible
Changing password for user ansible.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.

[root@centos ~]# su - ansible
```

```bash
[ansible@centos ~]$ sudo useradd test12

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for ansible:
ansible is not in the sudoers file.  This incident will be reported.
```

```bash
[ansible@centos ~]$ sudo -i
[sudo] password for ansible:
ansible is not in the sudoers file.  This incident will be reported.

[ansible@centos ~]$ exit
```

Let us give the `ansible` user sudo access.

```bash
[root@centos ~]# ls -l /etc/sudoers
-r--r-----. 1 root root 4328 Jan 24  2024 /etc/sudoers

[root@centos ~]# visudo
```

In the line below from `root    ALL=(ALL)       ALL` add the line:- `ansible ALL=(ALL)       ALL`. Then save the file and exit using the command `:wq`. Now the `ansible` user can execute sudo commands.

```bash
[ansible@centos ~]$ sudo -i
[sudo] password for ansible:
```

To access the root user without password, we need to update the added line to the line `ansible ALL=(ALL) NOPASSWD: ALL` in the sudoers file.

```bash
[root@centos ~]# sudo visudo
[root@centos ~]# su - ansible
# login without password
[ansible@centos ~]$ sudo useradd test12
[ansible@centos ~]$ exit
```

In the `/etc/sudoers.d/` directory:-

```bash
[root@centos ~]# cd /etc/sudoers.d/
[root@centos sudoers.d]# ls
vagrant
[root@centos sudoers.d]# cat vagrant
%vagrant ALL=(ALL) NOPASSWD: ALL

[root@centos sudoers.d]# cp vagrant devops
[root@centos sudoers.d]# vim devops
```

In the file, add the following line:-

```bash
%devops ALL=(ALL) NOPASSWD: ALL
```

## Using the `/etc/sudoers.d/` Directory

A safer and more modular approach is to create a custom configuration file inside the `/etc/sudoers.d/` directory. This avoids modifying the main sudoers file and makes managing permissions easier.

For example, to grant sudo privileges to all users in a group named `devops`, create a file like this:

```bash
sudo visudo -f /etc/sudoers.d/devops
```

Then add the following line:

```bash
%devops ALL=(ALL) NOPASSWD: ALL
```

The `%` prefix indicates that this is a group, not a user.

## Handling Errors in `sudoers`

If a syntax error is introduced into the sudoers configuration, `visudo` will detect it upon saving and prompt you to correct it. If you attempt to edit the sudoers file without using `visudo` and introduce an error, you may lose sudo access entirely — a serious issue if you don't have the root password.

## Summary

- `sudo` allows non-root users to execute commands with elevated privileges.
- Use `visudo` to safely edit the sudoers configuration.
- Add entries either directly in `/etc/sudoers` or create custom files in `/etc/sudoers.d/`.
- Avoid syntax errors — always validate changes using `visudo`.
- Use the `NOPASSWD` directive for automation or non-interactive use cases.

---
