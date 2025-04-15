# Managing Services in Linux with `systemctl`

In this section, we'll explore how to manage services on a Linux system using the `systemctl` command. Whether you're checking the status of built-in services or managing your own, understanding how services work is essential.

Let’s take the example of the `httpd` package, which provides the Apache web server. You can install it using:

```bash
yum install httpd -y
```

Once installed, it registers a service named `httpd` that can be controlled using `systemctl`. To check its current state, run: `systemctl status httpd`.

```bash
[root@centos ~]# systemctl status httpd
○ httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; preset: disabled)
     Active: inactive (dead)
       Docs: man:httpd.service(8)
```

This will show whether the service is active or inactive. If it's inactive, you can start it with:

```bash
systemctl start httpd
```

After starting, running the status command again should show the service as active. Behind the scenes, starting a service means initiating one or more processes. You can also stop, restart, or reload a service using:

```bash
systemctl stop httpd
systemctl restart httpd
systemctl reload httpd
```

- **`restart`** is used when you’ve made config changes and want a clean restart.
- **`reload`** attempts to apply changes without stopping the service.

## Starting Services at Boot

By default, starting a service manually only runs it for the current session. If you reboot the system, it won’t start automatically.

```bash
sudo reboot
vagrant ssh
sudo -i
systemctl status httpd
```

To make a service start at boot, use:

```bash
systemctl enable httpd
```

In the current session, it won't start automatically so you can call `systemctl start httpd` to start it.

```bash
systemctl enable httpd
systemctl start httpd
```

Or, you can use:-

```bash
systemctl enable --now httpd
```

This command:

- Enables the service to **start at boot**
- Immediately **starts** the service in the current session

Likewise, you can also **disable and stop** a service with:

```bash
systemctl disable --now httpd
```

To confirm its status or boot-time behavior:

```bash
systemctl is-active httpd     # Check if the service is running
systemctl is-enabled httpd    # Check if the service is enabled at boot
```

If you're using tools like Vagrant, a reboot can be done with:

```bash
vagrant reload
# or
reboot
```

After rebooting, log in and verify whether the service is running. If it’s inactive, that means it wasn’t enabled for boot.

We are using `vagrant ssh` to log into the VM, and it depends on `sshd` serice:- `systemctl status sshd`

## How `systemctl` Works Internally

When you install a package like `httpd`, a service definition (`httpd.service`) file is automatically created under `/etc/systemd/system/multi-user.target.wants/`

```bash
[root@centos ~]# cat /etc/systemd/system/multi-user.target.wants/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```

This file tells `systemctl` how to start or stop the service using the defined commands. For services installed from tarballs or custom binaries, you may need to create your own `.service` files to enable management via `systemctl`.

---
