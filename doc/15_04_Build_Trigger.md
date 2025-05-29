# Build Trigger

## 1. 🚀 Understanding Jenkins Job Triggers: Automate Like a Pro!

Lwt us explore **Jenkins job triggers** — a key ingredient for automation in your DevOps pipeline.

🛠️ Until now, we’ve been manually triggering our Jenkins jobs using the **“Build Now”** button. But did you know Jenkins can trigger jobs **automatically**? That’s right — no need to manually start builds every time! Let’s dive into the most popular ways to trigger Jenkins jobs.

### 🔔 Popular Jenkins Job Triggers

* **🔗 Git Webhooks**: This is one of the most common and powerful triggers. When a commit is pushed to your Git repository (like GitHub), a webhook sends a payload to Jenkins, triggering the job instantly. It’s fast and efficient!

* **🕵️ Poll SCM**: This is the reverse of webhooks. Instead of waiting for GitHub to inform Jenkins, Jenkins periodically checks (polls) the Git repository for new commits. You define the interval (e.g., every 1 or 5 minutes), and Jenkins will act when it detects changes.

* **⏰ Scheduled Builds**: Similar to setting an alarm clock ⏲️. You specify the timing using cron syntax, and Jenkins will automatically run your job at the scheduled times.

* **🌐 Remote Triggers**: A bit advanced but extremely useful! This allows you to trigger Jenkins jobs from **external systems** — like scripts, tools, or Ansible playbooks — using **API calls**. It involves using tokens, secrets, and custom URLs. Don’t worry — we’ll cover this step-by-step.

* **🧩 Build After Other Projects**: A simple dependency trigger. One job finishes, and another begins. Perfect for chaining jobs together in complex pipelines.

These are just a few of the many available triggers. And trust me, for most use cases, these are more than enough to build robust and efficient CI/CD workflows.

### 🛠️ Setting Up for Trigger Testing

Before testing triggers, let’s walk through the required setup:

1. **📁 Create Your Own GitHub Repository**: Don’t use mine 😉. Log into your GitHub account and create a repository (e.g., `jenkinstriggers`). You can make it private or public — we’re not storing sensitive data.

2. **🔐 Set Up SSH Authentication**:

   * Generate SSH keys using `ssh-keygen` (if you haven’t already).
   * Copy the **public key** (not the private one!) to GitHub → **Settings → SSH and GPG Keys**.

3. **📄 Create a Simple `Jenkinsfile`**:
   Just a basic pipeline:

   ```groovy
   pipeline {
     agent any
     stages {
       stage('Build') {
         steps {
           echo 'Hello from Jenkins!'
         }
       }
     }
   }
   ```

   Save this file as `Jenkinsfile` (capital J, no extension) in your local repo and commit it.

4. **🧪 Push Your Code to GitHub**:

   ```
   git add .
   git commit -m "First commit"
   git push origin master
   ```

Get the generated SSH private key from your system (e.g., `cat ~/.ssh/id_rsa`) and we will use it to clone the repo on your Jenkins server.

> ⚠️ **Tip**: If you get the **“Host key verification failed”** error, go to **Manage Jenkins → Configure Global Security**, find **Git Host Key Verification Configuration**, and choose **“Accept first connection”**. This will allow Jenkins to trust GitHub on the first try.

