# Understanding and Managing Linux Processes

In this section, we’ll dive into how processes work in a Linux system and how you can monitor and manage them effectively using basic commands.

## Viewing Running Processes with `top`

Linux runs numerous processes at any given time — some active, some sleeping. The `top` command is one of the most useful tools to monitor them in real-time. It functions similarly to Task Manager in Windows.

```bash
[root@centos ~]# top
top - 03:10:16 up 17 min,  1 user,  load average: 0.00, 0.00, 0.00
Tasks: 118 total,   1 running, 117 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.2 sy,  0.0 ni, 99.8 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :   1771.5 total,   1393.6 free,    320.9 used,    207.7 buff/cache
MiB Swap:   1024.0 total,   1024.0 free,      0.0 used.   1450.6 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
    661 root      20   0  161076   8676   5120 S   0.3   0.5   0:00.41 rsyslogd
   4284 root      20   0   10552   4224   3456 R   0.3   0.2   0:00.03 top
      1 root      20   0  110028  18480  10896 S   0.0   1.0   0:02.21 systemd
      2 root      20   0       0      0      0 S   0.0   0.0   0:00.01 kthreadd
      3 root      20   0       0      0      0 S   0.0   0.0   0:00.00 pool_workqueue_
      4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/R-rcu_g
      5 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/R-sync_
      6 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/R-slub_
      7 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/R-netns
      9 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/0:0H-events_highpri
     10 root      20   0       0      0      0 I   0.0   0.0   0:00.00 kworker/u8:0-events_unbound
```

When you run `top`, you'll see:

- **Uptime** of the system
- **Number of users** logged in
- **Load average** (CPU wait time) over the last 1, 5, and 15 minutes
- **Task summary**: running, sleeping, stopped, or zombie processes
- **CPU and RAM usage**
- **Process list**, dynamically sorted by CPU usage

Each process includes details like PID (Process ID), user, status (e.g., sleeping "S"), CPU/RAM usage, and command name. Press `q` to quit `top`.

> 💡 For memory info in a simpler format, use `free -m`.

## Static Process Snapshot with `ps`

The `ps` command gives a snapshot of current processes:

- `ps aux`: Lists all processes with details like PID, CPU/RAM usage, user, and process command.
- `ps -ef`: Also lists all processes but focuses on hierarchy using PPID (Parent Process ID), helpful for tracing which process started others.

