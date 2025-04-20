# Project Setup - Manual Process

This is the manual process for setting up a new project. Welcome to your first hands-on project! You’ll be working with VProfile, a Java-based web application made up of multiple services. Unlike traditional setups like WordPress, where Apache and MySQL might run on a single virtual machine, VProfile takes a more realistic, production-style approach - you'll deploy each service on its own virtual machine, across five separate VMs.

This project is designed to mirror real-world scenarios where developers maintain a local copy of the product to test, experiment, and troubleshoot. Get ready to dive into a practical experience that reflects how things work in the field. Let’s get started!

Project Link: [VProfile](https://github.com/vikas9-dev/vprofile-project)

---

You're right! Let’s revise that section to include a clear explanation of the **application flow**, so it fully captures how the VProfile stack works from the user request down to the backend services. Here's the improved H2 blog section with everything integrated:

---

## Setting Up the VProfile Web Stack Locally: Your DevOps Lab Foundation

In this project, you'll set up a **multi-tier web application stack** called **VProfile** on your local machine using virtual machines. This hands-on setup mirrors real-world infrastructure and prepares you for advanced DevOps tasks like refactoring, containerization, and Kubernetes deployments.

There are two main goals:

1. **Establish a baseline** for upcoming DevOps projects.
2. **Create a local lab environment** for experimentation and R&D.

Think of this like replicating your workplace setup—where you deal with services like MySQL, Apache, Nginx, Tomcat, and message brokers. Making changes in production can feel risky. That's why a **local, automated, repeatable setup** is crucial. We'll use tools like **VirtualBox** for virtualization, **Vagrant** for automation, **Git Bash** for CLI and version control, and optionally an **IDE** like Sublime Text or VS Code.

### Project Architecture & Application Flow

The VProfile application is a **Java-based social networking site** composed of several services, each running on its own virtual machine:

- **Nginx**: Acts as a **load balancer**. When a user opens a browser and enters the app's IP (acting as the URL), Nginx receives the request first.
- **Tomcat**: Nginx routes the request to **Apache Tomcat**, which hosts the Java web application.
- **MySQL**: If the user logs in, the app queries **MySQL** to retrieve or store credentials.
- **Memcached**: Before hitting MySQL, the request checks **Memcached** for cached data to reduce DB load and improve performance.
- **RabbitMQ**: Though used as a dummy service in this setup, it simulates real-world complexity. RabbitMQ is a **message broker** used to decouple and asynchronously connect services.

![VProfile Flow](images/vprofile-flow.png)

Here’s a simplified **request flow**:

1. **User opens the browser** and enters the IP address (which points to Nginx).
2. **Nginx** forwards the request to **Tomcat**.
3. Tomcat serves the **Java web application**, which may need user data.
4. Before querying **MySQL**, the app checks **Memcached** for cached user info.
5. If data isn’t in the cache, the app queries **MySQL**, retrieves the data, and stores it in **Memcached** for future requests.
6. **RabbitMQ** is connected to Tomcat to simulate message-driven architecture, helping you practice managing interconnected services.

### Why Automate?

Setting this up manually is complex and not repeatable. That’s why we automate everything using **Vagrant** and **provisioning scripts**. This lets you:

- Recreate the stack on demand
- Save time and reduce human error
- Safely experiment without affecting production
- Build confidence in troubleshooting real environments

By the end of this project, you’ll not only understand how a full-stack web app works behind the scenes, but also gain practical DevOps experience in automating and managing infrastructure. This is your **foundation project**—everything you learn here will carry forward into future projects with Docker, Kubernetes, Jenkins, Ansible, and more. Let’s get into the architecture and start building your local DevOps lab.

---

## VM Setup

Take a clone of the [VProfile](https://github.com/vikas9-dev/vprofile-project) project and checkout to the `local` branch.

Prerequisite
1. Oracle VM Virtualbox
2. Git bash or equivalent editor
3. Vagrant
4. Vagrant plugins

Execute below command in your computer(git bash/terminal) to install hostmanager plugin:-
```
$ vagrant plugin install vagrant-hostmanager
```
In the current project, create a new directory `03_vprofile/manual` and copy the manual `Vagrantfile` from the `local` branch to this directory. Check the [`Vagrantfile`](../03_vprofile/manual/Vagrantfile).

This project uses a **multi-VM Vagrantfile** to spin up the entire stack. It defines **five virtual machines**:

- **db01** – MySQL database  
- **mcache01** – Memcached  
- **rmq01** – RabbitMQ  
- **app01** – Tomcat server  
- **web01** – Nginx load balancer  

Each VM is assigned a specific hostname and memory allocation. By default, these are optimized for machines with lower RAM (600MB for backend VMs and 800MB for Tomcat and Nginx), but if you have **8GB+ or ideally 16GB RAM**, feel free to bump each VM's memory to **1024MB (1GB)**.

### OS-Specific VM Base Images

- **CentOS 9** is used for all VMs except the Nginx VM.
- **Ubuntu** is used for the Nginx VM (`web01`), mainly due to compatibility and lightweight requirements.
- The only difference between Intel-based and Apple Silicon setups lies in the **box names** used in the Vagrantfile.

### Launching the Environment

To get started:

1. **Open Git Bash** (Windows/Linux) or **Terminal** (macOS).
2. Navigate to your project folder. Example:
   ```bash
   cd /f/HC-Coder/vprofile-project/manual-provisioning-windows-mac-intel
   ```
3. List files to confirm the Vagrantfile is there:
   ```bash
   ls
   ```
4. **Clean up any stale VMs** before bringing up the environment:
   ```bash
   vagrant global-status
   vagrant destroy # run this in the folder shown for active VMs
   vagrant global-status --prune
   ```
5. Start provisioning:
   ```bash
   vagrant up
   ```

> ⚠️ Note: Some systems may ask for your local computer password—this is not the VM password, just your own system credentials.

### Understanding the Host Manager Plugin

You'll notice two important global settings in the Vagrantfile:
```ruby
config.hostmanager.enabled = true
config.hostmanager.manage_host = true
```

These lines ensure that Vagrant automatically maps hostnames like `app01`, `db01`, etc., to their respective IPs in your machine’s **hosts file**. This allows the VMs to communicate by name instead of IP, just like they would in a real production setup.

To verify this:

1. SSH into one of the VMs:
   ```bash
   vagrant ssh web01
   ```
2. Check the hostname:
   ```bash
   hostname
   ```
3. View the hosts file:
   ```bash
   cat /etc/hosts
   ```

You’ll see entries like:
```
192.168.56.11  db01
192.168.56.12  mcache01
```

This setup mimics a real DNS resolution process but locally using the hosts file.

### Bringing Services Up in the Right Order

Once the VMs are running, they’re just **bare OS instances**. You’ll manually install and configure services next. The **recommended startup sequence** is:

1. MySQL (`db01`)
2. Memcached (`mcache01`)
3. RabbitMQ (`rmq01`)
4. Tomcat (`app01`)
5. Nginx (`web01`)

> ✅ This order ensures all dependencies are resolved before the frontend (Nginx) starts.

When shutting everything down, reverse the order: **stop Nginx first**, followed by app servers and databases.

This order isn't always mandatory, but it's a good practice—especially in real-time environments where services like Memcached depend on MySQL being available.

### Quick Sanity Test

Once VMs are up, you can run a simple ping test between them to confirm connectivity:
```bash
ping db01 -c 4
```

Try pinging all other services from each VM. If you notice any timeouts or failures, simply reboot the affected VM:
```bash
vagrant reload <vm-name>
```

This manual provisioning setup gives you a strong foundation to install services one-by-one, understand interdependencies, and prepare for later stages involving automation, Docker, and Kubernetes.

---
