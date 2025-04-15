# File Permissions and Ownership in Linux

In this section, we’ll explore how file permissions and ownership work in Linux, along with how to manage them using both symbolic and numeric methods.

## File Types and Ownership

Every file in Linux has an owner and an associated group. When you run `ls -l`, you’ll see details like this:

```bash
-rw-r--r-- 1 root root 1234 Jan 1 12:00 anaconda-ks.cfg
```

- The first character (`-`) indicates the file type (`-` for file, `d` for directory, `l` for link).
- The next 9 characters represent permissions:
  - `rw-` for the owner
  - `r-x` for the group
  - `r-x` for others

This means:

- **Owner (root)**: read & write (`rw-`)
- **Group (root)**: read & execute (`r-x`)
- **Others**: read & execute (`r-x`)

## Exploring Permissions with `ls -l`

Let's inspect files in the root user’s home directory:

```bash
ls -l ~
```

You’ll see a mix of files, directories, and symbolic links. For example, for `anaconda-ks.cfg`, the file is owned by the `root` user and group. Its permissions are read and write for the owner, and none for group and others.

## Understanding Permission Bits

Permissions are divided into three sets:

- **User (owner)**: the creator or assigned user
- **Group**: members of the file’s group
- **Others**: everyone else

Each permission has a symbolic and numeric representation:

- **Read (r)** = 4
- **Write (w)** = 2
- **Execute (x)** = 1

So:

- `rwx` = 4+2+1 = **7**
- `rw-` = 4+2 = **6**
- `r--` = 4 = **4**

## Creating and Modifying Directories with Permissions

Let’s walk through an example.

1. **Create a new directory:**

```bash
mkdir /opt/devopsdir
```

2. **Create a group and users:**

```bash
groupadd devops
useradd ansible
useradd jenkins
useradd aws
useradd miles
```

3. **Add users (except `miles`) to the group:**
   Edit the `/etc/group` file or use:

```bash
usermod -aG devops ansible
usermod -aG devops jenkins
usermod -aG devops aws
```

4. **Change ownership of the directory:**

```bash
chown ansible:devops /opt/devopsdir
```

If we want to change ownership of subdirectories also then we can use `-R`: `chown -R ansible:devops /opt/devopsdir`. Be careful while doing this because it will do recursive changes to the all subdirectories and we can't undo it.

```sh
# ls -ld /opt/devopsdir/
drwxr-xr-x. 2 ansible devops 6 Apr 14 15:52 /opt/devopsdir/

```

5. **Modify permissions:**
   - Add execute permission to the owner (`u`):
     ```bash
     chmod u+x /opt/devopsdir
     ```
   - Remove all permissions for others (`o`):
     ```bash
     chmod o-rx /opt/devopsdir
     ```
   - Add write permission to the group (`g`):
     ```bash
     chmod g+w /opt/devopsdir
     ```
   - Give execute permission to all users:
     ```bash
     chmod +x /opt/devopsdir
     ```

```bash
# ls -ld /opt/devopsdir/
drwxrwx---. 2 ansible devops 6 Apr 14 15:52 /opt/devopsdir/
```

Now:

- **User `ansible`** has full access.
- **Group `devops`** also has full access (can read, write, and execute).
- **Others** have no access at all.

## Testing Permissions

Switch to a user **not** in the `devops` group (like `miles`) and try:

```bash
su - miles
ls /opt/devopsdir       # Permission denied
cd /opt/devopsdir       # Permission denied
touch /opt/devopsdir/test.txt  # Permission denied
```

Switch to a user **in** the group (like `aws`) and try:

```bash
su - aws
cd /opt/devopsdir
touch awsfiles.txt      # File will be created successfully
```

## Using the Numeric Method (`chmod 770`)

Instead of using symbolic flags (`rwx`), you can assign permissions using numbers.

**Example:**

```bash
chmod 770 /opt/devopsdir
```

Breakdown:

- 7 (Owner): read (4) + write (2) + execute (1)
- 7 (Group): read (4) + write (2) + execute (1)
- 0 (Others): no permissions

**Another example:**

```bash
chmod 754 /opt/devopsdir
```

- 7: rwx (Owner)
- 5: r-x (Group)
- 4: r-- (Others)

This numeric method is quicker and often preferred in scripts or automated tasks.

Note:-

- `chown` command is to change ownership of the file.
- `chmod` is to change mode of a file.

---
