# Understanding Software & Package Management in Linux

Software management—better known in the Linux world as **package management**—is a fundamental concept every Linux user should grasp.

Think about all the times you've installed or uninstalled software on your computer or phone. In Linux, similar tasks are performed using packages, and the system used to manage them depends on your Linux distribution.

To explore this, we’ll start from the basics: how to download and install a single package manually. Then, we’ll gradually move on to using package management tools like `yum`, `dnf`, and `apt`.

## Two Popular Linux Distributions: CentOS vs Ubuntu

At the beginning of this journey, we created two virtual machines—one running **CentOS** and the other **Ubuntu**. The primary difference between these two is their **package management systems**:

- **CentOS** is **RPM-based** (uses `.rpm` files and tools like `yum` or `dnf`).
- **Ubuntu** is **Debian-based** (uses `.deb` files and tools like `apt`).

Let’s focus on the CentOS VM for now. If your VM isn’t running, bring it up and log in using `vagrant ssh`. Once inside, switch to the root user using:

```bash
sudo -i
```

Managing packages requires **root privileges**, so this step is essential.

## Identifying Your OS and Architecture

To confirm the type of OS and architecture, run `cat /etc/os-release`.

```bash
[root@centos ~]# cat /etc/os-release
NAME="CentOS Stream"
VERSION="9"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="9"
PLATFORM_ID="platform:el9"
PRETTY_NAME="CentOS Stream 9"
ANSI_COLOR="0;31"
LOGO="fedora-logo-icon"
CPE_NAME="cpe:/o:centos:centos:9"
HOME_URL="https://centos.org/"
BUG_REPORT_URL="https://issues.redhat.com/"
REDHAT_SUPPORT_PRODUCT="Red Hat Enterprise Linux 9"
REDHAT_SUPPORT_PRODUCT_VERSION="CentOS Stream"
```

You should see output like `ID="centos"` and `x86_64`, indicating a CentOS OS with a 64-bit architecture.

To see the list of available packages, run `rpm -qa` in Arch Linux. In Debian-based systems, use `dpkg -l` instead. You should see a list of installed packages.

To see the architecture of the system (CPU), run `uname -m` or `arch`.

```bash
[root@centos ~]# arch
x86_64

[root@centos ~]# uname -m
x86_64
```

## Installing a Package Manually (RPM)

Let’s install a package named **telnet**. First, check if it’s already installed:

```bash
telnet
```

If you get an error like _command not found_, it means the telnet RPM isn’t installed.

