# Jenkins Pipeline: A Hands-On Introduction

## 1. 🔁 Understanding the Continuous Integration Pipeline Flow

Hello and welcome! 👋 In this session, we’re going to break down the **Continuous Integration (CI) pipeline** that we’ll be setting up over the next few videos. Before jumping into implementation, it’s crucial to **understand the flow** – how code travels from development to deployment-ready artifacts. 🛠️

![Continuous Integration Pipeline Flow](images/Continuous_Integration_Pipeline_Flow.png)

We're focusing on a set of tools to demonstrate this CI pipeline:

- 🧰 **Jenkins** (for orchestration)
- 🧠 **Git** (for version control)
- 🏗️ **Maven** (for building Java projects)
- 🧪 **SonarQube** and **Checkstyle** (for code quality and analysis)
- 📦 **Nexus** (for artifact storage)

These tools are just examples. Your actual project might use different ones, but the **core flow remains the same** – so grasp the concept, and you’ll be able to apply it with any toolset. 💡

### 👨‍💻 The Developer's Role

The journey begins with the **developer** writing and testing code locally. Once confident, they **push the code to a GitHub repository**. This is the centralized source from where the pipeline kicks off.

### ⚙️ Jenkins Triggers the Pipeline

Jenkins is configured with Git plugins that detect code changes. As soon as a commit is made, Jenkins:

1. 📥 **Fetches the latest code** using Git.
2. 🧱 **Builds the project** using Maven (in our case, for Java – but it can be adapted to other languages and tools).

### ✅ Testing and Code Quality Checks

After building the code, Jenkins runs **unit tests** using Maven's testing frameworks. These tests verify that each piece of functionality works as expected. The output is usually in XML format – ready for reporting.

Next comes **code analysis** 🕵️. Tools like SonarQube and Checkstyle assess:

- Bugs 🐞
- Vulnerabilities 🔐
- Coding standards 🧹
- Code smells and maintainability 💭

These tools generate detailed reports and dashboards. You can even enforce **quality gates** in SonarQube – if the code doesn’t meet the criteria, the build fails and the pipeline stops 🚫.

### 📦 Artifact Creation and Distribution

If everything passes, Jenkins proceeds to **version the artifact** and upload it to a **Nexus repository**. This versioned artifact is now ready for deployment to any environment. 🌍

### 🔁 Tool Agnostic Flow

Even though we’re using Jenkins, GitHub, SonarQube, and Nexus here, you can replicate the same pipeline with other CI tools like:

- 🧪 GitLab CI
- 🌀 CircleCI
- 🎍 Bamboo
- And many others!

The flow remains: **Fetch → Build → Test → Analyze → Publish**.

### 🎬 What’s Next?

In the next video, we’ll start implementing this CI pipeline step by step. For now, take a moment to review the flow. Once you're confident with it, join me in the next video and let's bring this pipeline to life! 🚀

## 2. 🚀 Steps for Continuous Integration Pipeline

Alright, let’s walk through the essential steps to build a complete **Continuous Integration (CI) pipeline** from scratch! 🌟

Steps:-
1. Jenkins Setup
2. Nexus Setup 
3. SonarQube Setup
4. Configure Security Groups
5. Install Plugins
6. Integrate:- Jenkins with Nexus and SonarQube
7. Write the Pipeline Script
8. Set Up Notifications

### 🧰 Step 1: Set Up Jenkins

We’ll begin by setting up **Jenkins**. If you already have it installed, great—you can reuse the existing setup. Otherwise, we’ll guide you through launching a new Jenkins server.

### 📦 Step 2: Set Up Nexus & SonarQube

Next, we’ll provision **Nexus** (artifact repository) and **SonarQube** (code quality scanner). All three servers—Jenkins, Nexus, and SonarQube—will be launched on EC2 instances using **user data bash scripts** for automation. 🖥️💡

### 🔐 Step 3: Configure Security Groups

As we spin up these services, we’ll also check and configure the **security groups** to ensure smooth communication between the servers. 🔄🔐

### 🧩 Step 4: Install Jenkins Plugins

We’ll install all the essential **Jenkins plugins** one by one—Nexus plugin, SonarQube plugin, Git plugin, Maven plugin, and more. 🔌

### 🔗 Step 5: Integrate Jenkins with Nexus & SonarQube

Time to connect the dots!

* **Nexus integration** is quick—just save your credentials.
* **SonarQube** requires a few extra steps, and we’ll walk through each one together. 🧭

### 📝 Step 6: Create the Pipeline Script

With everything set up, we’ll write the **pipeline script** that ties all these components together. Then, we’ll execute it to see our CI pipeline in action! ⚙️🚦

### 📣 Step 7: Set Up Notifications

Finally, we’ll configure **automated notifications** 📩 so that if any part of the pipeline fails, you’re immediately alerted.

Now, some of this may not fully click just yet—and that’s okay! This section is your **roadmap**. Whenever you're unsure or feel lost, come back here to reorient yourself. 🗺️✨

---

## 3. 🧑‍💻 Setting Up Nexus & SonarQube on EC2: A Hands-On Guide ☁️📦🧪

