# ⚙️ Prerequisites: Setting Up Your Tools, Accounts, and AWS Environment

Before diving into the hands-on sections of the course, it’s important to get a few prerequisites in place. This setup will ensure a smooth learning experience and prepare your system for the tools and technologies used throughout the project.

## 1. Essential Tools Installation

Several tools need to be installed locally to follow along with the exercises and projects. These include:

- **Oracle VM VirtualBox** – for running virtual machines.
- **Vagrant** – for managing virtual machine environments.
- **Git Bash** – a terminal for Git and command-line utilities.
- **Chocolatey** _(for Windows users)_ or **Homebrew** _(for macOS)_ – for easy package management.

Additional tools required:

- **Java JDK 8** – required for compiling and running Java-based projects.
- **Apache Maven** – a build automation tool for Java applications.
- **IntelliJ IDEA** – the recommended IDE for development (alternatively, Visual Studio Code or any preferred IDE).
- **Sublime Text/VS Code** – a lightweight editor for quick edits.
- **AWS CLI** – for interacting with AWS services from the terminal.
- **Terraform** – will be installed during project-specific steps.

### Account Sign-Ups

A few online accounts will be necessary for storing code, managing infrastructure, and integrating development tools:

- **GitHub** – to access and manage source code repositories.
- **Docker Hub** – for storing and pulling container images.
- **SonarCloud** – for static code analysis and quality checks.
- **Domain Registrar** – a domain will be purchased (GoDaddy/CloudFlare/any registrar can be used).

### AWS Setup

Amazon Web Services (AWS) will be the cloud platform used in this course. To use it safely and effectively, some initial setup steps are required:

- Create an **AWS Free Tier account**.
- Set up an **IAM user** with multi-factor authentication for security.
- Create a **billing alarm** to monitor usage and prevent unexpected charges.
- Request an **SSL certificate** to enable HTTPS for secure web access.

> ⚠️ Note: Some of the commands or steps in this section may be unfamiliar at first. That’s perfectly fine—they’ll be explained in detail later in the course.

---

## 2. 🛠 Installing Chocolatey: A Package Manager for Windows