```bash
[root@centos ~]# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.1  1.0 110028 18480 ?        Ss   02:53   0:02 /usr/lib/systemd/systemd --switched-root --system --deserialize 31
root           2  0.0  0.0      0     0 ?        S    02:53   0:00 [kthreadd]
root           3  0.0  0.0      0     0 ?        S    02:53   0:00 [pool_workqueue_]
root           4  0.0  0.0      0     0 ?        I<   02:53   0:00 [kworker/R-rcu_g]
root           9  0.0  0.0      0     0 ?        I<   02:53   0:00 [kworker/0:0H-events_highpri]
root          10  0.0  0.0      0     0 ?        I    02:53   0:00 [kworker/u8:0-events_unbound]
root          11  0.0  0.0      0     0 ?        I<   02:53   0:00 [kworker/R-mm_pe]
root         391  0.0  0.0      0     0 ?        S    02:53   0:00 [xfsaild/sda2]
root         462  0.0  0.5  23888  9344 ?        Ss   02:53   0:00 /usr/lib/systemd/systemd-journald
root         470  0.0  0.0      0     0 ?        I    02:53   0:00 [kworker/1:4-mm_percpu_wq]
root         476  0.0  0.7  37236 12844 ?        Ss   02:53   0:00 /usr/lib/systemd/systemd-udevd
root         508  0.0  0.0      0     0 ?        I<   02:53   0:00 [kworker/R-xfs-b]
root         515  0.0  0.0      0     0 ?        S    02:53   0:00 [xfsaild/sda1]
root         525  0.0  0.1  96176  2884 ?        S<sl 02:53   0:00 /sbin/auditd
root         527  0.0  0.1   7688  3328 ?        S<   02:53   0:00 /usr/sbin/sedispatch
dbus         553  0.0  0.2  10772  4992 ?        Ss   02:53   0:00 /usr/bin/dbus-broker-launch --scope system --audit
dbus         554  0.0  0.1   5280  3168 ?        S    02:53   0:00 dbus-broker --log 4 --controller 9 --machine-id f5ba50d49912402a977c9149838a614f --max-bytes 536870912 --max-fds 4096 --max-matches 131072 --audit
root         555  0.0  1.3 258980 23756 ?        Ssl  02:53   0:00 /usr/sbin/NetworkManager --no-daemon
root         558  0.0  0.2  82628  3968 ?        Ssl  02:53   0:00 /usr/sbin/irqbalance
libstor+     559  0.0  0.0   2704  1792 ?        Ss   02:53   0:00 /usr/bin/lsmd -d
root         560  0.0  0.1   3336  2048 ?        Ss   02:53   0:00 /usr/sbin/mcelog --daemon --foreground
root         562  0.0  0.8  31140 14960 ?        Ss   02:53   0:00 /usr/lib/systemd/systemd-logind
chrony       570  0.0  0.2  84948  4660 ?        S    02:53   0:00 /usr/sbin/chronyd -F 2
root         635  0.0  0.5  18760  9984 ?        Ss   02:53   0:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root         641  0.0  0.2  12472  4992 ?        Ss   02:53   0:00 /usr/sbin/atd -f
root         644  0.0  0.1   8568  3584 ?        Ss   02:53   0:00 /usr/sbin/crond -n
root         648  0.0  0.1   3044  1920 tty1     Ss+  02:53   0:00 /sbin/agetty -o -p -- \u --noclear - linux
root         661  0.0  0.4 161076  8676 ?        Ssl  02:53   0:00 /usr/sbin/rsyslogd -n
root        4049  0.0  0.6  20268 11776 ?        Ss   02:53   0:00 sshd: vagrant [priv]
vagrant     4053  0.0  0.7  23792 13948 ?        Ss   02:53   0:00 /usr/lib/systemd/systemd --user
vagrant     4055  0.0  0.4  28588  8632 ?        S    02:53   0:00 (sd-pam)
vagrant     4063  0.0  0.4  20556  7432 ?        S    02:53   0:00 sshd: vagrant@pts/0
vagrant     4064  0.0  0.2   8688  5376 pts/0    Ss   02:53   0:00 -bash
root        4174  0.0  0.4  21044  8960 pts/0    S    02:53   0:00 sudo -i
root        4176  0.0  0.3   8840  5504 pts/0    S    02:53   0:00 -bash
root        4249  0.1  0.0      0     0 ?        I    02:59   0:01 [kworker/1:0-mm_percpu_wq]
root        4275  0.0  0.0   5592  1536 ?        Ss   03:01   0:00 /usr/sbin/anacron -s
root        4282  0.0  0.0      0     0 ?        I    03:08   0:00 [kworker/0:1-cgroup_destroy]
root        4290  0.0  0.1   9968  3456 pts/0    R+   03:14   0:00 ps aux
```

