# How to Manage Apache Tomcat with systemctl in CentOS

In this blog, we’re going to dive into how you can manage **Apache Tomcat** using `systemctl`. If you’ve worked with services like `httpd`, you probably know how convenient `systemctl` is for starting, stopping, and enabling services. But what happens when you're dealing with software that doesn’t come pre-integrated with `systemctl`, like **Apache Tomcat**?

Let’s walk through how to make Tomcat work like a standard Linux service.

---

## 📌 A Quick Note: Tomcat vs HTTPd

First things first: **Apache HTTPd** and **Apache Tomcat** are _not_ the same.

- **HTTPd** is a traditional web server for serving static content.
- **Tomcat** is a Java Servlet container used to deploy **Java-based** web applications.

Both are from Apache, but they serve very different purposes.

---

## 🎯 What We'll Cover

Here’s what we’ll do in this tutorial:

1. Manually download and start Tomcat.
2. Understand the limitations of manual startup.
3. Learn how `systemctl` works by exploring the `httpd.service` file.
4. Create a custom `systemd` unit file for Tomcat.
5. Set up Tomcat to run as a non-root user.
6. Enable the service to run on boot.

```bash
 mkdir systemctl && cd systemctl
 vagrant init eurolinux-vagrant/centos-stream-9
```

Modify the vagrantfile for network configuration. Enable public network: `config.vm.network "public_network"` and private network: `config.vm.network "private_network", ip: "192.168.56.10"`. Then:-

```bash
 vagrant up
 vagrant ssh
 sudo -i
 cat /etc/os-release
 dnf install httpd -y
 systemctl status httpd
```

---

## 🧪 Starting With `httpd`

If you've already worked with `httpd`, you'll notice that it comes with a pre-built service file. You can see it using:

```bash
ls /usr/lib/systemd/system | grep httpd
```

Inspect it using:

```bash
cat /usr/lib/systemd/system/httpd.service
```

It will have the below content:-

```bash
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

You'll notice directives like `[Unit]`, `[Service]`, and `[Install]`. Most importantly, in the `[Service]` section, there’s a line like: `ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND`

This is the command `systemctl` runs under the hood when you start the service.

---

## 🧱 Installing Tomcat Manually

Since Tomcat isn’t available via the CentOS package manager (DNF/YUM), we download it manually:

1. Google “Download [Tomcat 10](https://tomcat.apache.org/download-10.cgi)”, in the binary distribution, grab the `.tar.gz` [link](https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.40/bin/apache-tomcat-10.1.40.tar.gz).
2. Use `wget` to download it:

```bash
wget <link_to_tarball>
```

3. Extract it:

```bash
tar xvf apache-tomcat-10*.tar.gz
```

You’ll now have a complete Tomcat binary in one folder — with `bin`, `conf`, `logs`, `lib`, etc.

But Tomcat depends on **Java**, so let’s install that:

```bash
dnf install java-17-openjdk -y
```

Verify the installation:

```bash
java -version
```

Now, start Tomcat using:

```bash
cd apache-tomcat-10*/bin
./startup.sh
```

You’ll see output that indicates the server has started. You can verify with:

```bash
ps -ef | grep tomcat
```

Visit the default Tomcat page at (get the ip using `ip addr show`, we had assigned `192.168.56.10`):

```
http://<your-ip>:8080
```

---

## ❌ Problems with Manual Start

- It won’t start automatically on system reboot.
- DevOps tools like **Ansible**, **Chef**, or **Puppet** expect to manage services using `systemctl`.
- Stopping the service means manually killing processes.
- No centralized logs or process management.

This is not scalable or practical in production. Let's kill the running tomcat process:

```bash
ps -ef | grep tomcat
kill -9 <pid>
```

---

## ✅ Let’s Fix It: Create a `systemd` Unit File

### 1. Create a dedicated user:

```bash
useradd -r -m -d /opt/tomcat -s /sbin/nologin tomcat
```

| Option         | Meaning                                                                 |
|----------------|-------------------------------------------------------------------------|
| `-r`           | Creates a **system user** (used for services, not normal login users).  |
| `-m`           | Creates the **home directory** if it doesn’t exist.                     |
| `-d /opt/tomcat` | Sets the home directory to **`/opt/tomcat`**.                          |
| `-s /sbin/nologin` | Disables shell access (for security; user cannot log in interactively). |
| `tomcat`       | The **username** being created.                                         |

### 2. Move and configure Tomcat:

```bash
cd
cp -r apache-tomcat-*/* /opt/tomcat/
chown -R tomcat:tomcat /opt/tomcat
```

### 3. Create the systemd unit file:

Create `/etc/systemd/system/tomcat.service` with the following content:

```ini
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/opt/tomcat

WorkingDirectory=/opt/tomcat
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
```

### 4. Reload systemd and start the service:

```bash
systemctl daemon-reload
systemctl start tomcat
systemctl status tomcat
systemctl enable tomcat
```

---

## 🤖 Why DevOps Engineers Should Care

DevOps tools like **Ansible** expect services to be managed with `systemctl`. For example, an Ansible playbook might look like this:

```yaml
- name: Start Tomcat service
  service:
    name: tomcat
    state: started
```

If your service isn’t `systemctl`-aware, it breaks automation. Writing your own `systemd` files ensures standardization, automation, and reliability.

---

## 📝 Summary

- We manually downloaded and configured Tomcat.
- We created a `systemd` unit file to manage it like a native service.
- We enabled it to start at boot.
- We saw how this ties into automation tools like Ansible.

Tomcat is just one example. As a DevOps engineer, you’ll often need to make custom apps behave like managed services. And now, you know how.

---