5. **🔧 Create a Jenkins Job**:

   * In Jenkins, create a new **Pipeline** job.
   * Use **Pipeline script from SCM**, select **Git**, and use the **SSH URL** of your repo.
   * Add your **SSH credentials** (private key) to Jenkins. Kind: **SSH username with private key** → **ID**: `gitsshkey` → Username: GitHub account username → **Private Key**: the private key you copied.
   * Set the **Branches to build** to **`main`** if you have used main as your default branch otherwise it will take `master` as the default branch.
   * Set the `Jenkinsfile` path (just `Jenkinsfile` if it's in the root).
   * Save and build. ✅

With this setup in place, you're now ready to experiment with **job triggers**. In the next part, we’ll test each type of trigger we discussed earlier. 🚦

So what are you waiting for? Let’s automate the grind and level up your Jenkins game! 💪

---

## 2. 🚀 Exploring Jenkins Job Triggers: From Webhooks to Cron Jobs 🔄

Let’s dive into the different ways you can **trigger a Jenkins job automatically**—because clicking "Build Now" every time is no fun 😅. Here’s a breakdown of the most common methods used to automate job execution in Jenkins:

### a. 🔗 GitHub Webhook: Push to Trigger

> Note:- If you are running Jenkins locally then this option will not work. If your **Jenkins is running locally**, **GitHub webhooks will *not* work by default**, because GitHub needs to **reach your Jenkins server over the internet**—and local machines typically don't have public IPs or DNS-accessible URLs.

Want your Jenkins job to run every time there’s a new commit? That’s where **GitHub Webhooks** shine!

1. **Copy the Jenkins URL** (up to `:8080`) and go to your **GitHub repository** → `Settings` → `Webhooks`.
2. Click **Add Webhook**, and paste the URL like this:

   ```
   http://<your-jenkins-url>:8080/github-webhook/
   ```

   Make sure to include the trailing slash `/` and select **Content type: application/json**. For VM use (in our case):- `http://192.168.56.10:8080/github-webhook/`
3. Leave the secret blank, and choose to trigger the webhook on **push events**. You can also choose individual events like branches or tags as per your needs.
4. After saving, you’ll see a ✅ green checkmark if it’s working, or ❌ if there’s an issue (check the URL, content type, and Jenkins port access).

Now go to Jenkins → your job → `Configure` → `Build Triggers`, and check ✅ **GitHub hook trigger for GITScm polling**. Save, commit something in GitHub (like `touch testfile.txt`, `git add .`, `git commit -m "test"`, `git push origin main`), and watch Jenkins fire that job 🔥.

### b. 🕐 Poll SCM: Jenkins Checks for Commits

Instead of GitHub notifying Jenkins, this approach lets **Jenkins do the polling**.

1. In your Jenkins job → `Configure` → `Build Triggers`, check ✅ **Poll SCM**.
2. Add a schedule in **cron format**. For example:

   ```
   * * * * *
   ```

   This runs the job **every minute**.

Jenkins will check GitHub regularly. If it detects a change, the job is triggered. It’s not as immediate as webhooks, but great if webhooks are not an option.

In the Jenkins UI, under `Git Polling Log`, you can see the log of polling activity.

### c. 📅 Build Periodically: Scheduled Jobs

Want a job to run at a specific time, regardless of code changes? Use **Build Periodically**!

1. Enable `Build periodically` and use the same cron syntax.
2. Example:

   ```
   30 20 * * 1-5
   ```

   This runs the job at **8:30 PM from Monday to Friday**.

It doesn’t check your repository, just runs at scheduled times ⏰.

### d.🌐 Remote Trigger: Trigger from Anywhere

You can also **trigger Jenkins jobs remotely** from a script or tool like Ansible.

Steps:

1. In the job config, enable **Trigger builds remotely** and provide a token (e.g., `mybuildtoken`). Generate URL & save in a file. 

It says:- "Use the following URL to trigger build remotely: JENKINS_URL/job/build-trigger-github-test/build?token=TOKEN_NAME or /buildWithParameters?token=TOKEN_NAME
Optionally append &cause=Cause+Text to provide text that will be included in the recorded build cause."

Job URL:-
```bash
http://192.168.56.10:8080/job/build-trigger-github-test/build?token=mybuildtoken
```

2. Generate Token for User: Generate your **API Token** under your Jenkins user settings. To do this:- 
    a. Click your username drop down button (Top right corner of the page) 
    b. Security => API Token => Generate
    c. Copy token name and save username:tokenname in a file

Overall Toke (user:token):-
```bash
admin:11b79673933eb8c286c380256fb1561106
```

3. Generate a **CRUMB** using the `wget` command to avoid CSRF issues.

a. wget command is required for this, so download [`wget binary for git bash`](https://eternallybored.org/misc/wget/).
b. Extract `wget.exe` content in c:/program files/Git/mingw64/bin
c. Run below command in Git Bash, (replace username,password,Jenkins URL)
`wget -q --auth-no-challenge --user username --password password --output-document=- "http://JENNKINS_IP:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)"`
d. It will generate a CRUMB. Save the token in a file.

```bash
$ wget -q --auth-no-challenge --user admin --password password --output-document=- "http://192.168.56.10:8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)"

Jenkins-Crumb:c50d3dc2582b2838421f65b60f2e918451fa003d2e3c569caee5b80f98528fd7
```

4. Use a `curl` command like this: `curl -I -X POST http://username:APItoken@Jenkins_IP:8080/job/JOB_NAME/build?token=TOKENNAME -H "Jenkins-Crumb:CRUMB"`

```bash
curl -I -X POST http://admin:11b79673933eb8c286c380256fb1561106@192.168.56.10:8080/job/build-trigger-github-test/build?token=mybuildtoken -H "Jenkins-Crumb:c50d3dc2582b2838421f65b60f2e918451fa003d2e3c569caee5b80f98528fd7"
```

This lets you trigger jobs from **scripts, other Jenkins instances, or tools**, anywhere with network access 🔓.

💡 **Windows users:** You might need to install `wget` separately (e.g., in Git Bash). Mac/Linux users are usually good to go.

### e. 🔁 Build After Another Job

Want to **chain jobs together**? Easy!

1. Create the downstream job first (`test-job`) > Item Type: `Free Style Project`.
2. In `Triggers` → `Build Triggers`, enable **Build after other projects are built**, and enter the upstream job name (`build-trigger-github-test`).
3. In Build Steps > Choose Execute Shell, add simple command:- `echo "Triggered by upstream job"`. Save the job.
3. Now, when the upstream job (`build-trigger-github-test`) finishes, your `test-job` kicks in automatically.

These are some of the **most popular ways to trigger Jenkins jobs** automatically. Whether you're reacting to commits, scheduling builds, or triggering from external tools, you now have the tools to automate your pipelines like a pro! 💪💻

---