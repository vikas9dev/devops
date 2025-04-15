# 4 Filtering and Redirection in Linux

One of the most powerful aspects of working in Linux is the ability to **filter data** and **redirect outputs** with ease. If you're aiming to be efficient and smart in Linux, mastering these skills is essential—especially for scripting and system administration tasks.

In this section, we'll explore a variety of **filtering commands** and **I/O redirection techniques** that are widely used in daily operations:

## a. 🔍 Filtering with `grep`, `cut`, and `awk`

### a.1. 🔍 Filtering with `grep`

- Use the `grep` command to search for text within files. Add `-i` to ignore case sensitivity, or `-R` to search recursively through directories.
- Want to see what’s _not_ there? Use `grep -v` to exclude matches.

```bash
grep "pattern" /path/to/file
```

Example:

```bash
[root@centos ~]# ls
anaconda-ks.cfg  original-ks.cfg

[root@centos ~]# grep firewall anaconda-ks.cfg
firewall --disabled

[root@centos ~]# grep -i firewall anaconda-ks.cfg
# Firewall configuration
firewall --disabled

[root@centos ~]# grep -i firewall < anaconda-ks.cfg
# Firewall configuration
firewall --disabled
```

The `grep -i firewall anaconda-ks.cfg` command internally works as `grep -i "firewall" < anaconda-ks.cfg`. It means `anaconda-ks.cfg` file is input to the command `grep -i "firewall"`.

**Search for a text in the current directory**:-

```bash
[root@centos ~]# grep -i firewall *
anaconda-ks.cfg:# This is test firewall
anaconda-ks.cfg:# Firewall configuration
anaconda-ks.cfg:firewall --disabled
original-ks.cfg:firewall --disabled
```

**Search for a text in the current directory recursively**:-

```bash
[root@centos ~]# ls
anaconda-ks.cfg  original-ks.cfg
[root@centos ~]# mkdir devopsdir
[root@centos ~]# cp anaconda-ks.cfg devopsdir/
[root@centos ~]# ls devopsdir/
anaconda-ks.cfg

[root@centos ~]# grep -iR firewall *
anaconda-ks.cfg:# This is test firewall
anaconda-ks.cfg:# Firewall configuration
anaconda-ks.cfg:firewall --disabled
devopsdir/anaconda-ks.cfg:# This is test firewall
devopsdir/anaconda-ks.cfg:# Firewall configuration
devopsdir/anaconda-ks.cfg:firewall --disabled
original-ks.cfg:firewall --disabled
```

Example of searching for a configuration in entire `/etc` directory:-

```bash
grep -R SELINUX /etc/*
```

We can use `-v` to exclude matches. The below command show the entire file without the line containing "firewall" (case insensitive because of `-i`):-

```bash
grep -vi firewall anaconda-ks.cfg
```

### a.2. 🔍 Filtering with `cut`

- Use `cut` when dealing with structured data separated by delimiters (like `:` or `,`). It's perfect for extracting specific columns from files like `/etc/passwd`.

The `/etc/passwd` file stores **user account information**. Each line represents one user, with fields separated by colons `:`.

```bash
# cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
```

**Fields (in order):**

1. **Username** (`root`)
2. **Password placeholder** (`x` → actual password is in `/etc/shadow`)
3. **User ID (UID)** (`0`)
4. **Group ID (GID)** (`0`)
5. **User info/comment** (`root`)
6. **Home directory** (`/root`)
7. **Login shell** (`/bin/bash`)

So:

- `root` is the superuser with UID 0, has `/root` as home, and uses Bash.
- `bin` is a system user with no login shell (`/sbin/nologin`).

To get the first column:-

```bash
# cut -d: -f1 /etc/passwd
root
bin
daemon
adm
lp
```

To get the 3rd column:- `cut -d: -f3 /etc/passwd`

### a.3.🔍 Filtering with `awk`

- When `cut` isn’t flexible enough, turn to `awk`. It’s a powerful tool for pattern scanning and processing, letting you apply logic and regex for complex filtering.

To get the first column:-

```bash
# awk -F':' '{print $1}' /etc/passwd
root
bin
daemon
adm
lp
```

## b. 📖 Viewing Files with `less`, `more`, `head`, and `tail`

- Use `less` for interactive reading—you can scroll and search within the file. It might look like within Vim, but it is not. Use `/` for search, `n` and `N` for next and previous matches, and `q` to quit.

```bash
less anaconda-ks.cfg
```

- `more` is a simpler alternative but with limited navigation.
- Want to preview the start or end of a file? Use `head` and `tail`. Need real-time updates (great for logs)? Add `tail -f`.

```bash
# show first N lines of the file (default is 10)
head anaconda-ks.cfg
head -20 anaconda-ks.cfg
```

```bash
# show last N lines of the file (default is 10)
tail anaconda-ks.cfg
tail -20 anaconda-ks.cfg
```

To see the dynamic content of the file, use `tail -f` 🧪. It won't quit the file, if any changes happen to the file, it will show the new content. Use `Ctrl + C` or `Ctrl + Z` to quit.

```bash
tail -20f anaconda-ks.cfg
```

Example:- Use the below command, open a new terminal and do `vagrant ssh`. It will show the recent log.

```bash
tail -f /var/log/messages
```

## c. ✂️ Text Manipulation with `sed` and `vim`

- Use `vim` for in-file search and replace:
  ```
  :%s/text-to-replace/new-text/g
  ```
  Add `/g` for global replacement on all matches.
  To remove (replace with nothing):-
  ```
  :%s/text-to-remove//g
  ```
- Prefer automation? Use `sed` for batch replacements across files:

  ```bash
  sed 's/text-to-replace/new-text/g' filename.txt
  ```

  It will show the updated content (like `cat`) with replacement, but it won't modify the original file. To modify the original file, use `-i` option: `sed -i 's/text-to-replace/new-text/g' filename.txt`.

  To replace in all the files of the current directory:- `sed -i 's/test/test1/g' *`.

---
