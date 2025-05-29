# Continuous Integration Pipeline

## 1. 🐳 From WAR Files to Docker Images: Publishing with Jenkins CI/CD

Previously, our CI pipeline was all about publishing **artifacts**—specifically, the `WAR` file generated after a successful build. Now, we’re taking things a step further. In this updated **Continuous Integration pipeline**, we’ll be publishing **Docker images** instead! 🚀

Before diving in, make sure to check out the **"Introduction to Containers"** section to get familiar with how Docker images are built and pushed. In this pipeline, we’re doing the **same thing—but fully automated** using **Pipeline as Code** in Jenkins.

Here’s how the workflow goes:

1. 💻 A developer makes a code change and pushes it to GitHub.
2. 🔁 Jenkins detects the change automatically and pulls the latest code.
3. ✅ It runs **unit tests** to ensure everything still works.
4. 🧹 It performs **code analysis** using **Checkstyle**.
5. 🔎 Then another round of code analysis is done using **SonarQube**.
6. 📊 Results are uploaded to the **SonarQube server**, and Jenkins waits for the **quality gate** approval.
7. 🐋 If everything looks good, Jenkins builds a **Docker image** containing the final artifact.
8. 📦 The image is then pushed to a **Docker registry**.

In our example, we’re using **Amazon ECR (Elastic Container Registry)** for storing Docker images. However, you could easily switch this to:

- 🐳 **Docker Hub**
- ☁️ **Google Container Registry (GCR)**
- 🧊 **Azure Container Registry**
- 🏠 Or even your private **Nexus registry**

The only part that really differs across registries is the **login process**. The rest of the pipeline remains largely the same.

![Jenkins With Amazon ECR](/doc/images/Jenkins_With_Amazon_ECR.png)

In the next section, we’ll walk through the actual **Jenkins pipeline code** that performs all of these tasks. Then, we’ll cover the **prerequisites** you'll need to have in place before running it.🎬

---

## 2. 🔧 Building & Publishing Docker Images to Amazon ECR with Jenkins

Welcome! 👋 In this section, we’ll explore how to **build a Docker image** and **push it to Amazon ECR (Elastic Container Registry)** using Jenkins. Let’s walk through the updated stages in our CI pipeline and the setup needed to make it all work. 🚀

### 🔁 Recap of Our Pipeline Stages

Here’s a quick overview of the pipeline flow so far:

1. 📥 **Fetch source code** (from the `docker` branch)
2. 🛠️ **Build artifact**
3. ✅ **Run unit tests**
4. 🧹 **Checkstyle analysis**
5. 🔎 **SonarQube analysis**
6. 📊 **Upload results to SonarQube & wait for Quality Gate**

Now, instead of uploading the artifact to Nexus, we’ll **build a Docker image** that contains the artifact and **push it to Amazon ECR**—making the Docker image our new deployable artifact. 🐳

Sample Jenkins Pipeline Code, see the actual Jenkinsfile [here](/08_jenkins/pipeline/08_amazon_ECR_Integration_with_docker/Jenkinsfile):-

```groovy
pipeline {
    agent any
    tools {
        maven "MAVEN_3.9"
        jdk "JDK_17"
    }
    environment {
        registryCredential = 'ecr:us-east-1:awscreds'
        imageName = "716657688884.dkr.ecr.us-east-1.amazonaws.com/vprofileappimg"
        vprofileRegistry = "https://716657688884.dkr.ecr.us-east-1.amazonaws.com"
    }
    stages {
        stage('Fetch code') {
            steps {
               git branch: 'docker', url: 'https://github.com/vikas9dev/vprofile-project.git'
            }
        }
        stage('Build'){
            steps{
               sh 'mvn install -DskipTests'
            }
            post {
               success {
                  echo 'Now Archiving it...'
                  archiveArtifacts artifacts: '**/target/*.war'
               }
            }
        }
        stage('UNIT TEST') {
            steps{
                sh 'mvn test'
            }
        }
        stage('Checkstyle Analysis') {
            steps{
                sh 'mvn checkstyle:checkstyle'
            }
        }
        stage("Sonar Code Analysis") {
            environment {
                scannerHome = tool 'sonar6.2'
            }
            steps {
              withSonarQubeEnv('sonarserver') {
                sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                   -Dsonar.projectName=vprofile \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
              }
            }
        }
        stage("Quality Gate") {
            steps {
              timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
              }
            }
          }
        stage('Build App Image') {
          steps {
            script {
                dockerImage = docker.build( imageName + ":$BUILD_NUMBER", "./Docker-files/app/multistage/")
            }
          }
        }
        stage('Upload App Image') {
          steps{
            script {
              docker.withRegistry( vprofileRegistry, registryCredential ) {
                dockerImage.push("$BUILD_NUMBER")
                dockerImage.push('latest')
              }
            }
          }
        }
        stage('Remove Container Images'){
            steps{
                sh 'docker rmi -f $(docker images -a -q)'
            }
        }
    }
}
```

