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

Our Dockerfile lives in:

```
docker-files/app/multistage/Dockerfile
```

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

===========================================================================================
DONE TILL HERE.
===========================================================================================

2. **Create ECR Repository:**
   - Go to AWS → ECR → **Create Repository**.
   - Name it something like `vprofile-app-image`.
   - Copy the repository URI—you’ll need it for your pipeline.

### 🧩 Installing Jenkins Plugins

Back in Jenkins:

- Go to **Manage Jenkins → Plugins → Available**
- Search and install the following plugins:

  - ✅ AWS SDK for Jenkins
  - ✅ Amazon ECR
  - ✅ Docker Pipeline
  - ✅ CloudBees Docker Build and Publish

These plugins will allow Jenkins to interact securely with AWS and build/push Docker images.

### 🔐 Storing AWS Credentials in Jenkins

Now let’s store the AWS credentials safely in Jenkins:

- Go to **Manage Jenkins → Credentials → System → Global credentials**
- **Add Credentials → Kind: AWS Credentials**
- Use the access key and secret key from the CSV file
- Set **ID** as `aws-creds` (or whatever you use in your pipeline script)

### 🧱 Update and Run the Pipeline

Make sure your pipeline script uses:

- The correct **ECR URI** for image tagging and pushing
- The right **region** (e.g., `us-east-1`)
- The correct **credential ID** (e.g., `aws-creds`)

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

## 4.
