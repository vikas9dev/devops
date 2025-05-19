# Maven

## 🚀 Mastering Maven: The Ultimate Build Tool Guide 🛠️

**Instructor:** Hello, and welcome! 👋

In this session, we’ll dive into **Maven**, the powerful build tool for Java projects. Let’s explore what we’ll cover:

✅ **Understanding the Build Process** – What happens from code to deployment?  
✅ **Exploring Build Tools** – Why do we need them, and how do they automate workflows?  
✅ **Introducing Maven** – What makes it a go-to choice for Java developers?  
✅ **Maven Phases** – Validate, compile, test, package, and more!  
✅ **Installation Guide** – Setting up Maven on **Windows & Linux**, including different versions.  
✅ **Deep Dive into `pom.xml`** – The heart of Maven’s build configuration.  
✅ **Essential Maven Commands** – Hands-on with key commands to streamline your workflow.

### 🔍 What is a Build Process?

Developers write **source code** — whether for web apps, mobile apps, or other software. But before deployment, the code must go through several steps:

1. **Compilation** – Converting human-readable code (Java, C#, etc.) into machine-readable format (e.g., `.class` files for Java).
2. **Testing** – Running **unit & integration tests** (written by devs, not QA!) to ensure functionality.
3. **Packaging** – Bundling compiled code into distributable formats (`.jar`, `.war`, `.exe`, `.zip`, etc.).
4. **Health Checks** – Code analysis for bugs, security flaws, and optimizations.

Since manually running these steps is tedious, **build tools automate the process**.

### ⚙️ Popular Build Tools

Different languages use different tools:

- **Maven** (Java, XML-based)
- **Ant** (Java, script-heavy, largely replaced by Maven)
- **MSBuild** (Microsoft Build Engine, used for Microsoft ecosystem)
- **Gradle** (Groovy/Kotlin-based, flexible & powerful)
- **Make** (For system-level executables like RPMs)
- **& NANT** (Windows .NET platform)

For this course, we focus on **Maven** since it’s the standard for Java projects.

### 🔄 Maven Build Lifecycle & Phases

Maven operates in **phases**, where each step triggers previous ones automatically. Key phases:

1. **`validate`** – Checks project structure & dependencies. It validate the project is correct and all necessary information is available.
2. **`compile`** – Converts source code into binaries.
3. **`test`** – Runs unit tests (no packaging needed). Test the compiled source code using a suitable unit testing framework.
4. **`package`** – Bundles code into `.jar`, `.war`, etc.
5. **`verify`** – Ensures quality checks pass. Run any checks on results of integration tests to ensure quality criteria are met.
6. **`install`** – Downloads dependencies to local repo. Install the package into the local repository, for use as a dependency in other projects locally.
7. **`deploy`** – Pushes artifacts to remote repositories. Done in the build environment, copies the final package to the remote repository for sharing with other developers and projects.

Running nth phase automatically runs the previous stages also. Example: Running **`mvn package`** executes `validate` → `compile` → `test` → `package`.

### 📜 Maven Documentation Reference

For deeper insights, check the **[Maven Build Lifecycle Docs](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html)**.

🔹 **Key Takeaways for DevOps:**

- Maven **automates** repetitive build tasks.
- `pom.xml` defines **dependencies, plugins, and packaging**.
- Most phases are developer-centric, but DevOps must understand **how builds integrate into CI/CD pipelines**.

---

## 🔧 Hands-On with Maven: Building & Deploying a Java Project 🚀

Let’s get practical! Open your browser and navigate to **[vProfile Project on GitHub](https://github.com/vikas9dev/vprofile-project)**. This is our source code repository.

### 📂 Key File: **`pom.xml`** (Maven’s Build Blueprint)

- **Spot `pom.xml`?** It’s a Maven project!
- Developers start with a template `pom.xml` and customize it for dependencies, versions, and build steps.
- **DevOps Need-to-Know:** You should **read** (and occasionally **edit**) this file—no XML expertise required!

#### � XML Basics:

```xml
<groupId>com.vprofile</groupId>
<artifactId>vprofile</artifactId>
<version>v2</version>
<packaging>war</packaging>
```

- **`groupId`**, **`artifactId`**, and **`version`** define the project’s identity (e.g., output: `vprofile-v2.war`).
- **`properties`** section holds reusable variables (e.g., `mysql-connector.version=8.0.32`).

  ```xml
  <properties>
      <spring.version>6.0.11</spring.version>
      <spring-boot.version>3.1.3</spring-boot.version>
      <spring-security.version>6.1.2</spring-security.version>
      <spring-data-jpa.version>3.1.2</spring-data-jpa.version>
      <hibernate.version>7.0.0.Alpha3</hibernate.version>
      <hibernate-validator.version>6.2.0.Final</hibernate-validator.version>
      <mysql-connector.version>8.0.33</mysql-connector.version>
      <commons-dbcp.version>2.12.0</commons-dbcp.version>

      <junit.version>4.13.2</junit.version>
      <logback.version>1.5.6</logback.version>
      <maven.compiler.source>17</maven.compiler.source>
      <maven.compiler.target>17</maven.compiler.target>
  </properties>
  ```

#### 📦 Dependencies & Plugins

- **Dependencies** (e.g., Spring Framework) are fetched from **Maven Central Repository** during build.
  ```xml
  <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-core</artifactId>
      <version>${spring.version}</version>  <!-- Refers to properties -->
  </dependency>
  ```
- **Plugins** like **JaCoCo** for unit testing are configured here.

### 🛠️ **Step-by-Step Build Process** (Ubuntu EC2 Example)

1️⃣ **Launch an EC2 Instance** (Ubuntu 24.04, `t2.micro`), SSH to it.
2️⃣ **Install Prerequisites:**

```bash
sudo apt update
sudo apt search jdk
sudo apt install -y openjdk-17-jdk  # JDK 17 for Maven
sudo apt install -y maven           # Install Maven
```

3️⃣ **Verify Installations:**

```bash
java -version    # Check Java (OpenJDK 11)
mvn -version     # Check Maven (default: v3.6+)
```

4️⃣ **Clone & Build the Project:**

```bash
git clone https://github.com/vikas9dev/vprofile-project/
cd vprofile-project
mvn validate  # Validate `pom.xml`
mvn test     # Download the dependencies, build and run unit tests
mvn clean install -DskipTests  # Clears old builds, downloads dependencies, and packages
```

- **Output:** `target/vprofile-v2.war` (filename mirrors `pom.xml` settings).

The dependencies are stored in `~/.m2/repository` directory.

5️⃣ **Advanced: Custom Maven Version**

- Download a specific version (e.g., 3.9.3):
  ```bash
  wget https://archive.apache.org/dist/maven/maven-3/3.9.3/binaries/apache-maven-3.9.3-bin.tar.gz
  tar xzvf apache-maven-3.9.3-bin.tar.gz
  sudo mv apache-maven-3.9.3 /opt
  /opt/apache-maven-3.9.3/bin/mvn -version  # Verify
  ```

If we change the maven version then we should delete the existing `~/.m2/repository` directory. Then we should run `mvn clean install` again.

6️⃣ **Modify & Rebuild**

- Edit `pom.xml` (e.g., change `<version>v2</version>` to `v3`).
- Rebuild:
  ```bash
  mvn clean install  # New artifact: `vprofile-v3.war`
  ```

---

### ☁️ **Bonus: AWS CloudShell Build**

- **Amazon Linux 2** uses `yum`:
  ```bash
  sudo yum search java
  sudo yum install -y java-17-amazon-corretto.x86_64
  sudo yum install -y maven
  mvn -version
  git clone https://github.com/vikas9dev/vprofile-project/
  cd vprofile-project
  mvn install -DskipTests
  ```
- **Push to S3:**
  ```bash
  aws s3 mb s3://maven-artifacts825765386084 # Create bucket
  aws s3 cp target/vprofile-v2.war s3://maven-artifacts825765386084 # Upload artifact to S3 bucket
  ```
- **Clean Up**:
  ```bash
  aws s3 rm s3://maven-artifacts825765386084/vprofile-v2.war
  aws s3 rb s3://maven-artifacts825765386084 --force
  ```

### 🔥 **Key Takeaways**

- **Maven automates:** Dependency resolution, testing, packaging.
- **`pom.xml` is the control center:** Defines project structure, versions, and plugins.
- **DevOps role:** Understand builds to debug CI/CD pipelines (e.g., Jenkins).

**Next Up:** Deeper integration with Jenkins! 🚀 Terminate your EC2 instance if testing is done.

---