To streamline the installation of various tools on Windows, one highly recommended utility is **[Chocolatey](https://chocolatey.org/docs/installation)**—a powerful package manager that lets you install software through the command line.

### What is Chocolatey?

Chocolatey allows you to install applications like Notepad++, Git, VirtualBox, and many others using simple terminal commands. For example:

```bash
choco install notepadplusplus
```

This eliminates the need to search, download, and manually install each tool.

> 🔹 **Note**: Installing Chocolatey is **optional**. If you prefer manual installation, or face issues setting it up, you can skip this part and install each tool individually by downloading them from their official websites.

### Chocolatey vs Homebrew

- **For Windows**: Chocolatey is the recommended tool.
- **For macOS**: A similar tool called **Homebrew** will be covered in the next section.

### How to Install Chocolatey

1. **Open PowerShell as Administrator**  
   Right-click on PowerShell and select **"Run as Administrator"**.

2. **Check PowerShell Execution Policy**  
   Run the following command:

   ```powershell
   Get-ExecutionPolicy
   ```

   - If the result is `Restricted`, you need to change it by running:

     ```powershell
     Set-ExecutionPolicy AllSigned
     ```

   - Type `Y` and press Enter when prompted.

3. **Install Chocolatey**  
   Copy and run the official Chocolatey installation command in the administrator PowerShell:

   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; `
   [System.Net.ServicePointManager]::SecurityProtocol = `
   [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
   iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

   > 💡 If you encounter an error, it could be due to antivirus software blocking the installation. Temporarily disabling the antivirus (e.g., McAfee) may help resolve the issue.

4. **Restart PowerShell**  
   After installation, close and reopen PowerShell to begin using Chocolatey.

### Using Chocolatey

Once installed, Chocolatey can be used to install other tools quickly. For example:

```bash
choco install virtualbox
choco install intellijidea-community
```

You can also visit the [Chocolatey website](https://community.chocolatey.org/) to search for tools and view their installation commands.

> ✅ Chocolatey offers a faster, automated way to install and manage software—especially useful when setting up a development environment.

After installing Chocolatey, it's a good idea to confirm that the installation was successful. Run one of the following commands: `choco -v`, `choco`.

---

## 3. ⚙️ Setting Up Essential Development Tools (Windows, macOS & Linux)

Before we dive deeper into the course, let’s get your system ready by installing some essential development tools. The instructions below cover **Windows** (using Chocolatey) and **macOS** (using Homebrew), and Linux.

### a. 🪟 Windows Setup Using Chocolatey

Run the following commands in **PowerShell (as Administrator)**:

```bash
choco install virtualbox --version=7.1.4 -y
choco install vagrant --version=2.4.3 -y
choco install git -y
choco install corretto17jdk -y
choco install maven -y
choco install awscli -y
choco install intellijidea-community -y
choco install vscode -y
choco install sublimetext3 -y
```

### b. 🍎 macOS Setup Using Homebrew

[Homebrew](https://brew.sh/) is a popular package manager for macOS that simplifies installing software.

#### ✅ Installing Homebrew

Follow the official guide:  
🔗 [Homebrew Installation Guide](https://brew.sh/)

After installation, verify with:

```bash
brew -v
```

You should see the Homebrew version if the installation was successful.

#### 📄 Configure `.curlrc` (Optional)

Create a `.curlrc` file in your home directory to avoid SSL issues during development:

```bash
echo -k > ~/.curlrc
cat ~/.curlrc  # Confirm the contents
```

#### 📦 Install Required Tools with Homebrew

> ⚠️ **Note**: `virtualbox` is **not compatible with Mac M1/M2 chips**.

Run these commands in **Terminal**:

```bash
brew install --cask virtualbox
brew install --cask vagrant
brew install --cask vagrant-manager
brew install git
brew install openjdk@17
sudo ln -sfn $HOMEBREW_PREFIX/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
exec zsh -l
brew install maven
brew install --cask visual-studio-code
brew install --cask intellij-idea
brew install --cask intellij-idea-ce
brew install --cask sublime-text
brew install awscli
```

### c. 🐧 Linux (RHEL/CentOS/AlmaLinux/Rocky) Setup

For Linux users using **RHEL-based distros**, follow these commands:

#### 🖥️ Install VirtualBox

```bash
sudo yum update
sudo yum install patch gcc kernel-headers kernel-devel make perl wget -y
sudo reboot
```

After rebooting, log in and run:

```bash
sudo wget http://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -P /etc/yum.repos.d
sudo yum install VirtualBox-7.1 -y
```

#### 📦 Install Vagrant

```bash
sudo dnf update -y
sudo dnf config-manager --add-repo=https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo dnf install vagrant -y
```

#### 🧑‍💻 Install Visual Studio Code

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

dnf check-update
sudo dnf install code -y
```

#### 🔧 Install Git

```bash
sudo dnf install git -y
```

#### ☕ Install JDK 17 & Maven

```bash
sudo dnf install java-17-openjdk java-17-openjdk-devel -y
sudo dnf install maven-openjdk17 -y
```

### d. 🐧 Tools Prerequisites for Ubuntu 24

To prepare your Ubuntu 24 environment for development, follow these steps to install all required tools including VirtualBox, Vagrant, Git, JDK, Maven, VS Code, and Sublime Text.

#### 🖥️ Install VirtualBox

Open your terminal and run the following commands:

```bash
sudo apt update
sudo apt install curl wget gnupg2 lsb-release -y

curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/vbox.gpg
curl -fsSL https://www.virtualbox.org/download/oracle_vbox.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/oracle_vbox.gpg

echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

sudo apt update
sudo apt install -y linux-headers-$(uname -r) dkms
sudo apt install virtualbox-7.1 -y

# Add your user to the vboxusers group
sudo usermod -aG vboxusers $USER
newgrp vboxusers
```

#### 📦 Install Vagrant

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install vagrant -y
sudo apt install libarchive-dev libarchive-tools -y
```

#### 🔧 Install Git

```bash
sudo apt install git -y
```

#### ☕ Install JDK 17

```bash
sudo apt-get install openjdk-17-jdk -y
```

#### 📦 Install Maven

```bash
sudo apt-get install maven -y
```

#### 💻 Install Visual Studio Code

```bash
sudo apt-get install wget gpg -y

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg

echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

rm -f packages.microsoft.gpg
sudo apt install apt-transport-https -y
sudo apt update
sudo apt install code -y
```

#### 📝 Install Sublime Text

```bash
sudo apt update
sudo apt install dirmngr gnupg apt-transport-https ca-certificates software-properties-common -y

curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo add-apt-repository "deb https://download.sublimetext.com/ apt/stable/"
sudo apt install sublime-text -y
```

### e. ✅ Verify Tools Installation

```bash
git --version
java -version
mvn -v
aws --version
code --version
vagrant --version
VBoxManage --version
```

---

## 4. 🔐 Creating Accounts for DevOps Tooling

Before we dive into our projects, let’s set up a few essential accounts that will be used throughout the course. These include GitHub, Docker Hub, SonarCloud, and a custom domain. Additionally, we’ll prepare for AWS usage by understanding the free tier setup.

### 1️⃣ Create a GitHub Account

GitHub will be our central platform for storing and sharing code repositories.

**Steps to sign up:**

1. Visit [https://github.com](https://github.com).
2. Click on **Sign up** and fill in:
   - **Username**
   - **Email address**
   - **Password**
3. Complete the verification steps (like selecting images).
4. Choose the **Free** plan when prompted.
5. Select your preferences (e.g., teacher, student, etc.).
6. Check your inbox and **verify your email** to activate your account.

Once completed, your GitHub account is ready!

### 2️⃣ Purchase a Domain Name (Optional but Recommended)

Having your own domain helps simulate real-world deployments.

We recommend using [GoDaddy](https://www.godaddy.com/) due to its ease of use and affordable domains.

**Steps:**

1. Create a GoDaddy account and sign in.
2. Search for a domain — avoid common names (e.g., `mydevops.com`) to keep the cost low.
3. Try domain extensions like `.xyz`, which are cheaper. For example:  
   `myinfo.xyz` → ₹169 for 1 year.
4. Reduce the registration period to **1 year**.
5. Skip all add-ons (like website builders or advanced protection).
6. Proceed to checkout and complete the payment.

📌 _Tip: If you’re unsure about purchasing now, you can skip this step and return later. However, we strongly recommend owning a domain for production-like scenarios._

### 3️⃣ Create a Docker Hub Account

Docker Hub will host and manage our container images.

**Steps:**

1. Visit [https://hub.docker.com](https://hub.docker.com).
2. Click on **Sign up**.
3. Provide:
   - **Username**
   - **Email address**
   - **Password**
4. Complete CAPTCHA and choose the **Free** plan.
5. Verify your email to activate the account.

Your Docker Hub account is now ready to push and pull images.

### 4️⃣ Sign Up for SonarCloud

SonarCloud helps us with code quality and static analysis.

**Steps:**

1. Ensure you’re logged into GitHub in the same browser.
2. Visit [https://sonarcloud.io](https://sonarcloud.io).
3. Click **Sign up**, then select **GitHub** as the provider.
4. Authorize SonarCloud to access your GitHub account.
5. Complete the setup and create a new organization or project when prompted.

That’s it! SonarCloud is now ready to be used in your CI/CD pipeline.

---