### 🧩 Using the Docker Plugin in Jenkins

```groovy
stage('Fetch Code') {
  steps {
    git branch: 'docker', url: 'https://github.com/vikas9dev/vprofile-project.git'
  }
}
stage('Build') {
  steps {
    sh 'mvn install -DskipTests'
  }
  post {
    success {
      echo 'Now archiving the artifact...'
      archiveArtifacts artifacts: '**/target/*.war'
    }
  }
}
```

Jenkins doesn't natively support Docker operations, so we use the **Docker Pipeline plugin**. This plugin provides useful methods like:

- `docker.build()`: Builds the image from a Dockerfile.
- `docker.withRegistry()`: Authenticates and pushes the image to a registry.

We’ll pass two key arguments to `docker.build()`:

- 🏷️ **Image name** (with tag)
- 📁 **Path to the Dockerfile**

Our Dockerfile lives in:- [`vprofile-project/Docker-files/app/multistage/Dockerfile`](https://github.com/vikas9dev/vprofile-project/blob/docker/Docker-files/app/multistage/Dockerfile)

It's a **multi-stage Dockerfile**:

- Stage 1: Fetch source code, switch to the `docker` branch, and run `mvn install` to generate the artifact.
- Stage 2: Start with a **Tomcat base image**, remove the default app, and copy the artifact into the image.

Once this Docker image is built, it contains your app ready to run on Tomcat. 🎯

### ☁️ Pushing the Docker Image to Amazon ECR

```groovy
stage('Upload App Image') {
  steps {
    script {
      docker.withRegistry(vprofileRegistry, registryCredential) {
        dockerImage.push("${BUILD_NUMBER}")
        dockerImage.push('latest')
      }
    }
  }
}
```

We use `docker.withRegistry()` to log in to Amazon ECR and push the image. This method takes:

- 🔗 **Registry URL** (ECR URL)
- 🔐 **Registry credentials** (stored in Jenkins)

We tag our image with:

- 🏷️ **Build number**
- 🏷️ **latest** (default tag used when no tag is specified)

### 🔑 Environment Variables & Setup

```groovy
environment {
    registryCredential = 'ecr:us-east-1:awscreds'
    imageName = "716657688884.dkr.ecr.us-east-1.amazonaws.com/vprofileappimg"
    vprofileRegistry = "https://716657688884.dkr.ecr.us-east-1.amazonaws.com"
}
```

Let’s break down the variables we’ll use:

- `imageName`: Format – `accountID/image-name`
- `dockerRegistry`: Your ECR URL
- `registryCredential`: AWS credentials stored in Jenkins

These variables will be dynamically used in our pipeline.

### ✅ Prerequisites: Jenkins & AWS Setup

To execute this pipeline successfully, we need to complete the following:

#### 🔐 AWS Setup

- Create an **IAM user** with permissions for ECR.
- Generate **Access Key** and **Secret Key**.

#### 📦 AWS ECR

- Create an **ECR repository** to store Docker images.

#### 🛠️ Jenkins Configuration

- **Install Docker Engine** on the Jenkins host.

- Add the **Jenkins user to the `docker` group** to allow Docker commands.

- Install these **Jenkins plugins**:

  - Docker
  - Docker Pipeline
  - AWS SDK for Jenkins
  - Amazon ECR

- Store **AWS credentials** in Jenkins (as credentials for the pipeline).

- (Optional) Install **AWS CLI**—helpful for future CD steps.

> 💡 Don’t worry if the Dockerfile syntax seems overwhelming. We’ll cover Docker in-depth later. For now, focus on understanding the **pipeline flow and structure**.

### 📥 What’s Next?

- 🔄 Review the pipeline script from the resources section.
- 🔍 Read through it and understand how each stage works.
- 🧠 Research Jenkins and Docker Pipeline documentation for deeper clarity.
- 🎥 Rewatch the explanation video if needed.

Ready to execute the pipeline? Let’s move to the next lecture and bring this all to life! 💪

---

## 3. 🚀 Setting Up Jenkins with AWS, Docker, and ECR: Prerequisites for a Smooth CI/CD Pipeline

Before we dive into running our Jenkins pipeline, let’s ensure we’ve got all the necessary tools and plugins set up 🛠️. These steps will lay the foundation for deploying Docker images to AWS Elastic Container Registry (ECR) and, later, to ECS.

### ✅ Installing AWS CLI & Docker Engine

Although AWS CLI isn’t needed immediately, it becomes essential when we deploy our Docker images to AWS ECS in upcoming lectures. So, let’s install it now.

1. **SSH into your Jenkins VM:**

   ```bash
   ssh -i <key-path> ubuntu@<jenkins-public-ip>
   ```

2. **Install AWS CLI:**

   ```bash
   sudo apt update
   sudo snap install aws-cli --classic
   ```

3. **Switch to root and install Docker Engine:**

   - Visit [docs.docker.com](https://docs.docker.com/) and follow [instructions](https://docs.docker.com/engine/install/) for ✔️👍🟢 **Docker Engine** (not the ❌🙅 **Docker Desktop**).
   - Add the Docker repo and install the engine using the provided commands.
   - Confirm Docker is running:

     ```bash
     systemctl status docker
     ```

     Use `Q` for quit.

4. **Allow Jenkins user to access Docker:**

   Jenkins jobs run as the `jenkins` user, which doesn’t have Docker permissions by default.

   ```bash
   su - jenkins
   docker ps
   exit
   ```

   Add Jenkins to the Docker group:

   ```bash
   sudo usermod -aG docker jenkins
   id jenkins
   ```

   Then reboot the Jenkins instance to apply changes:

   ```bash
   reboot
   ```

### 🔐 Creating IAM User & ECR Repository in AWS

While your instance is rebooting, let’s set up the necessary AWS services:

1. **Create IAM User:**

   - Go to AWS IAM → Users → **Create User**
   - Name it `jenkins-go`
   - Attach policies directly:

     - `AmazonEC2ContainerRegistryFullAccess`
     - `AmazonECS_FullAccess`

   - Click **Create User**
   - After user creation, go inside it > **Security Credentials**.
   - Create **Access Key & Secret Key** with **CLI** use case and **download the CSV file**.

2. **Create ECR Repository:**
   - Go to AWS → ECR → **Create Repository**.
   - Name it something like `vprofile-app-image`.
   - Copy the repository URI—you’ll need it for your pipeline.

### 🧩 Installing Jenkins Plugins

Back in Jenkins:

- Go to **Manage Jenkins → Plugins → Available**
- Search and install the following plugins:

  - ✅ Amazon Web Services SDK: All
  - ✅ Amazon ECR
  - ✅ Docker Pipeline
  - ✅ CloudBees Docker Build and Publish

These plugins will allow Jenkins to interact securely with AWS and build/push Docker images.

### 🔐 Storing AWS Credentials in Jenkins

Now let’s store the AWS credentials safely in Jenkins:

- Go to **Manage Jenkins → Credentials → System → Global credentials**
- **Add Credentials → Kind: AWS Credentials**
- Use the access key and secret key from the CSV file
- Set **ID** as `awscreds` (or whatever you use in your pipeline script). We have used `registryCredential = 'ecr:us-east-1:awscreds'` in the pipeline script inside Environment Variables section.

### 🧱 Update and Run the Pipeline

Make sure your pipeline script uses:

- The correct **ECR URI** for image tagging and pushing
- The right **region** (e.g., `us-east-1`)
- The correct **credential ID** (e.g., `awscreds`)

Your pipeline should:

1. Fetch code
2. Build the app
3. Build a Docker image
4. Push it to ECR
5. ✅ **\[New]** Clean up Docker images post-push to free up disk space:

   ```groovy
   stage('Cleanup Docker Images') {
     steps {
       sh 'docker rmi -f $(docker images -aq)'
     }
   }
   ```

After running the pipeline, verify the image exists in ECR. Try multiple builds—you’ll see image tags like `1`, `2`, etc., based on the build number.

And that’s it 🎉 Your CI pipeline is fully functional with Docker and AWS!

If you're continuing, keep your instances running. If you're taking a break, remember to shut down Jenkins and SonarQube to save resources. See you in the next lecture! 👋

---

## 4. 🚀 From CI to CD: Deploying Docker Images to Amazon ECS 🐳➡️☁️

![Amazon ECS](/doc/images/Amazon_ECS.png)

In this session, we’re shifting gears — it's time to move from **Continuous Integration (CI)** to **Continuous Delivery (CD)**! 🎯 Let’s take our Docker images beyond just building and testing — we’re going to **deploy them to the cloud**. 🌥️

You already know how our CI pipeline works:

* A developer pushes code to GitHub 🧑‍💻
* Jenkins fetches the code ⚙️
* Tests run ✅
* Code is analyzed and results are uploaded to SonarQube 📊
* The quality gate is checked 🚧
* If all is well, the Docker image is published to **Amazon ECR (Elastic Container Registry)** 📦

Now it’s time to host that Docker image. This is where **Amazon ECS (Elastic Container Service)** comes in — a platform that runs and manages your containers securely and at scale. Think of ECS as your Docker image’s new home 🏠🔐.

In a production setup, ECS will:

* Fetch the latest Docker image from ECR 🐋
* Deploy it as a running container service 🛠️
* Ensure reliability, scalability, and security 🔄🔐📈

Sure, for local development or testing, you can simply use Docker Engine and run containers with `docker run`. But in production? That’s not enough. You’d have to manage the VM, the engine, networking, and security yourself 😰 — no thanks!

For production-grade deployments, you need a **container orchestration platform** like **Kubernetes**. But don’t worry — we’ll cover that in-depth in a later section. Options like:

* **EKS** (Elastic Kubernetes Service) from AWS ☁️🐳
* **AKS** from Azure ☁️🔷
* **GKE** from Google ☁️🔵
* **OpenShift** by Red Hat 🎩

...will all be explored in detail soon.

For now, we’ll keep things simple and reliable with **Amazon ECS**. It’s perfect for launching containers at scale with minimal configuration — and it integrates smoothly with your CI/CD pipeline. 🚀

In the next lecture, we’ll dive into the actual **pipeline code** and see how to add one more stage to deploy to ECS, along with the **prerequisites** you’ll need.

Ready to complete the pipeline? Let’s go! 👉💻

---

## 5. 🛠️ Finalizing the CI/CD Pipeline: Deploying to Amazon ECS 🚀🐳

Alright, let’s dive into the code that completes our CI/CD pipeline by **deploying our Docker image to Amazon ECS**! 📦➡️🖥️

Up to the CI part, everything remains the same — code is committed, tested, analyzed, and the Docker image is pushed to **Amazon ECR**. Now comes the **CD (Continuous Delivery)** part, where we deploy that image to **Amazon ECS**, as discussed earlier.

### 🔧 Defining Deployment Variables

```groovy
environment {
    // new ECS variables
    clusterName = 'vprofile-cluster'
    serviceName = 'vprofile-app-task-service-bqx25kvp'
}
```

We start by setting two important variables in our pipeline:

* `cluster`: This is the name of the ECS cluster where your service will run.
* `service`: This refers to the ECS service responsible for running the containerized task.

An **ECS service** pulls the Docker image from **ECR**, runs your container, and can also be configured to work with **Elastic Load Balancers (ELB)** for routing traffic efficiently ⚖️💡.

```groovy
stage('Deploy to ECS') {
    steps {
        withAWS(credentials: 'awscreds', region: 'us-east-1') {
            sh "aws ecs update-service --cluster ${clusterName} --service ${serviceName} --force-new-deployment"
        }
    }
}
```

Before using these variables, make sure to:

1. **Create an ECS cluster**
2. **Create a service within that cluster**

These are prerequisites before moving on to the deployment stage.

### 🔌 Installing the Jenkins Plugin

To deploy from Jenkins, we use a specific plugin:

```
Pipeline: AWS Steps
```

This plugin enables Jenkins to interact with AWS services through pipeline steps.

You’ll also need:

* AWS credentials (already saved in Jenkins 🔐)
* Your target AWS region 🌍

Optional: To view the steps in better way, you can install the `Pipeline: Stage View` plugin.

### 🖥️ Deploying with AWS CLI in Jenkins

Once the plugin is installed and credentials are configured, we execute a shell command in Jenkins using `aws ecs update-service`. Here's the command structure:

```bash
aws ecs update-service \
  --cluster <cluster-name> \
  --service <service-name> \
  --force-new-deployment
```

What this command does:

* Pulls the **latest Docker image** from ECR 🐳
* **Stops the old task** running the previous image ❌
* **Starts a new task** with the updated container ✅

This is the final piece of the puzzle 🧩. With this stage added, your CI/CD pipeline is now capable of **automatically delivering and deploying Dockerized applications** to **Amazon ECS** — fast, reliable, and production-ready! 🎉

Get ready — in the next lecture, we’ll see this in action with the complete pipeline code! 👨‍💻📈

---

## 6. 🚀 Setting Up an ECS Cluster and Deploying Your Container

In this section, we’ll walk through how to set up an **Amazon ECS (Elastic Container Service)** cluster and run your containerized application on it using **AWS Fargate** — a powerful serverless compute engine. Let’s dive right in! 🐳✨

First, head over to the ECS section in your AWS Console. 

### 🌐 Why ECS?

Amazon ECS is a fully managed container orchestration service that makes it incredibly easy to deploy, manage, and scale containerized applications. It’s reliable, scalable, and integrates beautifully with the rest of the AWS ecosystem.

### 🛠️ Step 1: Create an ECS Cluster

Click on **"Clusters" > "Create Cluster"**, and name it something like `vprofile-cluster`. Leave the subnet and VPC selections as default — AWS will pick all the availability zones for you.

#### 🏗️ Launch Types:

* **AWS Fargate** (recommended): Fully serverless — AWS handles the compute provisioning, scaling, and infrastructure.
* **EC2 Launch Type**: Requires managing EC2 instances and capacity.
* **ECS Anywhere**: Allows you to bring your own infrastructure.

Choose **Fargate** for a hassle-free, serverless deployment. Also, in Monitoring section, enable **Container Insights with Enhanced Observability** to monitor resource utilization like CPU and memory through CloudWatch 📊.

In the **Tags** section, add a tag (e.g., `Name: vprofile-cluster`) — even though it says optional, omitting tags may cause issues in some setups.

> 💡 If the cluster creation fails, don’t worry! Just repeat the process with the same settings — sometimes it's a minor glitch.

### 🧱 Step 2: Define a Task Definition

Next, we create a **task definition** (e.g., `vprofile-app-task`), which is essentially a blueprint for our container: image source, resources, ports, etc.

* **Launch Type**: AWS Fargate
* **Architecture**: Linux, x86\_64
* **CPU & Memory**: 1 vCPU and 2GB RAM (minimum for Fargate)
* **Task Execution Role**: Let AWS create a new role
* **Container Details**: Name it something like `vproapp`, Use the URI from your ECR repository (like `825765386084.dkr.ecr.us-east-1.amazonaws.com/vprofile-app-image`).
* **Port Mapping**: Container port **8080** (since Tomcat runs on this)
* **Logging**: Enable Log collection (Amazon CloudWatch).
* **Tags**: Add a tag (e.g., `Name: vprofile`)

📌 **Important**: After creating the task definition, open the task definition, and click on the link of "Task Execution Role"  > `ecsTaskExecutionRole` (Or go to IAM > Roles > `ecsTaskExecutionRole`), and **attach the `CloudWatchLogsFullAccess` policy** (Add Permissions > Attach Policies) to it so your logs can be collected without errors.

### 🧳 Step 3: Launch the Service

Now that the cluster and task definition are ready, let’s launch the container as a **service** in ECS. Go to created Cluster > vprofile > Services > Create Service.

* **Launch Type**: Fargate
* **Service Type**: `Service` (for long-running tasks like web apps)
* **Task Definition**: In Family, choose the one (task) you just created.
* **Service Name**: Something like `vprofile-app-svc`
* **Desired Tasks**: 1 (you can scale this up later)
* **Security Groups**: Create a new security group as below.

Disable **Deployment Failure Detection** for now — it can interfere with first-time deployments.

#### 🔒 Security Group

Create a new security group (e.g., `vproapp-ecs-elb-sg`):

* **Allow HTTP (port 80) from Anywhere** — for external access via Load Balancer
* **Allow Custom TCP (port 8080) from Anywhere** — for internal communication between the Load Balancer and container

#### ⚖️ Load Balancer

* Select **Application Load Balancer**
* **Listener Port**: 80
* **Target Group Port**: 8080
* Provide a name like `vprofile-elb-ecs` and `vprofile-ecs-tg`

Click **Create Service** — this might take a few minutes (up to 5-10 minutes)  ⏳

### ✅ Validate Your Deployment

Once the service is running:

* Go to **ECS > Services**, verify that **1 of 1 task** is running.
* Click on the **Load Balancer URL** (DNS Name) to access your application in the browser — your containerized app should now be live! 🎉 You can also get the DNS Name from ECS > Clusters > vprofile-cluster > Configuration and Networking > Network Configuration > DNS names. 

You can also check:

* **Logs** under ECS Task > Container > Logs
* **Target Group Health** in the EC2 > Load Balancers section

In this setup, we manually deployed our container by referencing the Docker image in the task definition. In the next section, we'll automate this through **Jenkins** — pushing a new Docker image and triggering an ECS service update for a seamless CI/CD pipeline. 🔄👨‍💻

Stay tuned! 🚀

---

## 7. 🚀 Deploying to ECS from Jenkins: Complete CI/CD in Action! 🧑‍💻🐳

Alright, it's showtime! We're now ready to complete our CI/CD pipeline by automating the deployment of our Docker container to AWS ECS from Jenkins 💡.

We'll start by feeding the **ECS cluster** and **service information** into the Jenkins pipeline script. First things first—grab your ECS details:

* 🏗️ **Cluster Name:** `vprofile-cluster`
* 🔧 **Service Name:** `vprofile-app-task-service-bqx25kvp`

```groovy
environment {
  clusterName = 'vprofile-cluster'
  serviceName = 'vprofile-app-task-service-bqx25kvp'
}
stage('Deploy to ECS') {
    steps {
        withAWS(credentials: 'awscreds', region: 'us-east-1') {
            sh '''
                echo "Deploying to ECS..."
                echo "Cluster: $clusterName"
                echo "Service: $serviceName"

                aws ecs update-service \
                    --cluster "$clusterName" \
                    --service "$serviceName" \
                    --force-new-deployment
            '''
        }
    }
}
```

Ensure the **AWS CLI** is installed on your Jenkins instance. If you followed along earlier while setting up Docker, you likely have this installed already. If not, just log in to Jenkins and install the AWS CLI manually 🛠️.

Also, double-check that your **AWS credentials** are properly configured in Jenkins and that the IAM user/role has sufficient permissions for ECS. If you set this up with me previously, no changes are needed ✅.

Now, head to Jenkins and install the required plugin:

1. Go to **Manage Jenkins → Manage Plugins**
2. Search for `Pipeline: AWS Steps` or just `AWS Steps`
3. Install the plugin 📦

Next, create a new Jenkins job:

* 🆕 Go to **New Item**
* Name it something like `CICD-Pipeline-ECS`
* Choose **Pipeline** as the project type

Before you paste your pipeline code, verify the AWS region in your script. Mine is `us-east-2`—make sure to replace it with your region if different 🌍.

Once you've saved the pipeline script, it's time to **test the deployment**! 🎯

Head over to **ECS → Tasks** and note the current container ID. When Jenkins executes the `aws ecs update-service --force-new-deployment` command, it will:

* 🚀 Spin up a new container with the **latest Docker image**
* 📦 Gradually decommission the old container

Monitor the ECS **deployments** and **events** tabs—you’ll see a new task get created and the older one transitioning out. With just one task in our setup (for simplicity and low cost), ECS will seamlessly replace the old container with the new one 🔄.

Check the container logs to verify that your application (`vprofile`) has come up successfully and is generating logs 📋.

After a short wait, you'll see only one **healthy running task**, and the previous one will be marked as **stopped**. 🎉

Congratulations! You've completed a full CI/CD cycle:

* ✅ Fetched code
* 🛠️ Built Docker image
* 🔍 Ran code analysis
* 📤 Pushed to Amazon ECR
* 🚀 Deployed to ECS using Jenkins

Later in the course, we'll take things a step further by deploying to a **Kubernetes cluster**. But for now, this wraps up our ECS deployment journey. See you in the next one! 👋📘

---

## 8. 🔥 Cleaning Up After Deployment: A Quick Wrap-Up 🧹

Alright, now that the deployment is done, it’s time for some cleanup! 🎯

Let’s start with Jenkins and SonarQube. If you're done using them for now, feel free to stop their services. 🚫 For SonarQube or Nexus, you can even delete them entirely if you wish. However, for Jenkins, it's a good idea to **just stop it** rather than deleting—this way, you can reuse the same setup later without starting from scratch. 💡

Next up: your **ECS Cluster**. You can’t delete it straight away. First, head over to your **ECS service**, click **Edit**, and set the **desired task count to zero**. ✅ Update the service, then go ahead and delete it. Once the service is removed, you can try deleting the cluster.

If you encounter an error like *“task is still running”*, don’t worry. ⏳ It just means a container is still active. You can stop the running task manually by selecting it and clicking **Stop**. Then, try deleting the cluster again. And voilà — it’s gone! 🎉

That wraps up this part of the journey. See you in the next one! 🚀

---
