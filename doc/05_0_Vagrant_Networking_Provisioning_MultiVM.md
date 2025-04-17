# Vagrant Networking, Provisioning, MultiVM

## 1. Deep Dive into Vagrant: Laying the Foundation for Cloud Computing with AWS

In this section, we’re going to level up our understanding of **Vagrant** — not just as a tool, but as a gateway to essential DevOps concepts that will lay the groundwork for our journey into cloud computing with **AWS**.

Before diving into the Linux section earlier, we set up a virtual machine using Vagrant. You may recall we explored:

- **Vagrant Cloud** and its VM images (or "boxes")
- The **Vagrantfile**, where we configure VM settings
- Core **Vagrant commands** like `vagrant up`, `status`, `ssh`, `halt`, and `destroy`

Now, we’re going to take that knowledge a step further.

### 🧠 Things to Keep in Mind

For future use purposes:-
> **Longer boot time** Like `focal64`, `jammy64` (Ubuntu) uses `cloud-init` — so that boot delay + timeout problem might *still* happen. Be sure to keep:

   ```ruby
   web01.vm.boot_timeout = 300
   web01.vm.provision "shell", inline: <<-SHELL
     sudo touch /etc/cloud/cloud-init.disabled
   SHELL
   ```

### What You’ll Learn in This Section

This part of the course will focus heavily on the **Vagrantfile** — the heart of your VM configuration. We’ll cover:

- **Networking with Vagrant**: Learn how to assign both public (bridged) and private (static) IP addresses.
- **Provisioning**: Automatically execute scripts when a VM boots up using the Vagrantfile (also known as **bootstrapping**).
- **Resource Allocation**: Modify VM specs like RAM and CPU directly from the configuration file.
- **Multi-VM Setup**: Learn how to spin up multiple virtual machines using a single Vagrantfile.
- **Vagrant Internals**: Understand where Vagrant stores its state, SSH keys, and downloaded boxes.

We’ll also explore some hidden gems like the `.vagrant` folder and the global `~/.vagrant.d` directory.

```bash
$ ls ~/.vagrant.d/
boxes/    data/  insecure_private_key    plugins.json  setup_version
bundler/  gems/  insecure_private_keys/  rgloader/     tmp/
```

We'll use the **Ubuntu** VM for this section. Make sure to:

1. Clean up existing VMs using `vagrant global-status` and `vagrant destroy`.
2. We will use `adv_vagrant_vms/ubuntu` folder for this exercise. Initialize the Ubuntu VM using `vagrant init ubuntu/jammy64`.

### Editing the Vagrantfile

Open the [Vagrantfile](adv_vagrant_vms/ubuntu/Vagrantfile) using your favorite text editor (e.g., **Notepad++**, VS Code, or Vim). You'll notice:

- The file is a **Ruby script**, but don't worry — no Ruby knowledge is required.
- It starts with `Vagrant.configure` and ends with `end`.
- Lines prefixed with `#` are **comments** and do not affect the configuration.

You’ll find blocks like:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
end
```
Here, `config` is a **variable** that holds the configuration for the VM.

You can also include sub-blocks like:

```ruby
config.vm.provider "virtualbox" do |vb|
  vb.memory = "1600" # RAM in MB
  vb.cpus = 2 # CPU cores
end
```

Make sure to **uncomment** both the `do` and the corresponding `end` line for these sub-blocks to take effect.

### Networking: Public vs. Private IPs

- To **bridge** your VM’s network (assigning it a local network IP), use:

  ```ruby
  config.vm.network "public_network"
  ```

- To assign a **static private IP**, uncomment the below line:

  ```ruby
  config.vm.network "private_network", ip: "192.168.56.14"
  ```

  > ⚠️ Avoid using `0` or `1` in the third octet (e.g., `192.168.0.X`) to prevent conflicts with your router.
  > Some computers block other than `56` in 3rd octet due to VM configuration. Therefore, use `56` in 3rd octet.

### Applying Changes

The VagrantFile is now ready for you to apply changes to the VM. The overall structure looks like:-

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  
  config.vm.network "private_network", ip: "192.168.56.14"
  config.vm.network "public_network"

  config.vm.provider "virtualbox" do |vb|
     vb.memory = "1600"
     vb.cpus = 2
  end
end
```

Changes to the Vagrantfile only take effect after reloading your VM:

- For existing VMs:  
  `vagrant reload`
