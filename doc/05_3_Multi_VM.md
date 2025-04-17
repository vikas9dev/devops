# Mastering Multi-VM Vagrantfiles: Simplify Your DevOps Workflow

Welcome! In this section, we’re diving into a powerful feature of Vagrant — **Multi-VM Vagrantfiles**. Let’s explore what they are, why they’re useful, and how to create and manage them effectively.

In our previous setup, each Vagrantfile was tied to a single VM, meaning you'd need separate folders and commands to manage multiple virtual machines. But what if you’re working on a full-stack application requiring multiple services—like a web server, a database server, and a frontend—all running in separate VMs? Managing them individually would be tedious. Enter **Multi-VM Vagrantfiles**, which allow you to control multiple VMs from a single file, streamlining your development environment.

## Multi-VM Vagrantfiles

You can refer to the official Vagrant documentation to understand various configuration options. In particular, check out the **[multi-machine](https://developer.hashicorp.com/vagrant/docs/multi-machine)** section which provides a sample Vagrantfile structure for managing multiple machines.

For instance, a multi-VM Vagrantfile might define three VMs:

- `web01` with Ubuntu 20
- `web02` with Ubuntu 20
- `db01` with CentOS 7

Each VM can have its own hostname, private IP address, and provisioning scripts. You can define them using `config.vm.define` blocks and tailor each block with specific settings. This is where tools like ChatGPT can assist. You can simply ask ChatGPT to generate a sample multi-VM Vagrantfile and modify it as needed. Prompt:-

> Create a Multivm Vagrantfile with web01 ubuntu 20, web02 ubuntu 20, db01 centos 7. Include private IP address for each VM. Provide provisioning scripts for db01, use MySQL 8 DB. Also set hostname for each VM.

It gave `Vagrantfile`:-

```ruby
Vagrant.configure("2") do |config|

    # db01 - CentOS 7
    config.vm.define "db01" do |db01|
        db01.vm.box = "eurolinux-vagrant/centos-stream-9"
        db01.vm.hostname = "db01"
        db01.vm.network "private_network", ip: "192.168.56.43"
        db01.vm.provision "shell", inline: <<-SHELL
          yum update -y wget unzip mariadb-server -y
          systemctl start mariadb
          # additional commands
        SHELL
    end

    # web01 - Ubuntu 20.04
    config.vm.define "web01" do |web01|
      web01.vm.box = "ubuntu/focal64"
      web01.vm.hostname = "web01"
      web01.vm.network "private_network", ip: "192.168.56.41"
      web01.vm.boot_timeout = 300
      web01.vm.provision "shell", inline: <<-SHELL
        sudo touch /etc/cloud/cloud-init.disabled
      SHELL
    end

    # web02 - Ubuntu 20.04
    config.vm.define "web02" do |web02|
      web02.vm.box = "ubuntu/focal64"
      web02.vm.hostname = "web02"
      web02.vm.network "private_network", ip: "192.168.56.42"
      web02.vm.boot_timeout = 300
      web02.vm.provision "shell", inline: <<-SHELL
        sudo touch /etc/cloud/cloud-init.disabled
      SHELL
    end

end
```

After generating your Vagrantfile, open VS Code, create a new folder like `multivm`, and save the file as `Vagrantfile` (note the capital "V" and no extension). Customize IP addresses (to avoid conflicts), install packages like `wget`, `unzip`, and `mariadb-server` for CentOS, and ensure each VM has a unique hostname and purpose.

Once done, spin up your VMs using `vagrant up`, it will spin up all the VMs defined in the Vagrantfile. To bring up a specific VM, use `vagrant up web01`.

You can SSH into a specific VM like `web01` using `vagrant ssh web01`. You can halt, destroy, or bring up individual VMs using their names (`vagrant halt web02`, `vagrant destroy db01`, etc.), allowing more control over your environment. Or
you can halt or destroy all VMs together using `vagrant halt` or `vagrant destroy`.

As you experiment, remember this isn't about throwing all your VMs into one Vagrantfile. Use multi-VM setups when they make sense—typically for tightly-coupled application stacks. For unrelated projects, maintain separation with different folders and Vagrantfiles.

Lastly, once you’ve tested everything, you can clean up your environment with `vagrant destroy --force` to delete all VMs. Keep experimenting and practicing—this foundational knowledge will be invaluable when you transition to tools like Ansible, Docker, Kubernetes, and Terraform.

---