```bash
[root@centos ~]# ps -ef
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 02:53 ?        00:00:02 /usr/lib/systemd/systemd --switched-root --system --deserialize 31
root           2       0  0 02:53 ?        00:00:00 [kthreadd]
root           3       2  0 02:53 ?        00:00:00 [pool_workqueue_]
root           4       2  0 02:53 ?        00:00:00 [kworker/R-rcu_g]
root           5       2  0 02:53 ?        00:00:00 [kworker/R-sync_]
root           6       2  0 02:53 ?        00:00:00 [kworker/R-slub_]
root           7       2  0 02:53 ?        00:00:00 [kworker/R-netns]
root           9       2  0 02:53 ?        00:00:00 [kworker/0:0H-events_highpri]
root          10       2  0 02:53 ?        00:00:00 [kworker/u8:0-events_unbound]
root          11       2  0 02:53 ?        00:00:00 [kworker/R-mm_pe]
root          12       2  0 02:53 ?        00:00:00 [kworker/u8:1-netns]
root          13       2  0 02:53 ?        00:00:00 [rcu_tasks_kthre]
root          14       2  0 02:53 ?        00:00:00 [rcu_tasks_rude_]
root          15       2  0 02:53 ?        00:00:00 [rcu_tasks_trace]
root          16       2  0 02:53 ?        00:00:00 [ksoftirqd/0]
root          17       2  0 02:53 ?        00:00:00 [pr/ttyS0]
root          18       2  0 02:53 ?        00:00:00 [rcu_preempt]
root          19       2  0 02:53 ?        00:00:00 [rcu_exp_par_gp_]
root          20       2  0 02:53 ?        00:00:00 [rcu_exp_gp_kthr]
root          21       2  0 02:53 ?        00:00:00 [migration/0]
root          22       2  0 02:53 ?        00:00:00 [idle_inject/0]
root          24       2  0 02:53 ?        00:00:00 [cpuhp/0]
root          25       2  0 02:53 ?        00:00:00 [cpuhp/1]
root          26       2  0 02:53 ?        00:00:00 [idle_inject/1]
root          27       2  0 02:53 ?        00:00:00 [migration/1]
root          28       2  0 02:53 ?        00:00:00 [ksoftirqd/1]
root          30       2  0 02:53 ?        00:00:00 [kworker/1:0H-events_highpri]
root          31       2  0 02:53 ?        00:00:01 [kworker/u9:0-events_unbound]
root          34       2  0 02:53 ?        00:00:00 [kworker/u9:1-events_unbound]
root          35       2  0 02:53 ?        00:00:00 [kworker/u10:1-events_unbound]
root          36       2  0 02:53 ?        00:00:00 [kdevtmpfs]
root          37       2  0 02:53 ?        00:00:00 [kworker/R-inet_]
root          38       2  0 02:53 ?        00:00:00 [kauditd]
root          39       2  0 02:53 ?        00:00:00 [khungtaskd]
root          40       2  0 02:53 ?        00:00:00 [oom_reaper]
```

You’ll notice:

- **PID 1** is usually `systemd` (or `init` in some systems), the first process started by the kernel.
- Kernel threads appear in **square brackets**.
- Services like `httpd` or `sshd` will often have a parent-child hierarchy.

## Killing Processes

If you need to stop a process:

1. Identify the process with:

   ```bash
   ps -ef | grep httpd | grep -v grep
   ```

   or,

   ```bash
   pgrep httpd
   ```

   Example:-

   ```bash
    [root@centos ~]# ps -ef | grep httpd | grep -v grep
    root        4328       1  1 03:24 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
    apache      4329    4328  0 03:24 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
    apache      4330    4328  0 03:24 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
    apache      4331    4328  0 03:24 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
    apache      4332    4328  0 03:24 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND

    [root@centos ~]# pgrep httpd
    4328
    4329
    4330
    4331
    4332
   ```

2. Kill the parent process:

   ```bash
   kill <PID>
   ```

   This gracefully requests the process to terminate, closing its children first.

3. If the process is unresponsive:
   ```bash
   kill -9 <PID>
   ```
   This forcefully terminates it. Note: Child processes may become **orphans**.

To kill all child processes at once:

```bash
ps -ef | grep httpd | grep -v grep | awk '{print $2}' | xargs kill -9
```

Or,

```bash
pgrep httpd | xargs kill -9
```

## Orphan & Zombie Processes

- **Orphan Processes**: Child processes whose parent is terminated. They're usually adopted by `systemd` (PID 1). These can be cleaned up manually to free resources.
- **Zombie Processes**: Processes that have completed but remain in the process table. Their status appears as `Z` in `ps aux`. These don’t consume resources but might cause issues — a reboot typically clears them.

## Summary

- `kill -9 PID` command is to stop process forcefully and `kill PID` is to stop process gracefully, child processes also will be stopped if parent process is stopped gracefully.
- Difference between Zombie & Orphan Process:- A child process that remains runing even after its parent process is terminated or completed without waiting for the child process execution is called a Orphan process. Zombie process that has completed its task but still, it shows an entry in the process table is called Zombie process.

With these tools — `top`, `ps`, `kill`, `awk`, and `xargs`—you’re well-equipped to monitor and manage Linux processes efficiently. In the next section, we’ll explore more advanced process control and automation.

---
