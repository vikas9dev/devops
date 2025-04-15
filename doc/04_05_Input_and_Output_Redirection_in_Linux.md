# 🔁 Input and Output Redirection in Linux

In Linux, every command produces output, and by default, this output is sent to the **standard output device**, which is usually your **screen (monitor)**. For example, when you run a command like `uptime`, the output is displayed right on the terminal.

But what if you don’t want that output to appear on the screen? What if you'd rather save it into a file or suppress it entirely? That’s where **input/output redirection** comes in.

## Redirecting Output to a File

You can redirect the output of a command to a file using the `>` symbol. For instance:

```bash
uptime > /tmp/sysinfo.txt
```

This will save the output of the `uptime` command into the file `/tmp/sysinfo.txt`. If the file doesn’t exist, it will be created. If it already exists, it will be **overwritten**.

If you want to **append** the output instead of overwriting it, use `>>`:

```bash
ls >> /tmp/sysinfo.txt
```

This will add the output of the `ls` command to the end of the existing file without erasing previous content.

## Collecting System Information

Let’s gather some useful system information and redirect it into a file:

```bash
echo "## Date" > /tmp/sysinfo.txt
date >> /tmp/sysinfo.txt

echo "## Uptime" >> /tmp/sysinfo.txt
uptime >> /tmp/sysinfo.txt

echo "## Memory Usage" >> /tmp/sysinfo.txt
free -m >> /tmp/sysinfo.txt

echo "## Disk Usage" >> /tmp/sysinfo.txt
df -h >> /tmp/sysinfo.txt
```

Now, `/tmp/sysinfo.txt` contains nicely formatted system info that could be useful for logging or troubleshooting.

## Suppressing Output

If you want to **ignore** the output of a command completely, redirect it to `/dev/null`:

```bash
yum install vim -y > /dev/null
```

This sends the output into a **black hole**—a special file that discards anything written to it.

You can also use this trick to **clear a file’s content**:

```bash
cat /dev/null > /tmp/sysinfo.txt
```

This effectively wipes out the file by redirecting “nothing” into it. The same can be also done using:-

```bash
> /tmp/sysinfo.txt
```

## Redirecting Errors

Sometimes, a command might throw an error. These error messages are sent to **standard error (stderr)**, not standard output. To redirect them, use `2>`:

```bash
freeeeee -m 2> /tmp/error.log
```

This command attempts to run an invalid command (`freeeeee`) and redirects the error to `/tmp/error.log`.

To redirect **both** output and error messages to the same file:

```bash
command &>> /tmp/logfile.txt
```

This is very useful in bash scripting when you want to store logs or review issues later.

## Input Redirection and Piping

Redirection isn't limited to output. You can also **pipe** the output of one command into another using the `|` (pipe) symbol.

For example, to count the number of files in a directory:

```bash
ls /etc | wc -l
```

The `wc -l /etc/passwd` command counts the number of lines in the given file.

To filter output:

```bash
free -m | grep Mem
ls /etc | grep host
tail -20 /var/log/messages | grep -i vagrant
```

To get the first 10 files in a directory: `ls -l /etc | head`
To get the last 10 files in a directory: `ls -l /etc | tail`

You can chain commands together in creative ways to process data more efficiently. This is a powerful skill in Linux scripting.

## Finding Files

To **search for a file**:

```bash
find /etc -name "host*"
```

This performs a real-time search in `/etc`. Be cautious with searching from `/` (the root) as it can slow your system down.

Alternatively, use the `locate` command for faster searches:

```bash
locate host
```

Note: If `locate` is not installed, then you need to install `yum install mlocate -y` and run `updatedb`.

The `locate` is not the real-time search therefore we have to use `updatedb`.

---