Now, head to [rpmfind.net](https://rpmfind.net/linux/RPM/), search for **telnet**, and find a version compatible with **CentOS Stream 9** and **x86_64** architecture. Once you’ve found the right package, copy the [download link](https://rpmfind.net/linux/centos-stream/9-stream/AppStream/x86_64/os/Packages/telnet-0.17-85.el9.x86_64.rpm).

Download the RPM using `curl` or `wget`. The file telnet.rpm will be saved in the current working directory

```bash
curl -o telnet.rpm <PASTE_DOWNLOAD_LINK_HERE>
```

Or, use `wget`:

```bash
wget <PASTE_DOWNLOAD_LINK_HERE>
```

Now install the RPM:

```bash
rpm -ivh telnet.rpm
```

**Flags**:

- **`-i`** → **Install** the package
- **`-v`** → **Verbose** output (shows detailed progress)
- **`-h`** → **Hash marks** (shows progress as `#` while installing)

👉 So `-ivh` = install with detailed, human-readable progress.

Verify the installation:

```bash
[root@centos ~]# telnet
telnet> quit

[root@centos ~]# rpm -qa | grep telnet
telnet-0.17-85.el9.x86_64
```

To uninstall:

```bash
rpm -e telnet
```

## Why Use Package Managers Like `yum` and `dnf`?

While RPM installation works, it doesn't automatically handle **dependencies**. For example, trying to install a web server like `httpd` using RPM can result in missing dependency errors.

```bash
[root@centos ~]# wget https://rpmfind.net/linux/centos-stream/9-stream/AppStream/x86_64/os/Packages/httpd-2.4.62-4.el9.x86_64.rpm

[root@centos ~]# rpm -ivh httpd-2.4.62-4.el9.x86_64.rpm
error: Failed dependencies:
        httpd-core = 0:2.4.62-4.el9 is needed by httpd-2.4.62-4.el9.x86_64
        system-logos-httpd is needed by httpd-2.4.62-4.el9.x86_64
```

That’s where **package managers** like `yum` and **`dnf`** (mostly used) come in. They automatically resolve and install all dependencies for you.

```bash
[root@centos ~]# cd /etc/yum.repos.d/
[root@centos yum.repos.d]# ls
centos-addons.repo  centos.repo
```

The `centos.repo` and`centos-addons.repo` files contain the list of repositories for CentOS Stream 9. See content of any of these files:

```bash
[root@centos yum.repos.d]# cat centos.repo
[baseos]
name=CentOS Stream $releasever - BaseOS
metalink=https://mirrors.centos.org/metalink?repo=centos-baseos-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
countme=1
enabled=1

[baseos-debuginfo]
name=CentOS Stream $releasever - BaseOS - Debug
metalink=https://mirrors.centos.org/metalink?repo=centos-baseos-debug-$stream&arch=$basearch&protocol=https,http
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
gpgcheck=1
repo_gpgcheck=0
metadata_expire=6h
enabled=0

// More repos...
// enabled=1 enables the repo, enabled=0 disables the repo
```

When we search for a package, it checks for the available repositories and gives the list.

```bash
[root@centos yum.repos.d]# yum search httpd

========================= Name Exactly Matched: httpd ==========================
httpd.x86_64 : Apache HTTP Server
======================== Name & Summary Matched: httpd =========================
centos-logos-httpd.noarch : CentOS-related icons and pictures used by httpd
httpd-core.x86_64 : httpd minimal core
keycloak-httpd-client-install.noarch : Tools to configure Apache HTTPD as
                                     : Keycloak client
python3-keycloak-httpd-client-install.noarch : Tools to configure Apache HTTPD
                                             : as Keycloak client
============================= Name Matched: httpd ==============================
httpd-devel.x86_64 : Development interfaces for the Apache HTTP Server
httpd-filesystem.noarch : The basic directory layout for the Apache HTTP Server
httpd-manual.noarch : Documentation for the Apache HTTP Server
httpd-tools.x86_64 : Tools for use with the Apache HTTP Server
libmicrohttpd.i686 : Lightweight library for embedding a webserver in
                   : applications
libmicrohttpd.x86_64 : Lightweight library for embedding a webserver in
                     : applications
============================ Summary Matched: httpd ============================
mod_auth_mellon.x86_64 : A SAML 2.0 authentication module for the Apache Httpd
                       : Server
mod_dav_svn.x86_64 : Apache httpd module for Subversion server
mod_proxy_cluster.x86_64 : JBoss mod_proxy_cluster for Apache httpd
```

To install `httpd` using `yum` use `yum install httpd` or using `dnf` use `dnf install httpd`.

```bash
[root@centos yum.repos.d]# yum install httpd
CentOS Stream 9 - BaseOS                        8.5 kB/s | 6.3 kB     00:00
CentOS Stream 9 - BaseOS                        939 kB/s | 8.7 MB     00:09
CentOS Stream 9 - AppStream                      55 kB/s | 6.4 kB     00:00
CentOS Stream 9 - AppStream                     7.3 MB/s |  23 MB     00:03
CentOS Stream 9 - Extras packages                60 kB/s | 6.8 kB     00:00
Dependencies resolved.
================================================================================
 Package                  Architecture Version            Repository       Size
================================================================================
Installing:
 httpd                    x86_64       2.4.62-4.el9       appstream        47 k
Installing dependencies:
 apr                      x86_64       1.7.0-12.el9       appstream       123 k
 apr-util                 x86_64       1.6.1-23.el9       appstream        95 k
 apr-util-bdb             x86_64       1.6.1-23.el9       appstream        13 k
 centos-logos-httpd       noarch       90.8-2.el9         appstream       1.5 M
 httpd-core               x86_64       2.4.62-4.el9       appstream       1.5 M
 httpd-filesystem         noarch       2.4.62-4.el9       appstream        13 k
 httpd-tools              x86_64       2.4.62-4.el9       appstream        82 k
Installing weak dependencies:
 apr-util-openssl         x86_64       1.6.1-23.el9       appstream        15 k
 mod_http2                x86_64       2.0.26-4.el9       appstream       163 k
 mod_lua                  x86_64       2.4.62-4.el9       appstream        60 k

Transaction Summary
================================================================================
Install  11 Packages

Total download size: 3.6 M
Installed size: 8.6 M
Is this ok [y/N]:
```

```bash
[root@centos yum.repos.d]# dnf install httpd
Last metadata expiration check: 0:00:59 ago on Tue 15 Apr 2025 02:22:31 AM UTC.
Package httpd-2.4.62-4.el9.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
```

To remove it:

```bash
dnf remove httpd
```

Or,

```bash
yum remove httpd
```

Want to skip confirmation prompts?

```bash
dnf install -y httpd
```

To list available options:

```bash
dnf --help
```

To upgrade all packages:

```bash
dnf upgrade
```

## Managing Repositories

Repositories are where packages are stored. You can inspect them here:

```bash
cd /etc/yum.repos.d
ls
cat CentOS-Stream-AppStream.repo
```

To see all repositories:

```bash
[root@centos ~]# dnf repolist
repo id                       repo name
appstream                     CentOS Stream 9 - AppStream
baseos                        CentOS Stream 9 - BaseOS
extras-common                 CentOS Stream 9 - Extras packages
```

To clean the package cache (sometimes necessary when facing installation issues):

```bash
dnf clean all
```

## Adding External Repositories (e.g., Jenkins)

If a package isn’t found, like `jenkins`, it means none of the default repos include it.

```bash
[root@centos ~]# yum install jenkins
Last metadata expiration check: 0:07:59 ago on Tue 15 Apr 2025 02:22:31 AM UTC.
No match for argument: jenkins
Error: Unable to find a match: jenkins

[root@centos ~]# yum search jenkins
Last metadata expiration check: 0:08:09 ago on Tue 15 Apr 2025 02:22:31 AM UTC.
No matches found.
```

Visit the official Jenkins website ([jenkins.io](https://www.jenkins.io)) and follow the installation instructions for your OS.

Example steps:

```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
# Add required dependencies for the jenkins package
sudo dnf install fontconfig java-17-openjdk
sudo dnf install jenkins
sudo systemctl daemon-reload
```

Now Jenkins is installed via `dnf` using its official repo.

## Other Helpful Tools

- **EPEL Repository**: Provides access to additional packages.

  ```bash
  dnf install epel-release -y
  ```

- **Package History**: See what’s been installed, removed, or updated.

  ```bash
  dnf history
  ```

- **Group Installations**: Install groups like development tools.

  ```bash
  dnf group list
  dnf groupinstall "Development Tools"
  ```

**Wrapping up**: Installing software on Linux can be as simple or as advanced as you want it to be. Whether you’re downloading individual RPMs or using powerful tools like `dnf`, the key is understanding your system architecture, your distribution’s package format, and how to interact with repositories.

How to install single package in RedHat & Debian OS?

- `rpm -i packagename` in RedHat OS
- `dpkg -i packagename` in Debian OS

Where are yum repos and apt repos files located?

- `/etc/yum.repos.d` in yum and `/etc/apt/sources.list` & `/etc/apt/sources.list.d` in apt.

Before installing package in ubuntu with apt command, we should run apt update to refresh apt repository index:- `sudo apt update`

---