> 💡 **Note:** Due to cost constraints, Jenkins is already running locally on a VM instead of an EC2 instance. Nexus and SonarQube, also will be hosted on local VM instead of EC2.

⚠️ Why Not EC2 for Nexus/SonarQube (in our case):
* ❌ `t2.micro` (free tier) is **not sufficient** — both tools are memory-intensive (Nexus \~2–3 GB, SonarQube \~3–4 GB)
* 💰 Upgrading to `t2.medium` or `t3.medium` is **not free tier** — you'll incur hourly costs
* 💤 Keeping them stopped when not in use can help, but you’ll still risk forgetting or getting billed

| Tool      | Where to Run     | Reason                                    |
| --------- | ---------------- | ----------------------------------------- |
| Jenkins   | Local Vagrant VM | Already done ✅ – stable, cost-free        |
| Nexus     | Local Vagrant VM | Needs more RAM than free EC2 provides     |
| SonarQube | Local Vagrant VM | Needs 3–4 GB RAM — too heavy for free EC2 |

In this section, we’ll launch and configure two essential services for our CI pipeline—**Nexus** (artifact repository) on Amazon Linux 2023 and **SonarQube** (code quality analysis)—on Ubuntu 24.04. These services will be hosted on separate EC2 instances.

### 📦 Nexus Setup (Amazon Linux 2023)

We'll deploy **Nexus** on an Amazon Linux 2023 EC2 instance using a **User Data script**. Here's how it works:

* Clone the setup scripts from: `https://github.com/vikas9dev/vprofile-project` (branch: `atom`)
* Navigate to the `userdata` folder and locate `nexus-setup.sh`
* The script performs:
  * JDK 17 installation
  * Directory setup under `/opt/nexus`
  * Binary download and extraction
  * Nexus user creation
  * Systemd service configuration and activation ✅

🔐 **Security Group Setup for Nexus:**

* Allow SSH (port 22) from **your IP**
* Allow HTTP (port 8081) from:

  * **Your IP** (to access via browser)
  * **Jenkins Security Group** (to upload artifacts)

💡 *Important:* Jenkins must be able to communicate with Nexus on port 8081.

==================================================================================

**For VM Environment**

> Go to [nexus-vagrant](/08_jenkins/nexus-vagrant/) and start the VM. It will use specified `nexus-setup.sh` script to setup Nexus. Once done, you can access Nexus at: `http://localhost:8081`

Vagrant Networking:- Ensure both VMs (Jenkins and Nexus) are on the same private network and can talk to each other. For example, in both Vagrantfiles:

```ruby
config.vm.network "private_network", ip: "192.168.56.10"  # Jenkins VM
config.vm.network "private_network", ip: "192.168.56.11"  # Nexus VM
```

**Firewall (firewalld)**

CentOS 9 may have **`firewalld`** enabled, which can block ports **just like a security group** would.

Check and either **allow port 8081** or disable `firewalld`:

Option A: Allow port 8081

```bash
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload
```

Option B: Disable firewalld entirely (not for production):

```bash
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```
✅ 3. **Ensure Nexus is Listening on 0.0.0.0**

This is already done in your `nexus.properties`:

```properties
application-host=0.0.0.0
```
==================================================================================

### 🧪 SonarQube Setup (Ubuntu 24.04)

SonarQube will be set up on **Ubuntu 24.04** using `sonar-setup.sh`, which handles:

* JDK 17 installation
* PostgreSQL setup and database creation
* SonarQube binary installation and extraction
* NGINX configuration as a reverse proxy (port 80 → 9000)
* System-level tuning to meet SonarQube’s performance needs:

  * Update `/etc/sysctl.conf` and `/etc/security/limits.conf`
  * Reboot the instance to apply these changes 🔄

📁 Configuration:

* `sonar.properties` contains database credentials (`sonar`/`admin123`) and other runtime settings.
* Systemd is used to manage and enable the SonarQube service.

🔐 **Security Group Setup for SonarQube:**

* Allow SSH (port 22) and HTTP (port 80) from:

  * **Your IP** (for browser access)
  * **Jenkins Security Group** (to upload analysis results)

💡 *Also*: SonarQube needs to **send feedback to Jenkins**. So, make sure Jenkins’ security group allows incoming traffic on **port 8080** from **SonarQube’s Security Group**.

### 🧪⚙️ Quick Tips:

* Use **T2 or T3 medium instances** (Nexus and SonarQube need more RAM).
* Always **shut down** instances when not in use to save costs 💰.
* If using a VPN or proxy, disable it temporarily during setup and update your security group IP rules accordingly 🌐.

### ✅ Verifying the Setup:

* **Nexus:** Visit `http://<nexus-public-ip>:8081`, login as `admin`, and retrieve the initial password from the EC2 terminal. Complete setup and set a new password.
* **SonarQube:** Visit `http://<sonarqube-public-ip>`, login with `admin/admin`, and reset the password. You’ll soon see beautiful dashboards once we connect Jenkins!

Once both services are running successfully, go ahead and **shut them down** to avoid unnecessary billing. We’ll bring them back up when we’re ready to integrate them into the pipeline.

🎉 That’s it for now! Join me in the next lecture to continue building your CI pipeline.

---