- For new VMs:  
  `vagrant up`

### Validating the Configuration

- Run `vagrant ssh` to log into your VM
- Use `free -m` to check the updated **memory**
- Use `cat /proc/cpuinfo` to check **CPU cores**

You can also inspect these settings in the **VirtualBox GUI** under the VM’s settings.

That’s it for this section! Power off your VM using `vagrant halt` and get ready — next, we’ll dive deeper into provisioning and multi-VM environments.

---

## 2. Understanding Vagrant Synced Folders: A Hands-On Guide

Let us dive into one of Vagrant’s most useful features — **synced folders**. 

### Step 1: Bring Up Your Vagrant VM  
Start by launching your Ubuntu VM with:

```bash
vagrant up
```

If it’s already running, just reload it using:

```bash
vagrant reload
```

### Step 2: Explore the Default Synced Folder  
Now, take a look at the directory structure. On your **host machine** (your laptop or desktop), you’ll find the VM folder, typically something like:

```bash
$ cd adv_vagrant_vms/ubuntu
$ ls -a
./  ../  .vagrant/  Vagrantfile
```

Inside the VM (the **guest** machine), the corresponding path is:

```
/vagrant
```

This `/vagrant` directory in the VM is automatically synced with your host machine’s project folder (where VagrantFile and `.vagrant` folder are located). To see this in action, open two terminals, one on the host with `cd adv_vagrant_vms/ubuntu` and another on the VM with `cd /vagrant`.

1. On the host, you’ll see a `Vagrantfile`.
2. In the host, create another file with:

   ```bash
   touch test1.txt
   ```

4. In the VMNavigate to `/vagrant` and list the contents:

   ```bash
   $ cd /vagrant
   $ ls
   Vagrantfile  test1.txt
   ```

You’ll notice both files are visible inside the VM. That’s the beauty of synced folders — **any changes you make on one side instantly reflect on the other**.

### Step 3: Sync Test – Guest to Host  
Try this inside the VM:

```bash
cd /vagrant
touch file{1..20}.txt
```

Check your host directory—you’ll see all 20 files appear there instantly.

### Step 4: Removing Files Reflects Both Ways  
Deleting synced files works both ways too:

- From the guest:
  ```bash
  rm -rf file*
  ```

- Or from the host—either way, the changes are mirrored.

### Step 5: Creating a Custom Synced Folder  
Want to sync a different folder? You can customize it in your `Vagrantfile`.

Uncomment (or add) the following line:

```ruby
config.vm.synced_folder "HOST_PATH", "/opt/scripts"
```

- `HOST_PATH` is a directory on your host (which **you** must create).
- `/opt/scripts` is a folder on the guest, and Vagrant will create it automatically.
- Host machines folder need to create Manually, VM machine folder will be created automatically.

For example:

- On **Windows**, create `c:\workspace\devops\shell_scripts` and set:

  ```ruby
  config.vm.synced_folder "c:\\workspace\\devops\\shell_scripts", "/opt/scripts"
  ```

- On **macOS**, you might use:

  ```ruby
  config.vm.synced_folder "/Users/yourname/Desktop/scripts", "/opt/scripts"
  ```

Don’t forget to adjust the syntax based on your OS (Windows uses double backslashes `\\`, while macOS uses forward slashes `/`).

After updating the Vagrantfile, apply the changes:

```bash
vagrant reload
```

You’ll now see an additional synced folder during boot.

```log
[log]
default: C:/workspace/devops/adv_vagrant_vms/ubuntu => /vagrant
default: C:/workspace/devops/shell_scripts => /opt/scripts
```

### Why Use Synced Folders?

There are two great reasons:

1. **Data Safety**: Even if your VM gets corrupted, your files live safely on the host.
2. **Better Editing Experience**: Use your favorite text editors (like VS Code, IntelliJ, or Notepad++) on the host, while the VM executes the code.

Play around—add or delete files in either machine, and you’ll see the sync in action.

Once you're done experimenting, shut down the VM:

```bash
vagrant halt
vagrant destroy
vagrant global-status
```

---

## 3. Vagrant Provisioning: Automate Your VM Setup

There’s a powerful feature in Vagrant called **provisioning** — an essential feature that allows you to automate the setup of your virtual machines.

### What Is Provisioning?

Provisioning in Vagrant means executing commands or scripts **automatically** when a VM is brought up for the first time. Think of it as **bootstrapping** your VM—setting up software, directories, or configurations right when the VM is created. You can also manually trigger provisioning on an already running VM when needed.

