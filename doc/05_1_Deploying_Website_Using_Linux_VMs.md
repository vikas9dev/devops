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

---

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
   Start by installing Apache2, MySQL Server, and several PHP libraries that WordPress depends on. Use `apt update` followed by the installation commands, preferably copied to a notepad first for clarity and customization. Add `-y` for automatic confirmation.

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

   Verify:-

   ```bash
    ls -ld /srv/www
    ls -l /srv/www/wordpress/
   ```

3. **Apache Configuration**  
   Create a new config file `wordpress.conf` under `/etc/apache2/sites-available/`, pointing `DocumentRoot` to `/srv/www/wordpress`. Enable this site using `a2ensite`, disable the default site using `a2dissite`, and reload Apache for the changes to take effect.

   ```bash
   vim /etc/apache2/sites-available/wordpress.conf
   ```
   Add the content. Then, enable the site and reload Apache.

   ```bash
   sudo a2ensite wordpress
   sudo a2enmod rewrite
   sudo a2dissite 000-default
   sudo service apache2 reload
   ls -l /etc/apache2/sites-enabled/
   ls -l /etc/apache2/sites-available/
   ```

4. **Setup MySQL Database for WordPress**  
   Log into MySQL and create a database named `wordpress`. Then, create a user with access to this database, grant it privileges, and flush them. For simplicity, you can use a password like `admin123` during testing, but always use a secure password in real scenarios.

   ```bash
   sudo mysql -u root
   ```
   It will open a MySQL prompt. Enter the following commands:-
   ```sql
   CREATE DATABASE wordpress;
   SHOW DATABASES;
   CREATE USER wordpress@localhost IDENTIFIED BY 'admin123';
   GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO wordpress@localhost;
   FLUSH PRIVILEGES;
   exit
   ```

5. **WordPress Configuration File**  
   Copy `wp-config-sample.php` to `wp-config.php` and use the `sed` command to replace placeholders with the actual database name, username, and password. Open this file to double-check everything is set correctly.

   ```bash
   sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
   sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
   sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
   sudo -u www-data sed -i 's/password_here/admin123/' /srv/www/wordpress/wp-config.php
   ```

6. **Set SALT Keys**  
   Retrieve the security keys from the WordPress site and replace the existing ones in `wp-config.php`. Ensure you're editing this as the `www-data` user using `sudo -u www-data vim`.

   ```bash
   sudo -u www-data vim /srv/www/wordpress/wp-config.php
   ```

   Replace all the lines having `put your unique phrase here` with following content:- https://api.wordpress.org/secret-key/1.1/salt

