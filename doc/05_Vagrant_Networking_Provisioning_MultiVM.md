# Vagrant Networking, Provisioning, MultiVM

## 1. Deep Dive into Vagrant: Laying the Foundation for Cloud Computing with AWS

In this section, we’re going to level up our understanding of **Vagrant** — not just as a tool, but as a gateway to essential DevOps concepts that will lay the groundwork for our journey into cloud computing with **AWS**.

Before diving into the Linux section earlier, we set up a virtual machine using Vagrant. You may recall we explored:

- **Vagrant Cloud** and its VM images (or "boxes")
- The **Vagrantfile**, where we configure VM settings
- Core **Vagrant commands** like `vagrant up`, `status`, `ssh`, `halt`, and `destroy`

Now, we’re going to take that knowledge a step further.

### What You’ll Learn in This Section

This part of the course will focus heavily on the **Vagrantfile** — the heart of your VM configuration. We’ll cover:

- **Networking with Vagrant**: Learn how to assign both public (bridged) and private (static) IP addresses.
- **Provisioning**: Automatically execute scripts when a VM boots up using the Vagrantfile (also known as **bootstrapping**).
- **Resource Allocation**: Modify VM specs like RAM and CPU directly from the configuration file.
- **Multi-VM Setup**: Learn how to spin up multiple virtual machines using a single Vagrantfile.
- **Vagrant Internals**: Understand where Vagrant stores its state, SSH keys, and downloaded boxes.

We’ll also explore some hidden gems like the `.vagrant` folder and the global `~/.vagrant.d` directory.

We'll use the **Ubuntu** VM for this section. Make sure to:

1. Clean up existing VMs using `vagrant global-status` and `vagrant destroy`.
2. Download the correct **Vagrantfile** (especially if you're on Mac M1/M2 chips).
3. Place the Vagrantfile in your Ubuntu folder (or use `vagrant init ubuntu/jammy64`) and validate its presence using `ls` and `ls -a`.

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

You can also include sub-blocks like:

```ruby
config.vm.provider "virtualbox" do |vb|
  vb.memory = "1600"
  vb.cpus = 2
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

### Applying Changes

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
