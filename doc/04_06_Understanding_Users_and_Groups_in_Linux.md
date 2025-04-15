# Understanding Users and Groups in Linux

In this section, we’ll explore how Linux manages **users and groups**—the fundamental elements used to control access to files, directories, and system resources.

## What Are Users and Groups?

In Linux, **everything is treated as a file**, and each file is owned by a **user** and associated with a **group**. This ownership structure helps enforce access control via permissions.

- Every user has a unique **User ID (UID)**.
- Groups have a **Group ID (GID)**.
- This information is stored in `/etc/passwd` (for user details) and `/etc/group` (for group memberships).
- Passwords are stored (in encrypted form) in `/etc/shadow`.

## Types of Users

Linux systems typically categorize users into three types:

| **Type**            | **Example**             | **User ID (UID)** | **Group ID (GID)** | **Home Dir**       | **Shell**                       |
| ------------------- | ----------------------- | ----------------- | ------------------ | ------------------ | ------------------------------- |
| Root User           | `root`                  | 0                 | 0                  | `/root`            | `/bin/bash`                     |
| Regular User        | `vagrant`, `vks`        | 1000 to 60000     | 1000 to 60000      | `/home/<username>` | `/bin/bash` (or similar)        |
| System/Service User | `sshd`, `ftp`, `apache` | 1 to 999          | 1 to 999           | `/var/ftp`, etc.   | `/sbin/nologin` or `/bin/false` |

1. **Root User**:- Has full administrative privileges.
2. **Regular Users**:- Used for day-to-day tasks by real people.
3. **System/Service Users**:- Often have no login shell (`/sbin/nologin` or `/bin/false`) and sometimes no home directory.

## Working with `/etc/passwd` and `/etc/group`

The `/etc/passwd` file contains information like:

- Username
- Link to encrypted password (indicated by `x`)
- UID (User ID)
- GID (Group ID)
- Comments
- Home directory
- Login shell

Example: `grep vagrant /etc/passwd`

```
vagrant:x:1000:1000:Vagrant User:/home/vagrant:/bin/bash
```

The `/etc/group` file lists group names and their members. For instance: `grep vagrant /etc/group`

```
vagrant:x:1000:
```

When creating a user, a primary group with the same name is usually created by default.

To get all the groups a user belongs to:

```bash
# id vagrant
uid=1000(vagrant) gid=1000(vagrant) groups=1000(vagrant)
```

## Creating Users and Groups

You can create users with the `useradd` command:

```bash
useradd ansible
useradd jenkins
useradd aws
```

Check their entries with:

```bash
tail -4 /etc/passwd
tail -4 /etc/group
```

Create a new group:

```bash
groupadd devops
```

## Adding Users to Groups

To add users to a secondary group:

```bash
usermod -aG devops ansible
```

Here `G` represents secondary group. For primary group we can use `g`.

Alternatively, directly edit `/etc/group`:

```bash
devops:x:1010:ansible,jenkins,aws
```

Check group membership:-

```bash
[root@centos ~]# id ansible
uid=1001(ansible) gid=1001(ansible) groups=1001(ansible),1004(devops)

[root@centos ~]# grep devops /etc/group
devops:x:1004:ansible
```

## Setting and Resetting Passwords

Root user can reset any users password by using `passwd username` command, also user can reset its own password by running just `passwd` command.

Set or reset a password:

```bash
passwd ansible
passwd aws
passwd jenkins
```

Only the **root user** can reset others’ passwords. Root can also switch to any user without a password using: `su - user`

```bash
[root@centos ~]# su - ansible
[ansible@centos ~]$ whoami
ansible
```

Regular users will be prompted for a password when switching:

```bash
su - aws
```

Use `exit` to logout from the current user.

## Monitoring User Activity

Useful commands:

- `who`: See who is logged in.
- `whoami`: Shows current user.
- `last`: Shows login history.
- `lsof -u username`: Lists open files by a user (install `lsof` if needed). This command is often used to find open ports, logged in users, etc.

```bash
yum install lsof -y
lsof -u aws
```

## Deleting Users and Groups

Delete a user:

```bash
userdel aws
```

But it won't delete its home directory:- `ls /home`

Delete a user and their home directory:

```bash
userdel -r jenkins
userdel -r ansible
```

Delete a group:

```bash
groupdel devops
```

To remove remaining home directories manually:

```bash
rm -rf /home/aws
```

Finally, you can view your command history with:

```bash
history
```

---
