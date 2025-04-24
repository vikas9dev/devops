**Automated Provisioning with Vagrant: Set Up Your Full Stack with a Single Command**

It is a continuation of our previous project, but with a powerful upgrade — **automated provisioning**. In this session, you'll learn how to bring up an entire infrastructure stack using just one command:

```bash
cd 03_vprofile/automated/
vagrant up
```

That’s right — no manual setup required. All the virtual machines (VMs) — including Nginx, Tomcat, RabbitMQ, Memcache, and MySQL — will be automatically provisioned and configured using shell scripts.

We're sticking with a similar architecture as before, but this time, the provisioning process is fully scripted. Each VM has its own bash script (like `mysql.sh`, `memcache.sh`, etc.) that handles installation and setup of the required services. These scripts will run automatically as part of the Vagrant boot process.

```ruby
db01.vm.provision "shell", path: "mysql.sh"
```

Even if you're not experienced in bash scripting, don't worry — the scripts are simple and self-explanatory. For instance, `mysql.sh` sets up MariaDB, configures the database, and loads the schema. Other scripts follow a similar pattern — installing packages, enabling services, and preparing each component of the stack.
