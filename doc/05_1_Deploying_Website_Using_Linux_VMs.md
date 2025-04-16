# Deploying Your First Website and WordPress with Linux VMs

In this section, we’re stepping beyond the Linux basics and diving into **server management**. So far, you’ve explored the Linux file system, filters, user/group management, services, and software installation. Now it’s time to apply that knowledge in a practical, confidence-building way—by setting up and managing real servers on Linux virtual machines.

## What You’ll Learn

You’ll be learning how to:

- Install and manage web servers on CentOS and Ubuntu
- Deploy a simple static website using ready-made HTML templates
- Set up a full LAMP stack (Linux, Apache, MySQL, PHP)
- Deploy a WordPress site on Ubuntu
- Automate the entire setup with Vagrant provisioning

These exercises will give you hands-on experience with concepts that are directly transferable to cloud platforms like AWS. In fact, what you're learning here—known as **provisioning** or **bootstrapping** — is very similar to AWS EC2’s **user data** scripts.

---

## 1. Deploying a Static Website on CentOS

We’ll begin by deploying a basic website on a **CentOS VM**.

### Setup:

1. Create a new folder for your VM setup, e.g., `finance`, and run `vagrant init eurolinux-vagrant/centos-stream-9` using a CentOS box (e.g., EuroLinux).
2. Configure the VM:
   - Assign a static or bridged IP (e.g., `192.168.56.22`)
   - Allocate > 1GB of RAM
3. Start the VM using `vagrant up`, SSH into it, and switch to the root user.
4. (Optional) Change the hostname for clarity.

### Install Required Packages:

```bash
sudo -i
yum install httpd wget unzip zip vim -y
```

- `httpd`: Apache web server
- `wget`: To download website templates
- `unzip`: To extract downloaded templates
- `vim`: For basic file editing

Start and enable the Apache service:

```bash
systemctl enable --now httpd
systemctl status httpd
```

### Deploy a Simple Webpage

Place a basic `index.html` file in `/var/www/html`:

```bash
echo "This is my first website setup." > /var/www/html/index.html
systemctl restart httpd
```

Access it in your browser using your VM’s IP address (http://192.168.56.22) to confirm it works.

### Deploying a Template from Tooplate

1. Open [tooplate.com](https://www.tooplate.com) in the **Brave browser** (to avoid ad popups).
2. Choose a template (e.g., **[Mini Finance](https://www.tooplate.com/view/2135-mini-finance)**), click download, and copy the actual [zip file link](https://www.tooplate.com/zip-templates/2135_mini_finance.zip) from DevTools (F12 > Network tab).
3. SSH into your VM and run:

```bash
rm -rf /var/www/html/index.html
cd /tmp
wget <copied-download-link>
unzip 2135_mini_finance.zip
cd 2135_mini_finance
cp -r * /var/www/html/
ls /var/www/html
systemctl restart httpd
```

Access it in your browser using your VM’s IP address (http://192.168.56.22). You now have a beautiful ready-made website served from your CentOS VM.

## Cleanup the VM by using `vagrant halt `, `vagrant destroy`, or `vagrant destroy --force`.

## 2. Deploying WordPress on an Ubuntu VM with LAMP Stack

Previously, we set up a basic website using an HTML template on a CentOS VM running the Apache (`httpd`) service. Now, we're going to take things a step further by deploying a **WordPress website** on a **Ubuntu 20.04 VM** using a **LAMP (Linux, Apache, MySQL, PHP) stack**.

The official Ubuntu documentation offers a clear and reliable [guide](https://ubuntu.com/tutorials/install-and-configure-wordpress#1-overview). Read through the documentation to get an overview of the requirements and the steps involved.

- In the host machine, create a separate folder (`wordpress`) and initialize the Ubuntu 20.04 VM:- `vagrant init ubuntu/focal64`.
- Enable the network in VagrantFile, and assign a static IP (e.g., `192.168.56.26`).
- Provide 1.5 GB (~1600 MB) of RAM.
- Optional change the hostname for clarity by adding `config.vm.hostname = "wordpress"` to VagrantFile.
- Start the VM `vagrant up`.
- SSH into the VM `vagrant ssh`
- Switch to the `root` user using `sudo -i`.

### Key Setup Steps:

1. **Install Required Packages**  
   Start by installing Apache2, MySQL Server, and several PHP libraries that WordPress depends on. Use `apt update` followed by the installation commands, preferably copied to a notepad first for clarity and customization.

   ```bash
    sudo apt update
    sudo apt install apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip -y
   ```

2. **Download and Configure WordPress**  
   After setting up the LAMP stack, download WordPress from the official site and extract it into `/srv/www/wordpress`. Change ownership of this directory to the `www-data` user, which is used by Apache.

   ```bash
    sudo mkdir -p /srv/www
    sudo chown www-data: /srv/www
    curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
   ```

3. **Apache Configuration**  
   Create a new config file `wordpress.conf` under `/etc/apache2/sites-available/`, pointing `DocumentRoot` to `/srv/www/wordpress`. Enable this site using `a2ensite`, disable the default site using `a2dissite`, and reload Apache for the changes to take effect.

4. **Setup MySQL Database for WordPress**  
   Log into MySQL and create a database named `wordpress`. Then, create a user with access to this database, grant it privileges, and flush them. For simplicity, you can use a password like `admin123` during testing, but always use a secure password in real scenarios.

5. **WordPress Configuration File**  
   Copy `wp-config-sample.php` to `wp-config.php` and use the `sed` command to replace placeholders with the actual database name, username, and password. Open this file to double-check everything is set correctly.

6. **Set SALT Keys**  
   Retrieve the security keys from the WordPress site and replace the existing ones in `wp-config.php`. Ensure you're editing this as the `www-data` user using `sudo -u www-data vim`.

7. **Finalize and Test**  
   Start the VM (`vagrant up`), login, and complete the WordPress setup via browser by entering the VM’s IP. You should see the WordPress installation screen where you can enter a site title, admin username, and password.

### Troubleshooting Tips:

- If WordPress can’t connect to the database, re-check your `wp-config.php` file.
- Ensure the Apache and MySQL services are running.
- Use `history` to review commands if something doesn’t work as expected.
- Validate your SQL steps by logging into MySQL and confirming the presence of the `wordpress` database and user.

Once you're done, log out of the VM and run `vagrant destroy` to clean up your environment.

## This hands-on experience will give you a solid foundation in deploying dynamic websites on a Linux server.