7. **Finalize and Test**  
   Now the WordPress setup is complete. You can access it via browser by entering the VM’s IP (http://192.168.56.26). You will see the WordPress installation screen where you can enter a site title, admin username, and password.

### Troubleshooting Tips:

- If WordPress can’t connect to the database, re-check your `wp-config.php` file.
- Ensure the Apache and MySQL services are running.
- Use `history` to review commands if something doesn’t work as expected.
- Validate your SQL steps by logging into MySQL and confirming the presence of the `wordpress` database and user.

Once you're done, log out of the VM and run `vagrant destroy` to clean up your environment.

---

## 3. Automating Website and WordPress Setup with Vagrant

Previously, we manually set up a finance website on CentOS and installed a WordPress blog on Ubuntu. Now it's time to take things to the next level—automation. In this section, we’ll create Vagrantfiles that provision both setups automatically. This is the beginning of our journey into Infrastructure as Code (IaC).

We'll start by automating the finance website setup. First, duplicate the existing "finance" folder, then rename the copy to **financeIAC** (Here, "IAC" stands for "Infrastructure as Code"). This folder will house our code-based infrastructure setup.

Delete the `.vagrant` folder inside the new directory to avoid conflicts. Open the `Vagrantfile`, and let’s modify the IP address to prevent clashes with any running VMs. For example, set it to `192.168.56.28`.

Now comes the provisioning magic—this is where we script all the commands we used earlier to set up the website manually. Uncomment the provisioning section in the `Vagrantfile` and begin adding the shell commands one by one:

1. Install required packages:  
   `yum install httpd wget unzip vim -y`

2. Start and enable the Apache service:  
   `systemctl start httpd`  
   `systemctl enable httpd`

3. Create a temporary folder and navigate into it:  
   `mkdir -p /tmp/finance`  
   `cd /tmp/finance`

4. Download the website template from [Tooplate](https://www.tooplate.com). Use browser developer tools (F12 → Network tab) to find the actual download URL and use `wget` to fetch it.

   ```bash
   wget https://www.tooplate.com/zip-templates/2135_mini_finance.zip
   ```

5. Unzip the template:  
   `unzip -o your-template.zip`

6. Copy the contents to the web root:  
   `cp -r your-template/* /var/www/html/`

7. Restart Apache:  
   `systemctl restart httpd`

8. Clean up by deleting the temp folder:  
   `cd /tmp`  
   `rm -rf /tmp/finance`

These steps replicate everything we did manually, now automated through a single Vagrantfile. This is a key principle of DevOps—**if you can do it manually, you can automate it.** The overall structure of the provisioning section looks like this:-

```ruby
  config.vm.provision "shell", inline: <<-SHELL
    yum install httpd wget unzip vim -y
    systemctl start httpd
    systemctl enable httpd
    mkdir -p /tmp/finance
    cd /tmp/finance
    wget https://www.tooplate.com/zip-templates/2135_mini_finance.zip
    unzip -o 2135_mini_finance.zip
    cp -r 2135_mini_finance/* /var/www/html/
    systemctl restart httpd
    cd /tmp/
    rm -rf /tmp/finance
  SHELL
```

Once your file is ready, open Git Bash, navigate to the `financeIAC` folder, and run:

```bash
vagrant up
```

Vagrant will spin up your VM and provision it using the commands you've added. If everything goes well, the site will be live at the IP you configured.

You can test the setup in your browser (http://192.168.56.28). Once tested, you can destroy the VM with:

```bash
vagrant destroy
```

But keep that Vagrantfile safe — this is your reusable infrastructure code. You can spin up this website anytime, anywhere. We’ll also reuse this in our AWS lectures.

---

## 4. Automating WordPress Setup with Vagrant: Infrastructure as Code

In this section, we’re going to automate the WordPress setup using Vagrant — transforming a manual process into **Infrastructure as Code (IaC)**.

Start by opening **Visual Studio Code** and navigating to your `adv_vagrant_vms` folder. Copy the existing `wordpress` folder, paste it in the same location, and rename the new folder to something like `wordpressIAC`. This new directory will contain your automated setup.

Next, expand the folder and delete the hidden `.vagrant` directory inside to avoid conflicts. Open the `Vagrantfile`, confirm you're editing the one inside `wordpressIAC`, and update the IP address to something unique (e.g., `192.168.56.30`) to prevent clashes with other VMs.

Now, onto the provisioning. If you’ve saved the WordPress setup commands from before (or can access them from your documentation), you’re halfway there.

Here’s what we’ll be doing:
- Install necessary dependencies
- Download and configure WordPress
- Set up the database and user using `mysql` commands
- Automatically create and populate configuration files using **here documents (heredocs)**

To write files with specific content automatically, you’ll use the `cat` command along with redirection:

```bash
cat > /path/to/file <<EOF
[your file content goes here]
EOF
```

Make sure there are **no spaces** before or after the `EOF` markers—this is crucial. Any space will cause a `heredoc` error, and provisioning will fail.

For MySQL commands, use this pattern:
```bash
mysql -u root -e 'CREATE DATABASE yourdb;'
```
Be mindful of quotes—especially when passwords are involved. Use single quotes to wrap the entire command, and switch to double quotes inside if needed to avoid confusion.

After setting up the configuration, restart both Apache2 and MySQL services to ensure changes take effect:
```bash
systemctl restart apache2
systemctl restart mysql
```

Once your full provisioning script is ready, replace the placeholder script in your `Vagrantfile` with the new commands. Double-check for typos, missing flags like `-y`, or syntax errors. 

**Check the [VagrantFile](../adv_vagrant_vms/wordpressIAC/Vagrantfile)**

Save the file, then open Git Bash, navigate to your `wordpressIAC` folder, and run:

```bash
vagrant up
```

Vagrant will boot the VM and automatically provision WordPress using your script. Once it’s up, get the VM’s IP address (http://192.168.56.30), paste it into your browser, and you should see the WordPress setup page ready to go.

Congratulations! If you've reached this point, you're doing great. Your foundation in automation and infrastructure as code is solid, and this knowledge will carry forward into more advanced tools like **AWS, Docker, Kubernetes, Ansible**, and **Terraform**.

Go ahead and clean up by running `vagrant destroy` to remove the VM — but keep your `Vagrantfile` safe. 

---

## 5. Mastering Multi-VM Vagrantfiles: Simplify Your DevOps Workflow

Welcome! In this section, we’re diving into a powerful feature of Vagrant—**Multi-VM Vagrantfiles**. Let’s explore what they are, why they’re useful, and how to create and manage them effectively.

In our previous setup, each Vagrantfile was tied to a single VM, meaning you'd need separate folders and commands to manage multiple virtual machines. But what if you’re working on a full-stack application requiring multiple services—like a web server, a database server, and a frontend—all running in separate VMs? Managing them individually would be tedious. Enter **Multi-VM Vagrantfiles**, which allow you to control multiple VMs from a single file, streamlining your development environment.

You can refer to the official Vagrant documentation to understand various configuration options. In particular, check out the **multi-machine** section which provides a sample Vagrantfile structure for managing multiple machines.

For instance, a multi-VM Vagrantfile might define three VMs:  
- `web01` with Ubuntu 20  
- `web02` with Ubuntu 20  
- `db01` with CentOS 7  

Each VM can have its own hostname, private IP address, and provisioning scripts. You can define them using `config.vm.define` blocks and tailor each block with specific settings. Here’s where tools like ChatGPT can assist. You can simply ask ChatGPT to generate a sample multi-VM Vagrantfile and modify it as needed.

But remember—ChatGPT is an assistant, not a replacement. You should understand each configuration you’re adding. Use it to save time, not to skip learning.

After generating your Vagrantfile, open VS Code, create a new folder like `multivm`, and save the file as `Vagrantfile` (note the capital "V" and no extension). Customize IP addresses (to avoid conflicts), install packages like `wget`, `unzip`, and `mariadb-server` for CentOS, and ensure each VM has a unique hostname and purpose.

Once done, spin up your VMs using `vagrant up`. You can SSH into a specific VM like `web01` using `vagrant ssh web01`. You can halt, destroy, or bring up individual VMs using their names (`vagrant halt web02`, `vagrant destroy db01`, etc.), allowing more control over your environment.

As you experiment, remember this isn't about throwing all your VMs into one Vagrantfile. Use multi-VM setups when they make sense—typically for tightly-coupled application stacks. For unrelated projects, maintain separation with different folders and Vagrantfiles.

Lastly, once you’ve tested everything, you can clean up your environment with `vagrant destroy --force` to delete all VMs. Keep experimenting and practicing—this foundational knowledge will be invaluable when you transition to tools like Ansible, Docker, Kubernetes, and Terraform.

Use ChatGPT to troubleshoot or generate configuration files when needed, but during your learning phase, challenge yourself to write and understand every line. You’ve got this—onward to the next section!

---

## 6. 

---