### Setting the Stage

For this example, we'll work with two virtual machines:

- A **CentOS VM**
- An **Ubuntu VM**

```bash
cd adv_vagrant_vms
mkdir ubuntu_prov centos_prov
cd ubuntu_prov
vagrant init ubuntu/jammy64
cd ../centos_prov
vagrant init eurolinux-vagrant/centos-stream-9
```

Let’s walk through provisioning on both.

### Provisioning the CentOS VM

1. **Navigate to your CentOS project directory** and open the `Vagrantfile`.

2. **Enable Network Configuration**  
   Add these lines (or uncomment if already present):

   ```ruby
   config.vm.network "public_network"
   config.vm.network "private_network", ip: "192.168.56.16"
   ```

   ⚠️ *Ensure this IP doesn’t conflict with other VMs.*

3. **Enable Shell Provisioning**

   Uncomment or add the following block at the end of your `Vagrantfile`:

   ```ruby
   config.vm.provision "shell", inline: <<-SHELL
     yum install httpd wget unzip git -y
     mkdir -p /opt/devopsdir
     free -m
     uptime
   SHELL
   ```

   - The `-y` flag ensures non-interactive installation (a must for provisioning).
   - You can add any commands here—just avoid anything that prompts user input.

4. **Boot and Provision the VM**
    The overall VagrantFile looks like:-
    ```ruby
    Vagrant.configure("2") do |config|
      config.vm.box = "eurolinux-vagrant/centos-stream-9"
      config.vm.network "public_network"
      config.vm.network "private_network", ip: "192.168.56.16"
      config.vm.provision "shell", inline: <<-SHELL
        yum install httpd wget unzip git -y
        mkdir -p /opt/devopsdir
        free -m
        uptime
      SHELL
    end
    ```

   - Run the following from your CentOS project directory: `vagrant up`
   - You’ll see the provisioning steps executed as the VM comes up. Commands like `free -m` and `uptime` will show output if successful.

### Re-Provisioning an Existing VM

Provisioning only runs **once** by default. If you try `vagrant reload`, it won’t re-run the provisioner. You will see the following message:

```log
[log]
==> default: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> default: flag to force provisioning. Provisioners marked to run always will still run.
```

To force provisioning:

```bash
vagrant reload --provision
```

Or you can use:

```bash
vagrant provision
```

This is handy when modifying or testing provisioning scripts without destroying and recreating the VM.

### Provisioning the Ubuntu VM

1. **Switch to your Ubuntu project directory (`ubuntu_prov`)** and open the `Vagrantfile`. Add the network details:-

```ruby
config.vm.network "public_network"
config.vm.network "private_network", ip: "192.168.56.17"
```

2. **Enable Provisioning for Ubuntu**

   Uncomment or add:

   ```ruby
   config.vm.provision "shell", inline: <<-SHELL
     apt-get update
     apt install apache2 -y
   SHELL
   ```

3. **Force Provisioning on an Existing VM**

   If the VM already exists, run `vagrant reload --provision` otherwise `vagrant up`.

   This triggers the provisioning script and installs Apache.

4. **Verify Apache Installation**

   Find your VM’s IP address by either checking the `Vagrantfile` or running:

   ```bash
   vagrant ssh
   ip a
   ```

   Then open a browser (in host machine) and navigate to:

   ```
   http://192.168.56.17
   ```

   You should see Ubuntu’s default Apache2 page!

   > 📝 Note: In CentOS, Apache (`httpd`) doesn’t start automatically. But in Ubuntu, the Apache2 service starts by default after installation.

### Wrap-Up: Why Provisioning Matters

Provisioning (or bootstrapping) helps you:

- **Automate VM setup**—install packages, create directories, or configure environments without manual intervention.
- **Standardize development environments** across machines.
- **Reuse scripts** to save time and avoid setup errors.

You’ll find similar concepts in cloud platforms too. For example, **AWS EC2** uses something called **user data**—which works just like Vagrant provisioning.

### Cleanup Tips

Once done:
1. Power off your VMs (`vagrant halt`) and destroy your VMs `vagrant destroy` or `vagrant destroy --force`.
2. Check global status `vagrant global-status`
3. Clean up stale entries with `vagrant global-status --prune`
4. Delete remaining VMs in VirtualBox (if any) manually.

---
