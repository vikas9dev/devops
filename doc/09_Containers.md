# Containers

## 1. Introduction to Containers: Isolating Applications the Smarter Way

Let us dive into the basics of containers and understand why they have become such an essential part of modern application deployment.

Right now, what you see on your screen is a Linux computer. I want to highlight two important aspects:

- The **operating system** and
- The **file system hierarchy**.

At the top level, you have the root directory (`/`), and beneath it, various subdirectories like `/root`, `/boot`, `/bin`, `/var`, and `/etc`. If you're not familiar with this structure, I recommend revisiting the Linux sessions where we discussed it in detail.

These directories contain important files: configuration files, binaries, libraries, and more. But who uses these files? They are consumed by the processes running on the computer — services like **Apache Tomcat**, **Nginx**, and **MongoDB**. Each of these services is a process within the system's **process tree**, with `init` (or `systemd`) typically as the very first process (PID 1), which forks other processes below it.

This structure has existed for a long time, and it works well. However, when multiple main processes—such as Tomcat, Nginx, and MongoDB—run on the same computer, they all share:

- The **same operating system**,
- The **same file system**, and
- The **same set of libraries and binaries**.

This shared environment can lead to several problems. For example:

- Updating a library could unintentionally break other services.
- Changes to configuration files might affect all processes.

To solve this, traditionally, we isolated services by placing them on **different computers** — physical machines or virtual machines. Each server would then have its own OS, file system, and processes. This approach achieved isolation but also introduced a major drawback: **increased cost**. More servers mean more hardware, more maintenance, and more expenses.

This is where **containers** come in.

Instead of spinning up multiple full-fledged computers, containers allow us to isolate services at the **process level** within the same OS. Think of a container as just a **directory** that mimics a miniature file system:

- Each container has its own binaries, libraries, and configuration files.
- Each container runs its own process tree, starting with its own PID 1.

For example:

- An **Apache Tomcat container** has everything it needs to run Tomcat, and its PID 1 is the Tomcat process.
- An **Nginx container** has its own set of necessary files, isolated from others.
- A **MongoDB container** behaves similarly.

Since containers are lightweight and self-contained, they can be **archived** into **images**. These container images can then be shared and deployed across any environment, ensuring consistent behavior across development, testing, and production.

**Key benefits of containers**:

- **Isolation** without the overhead of full virtual machines.
- **Lightweight and efficient**.
- **Portability** across different environments.

But how does this all work under the hood?

At the foundation, you have:

- The **hardware** (physical or virtual),
- An **operating system** (like Linux), and
- A **container engine** (or runtime environment) like **Docker**.

The container engine is responsible for creating and managing containers. It leverages OS-level features like namespaces and cgroups to provide isolation without needing separate OS instances.

---

## 2. Docker Overview: A Quick Dive into Containerization

Let us explore [Docker](https://docs.docker.com/get-started/docker-overview/), one of the most powerful platforms for building, shipping, and running applications. This session builds on what we discussed earlier and is inspired directly by Docker’s official documentation.

Docker provides an open platform that allows you to develop applications, package them into containers, and run them anywhere. When we refer to "applications" here, we mean containers that encapsulate everything needed to run a process. With Docker, you can develop your own containers, ship them easily across environments, and run them wherever Docker is installed.

![Docker Architecture](https://docs.docker.com/get-started/images/docker-architecture.webp)

One of Docker’s biggest advantages is **isolation**. It allows you to separate your applications from the underlying infrastructure, making your deployments faster, more secure, and more scalable. Containers run in a loosely isolated environment on a single host, meaning you don’t need multiple machines to achieve separation. Each container is lightweight, carrying only the essential files required for its specific process — like an Nginx container containing just the Nginx files.

In simple terms, a **Docker Host** is the machine (physical or virtual) where Docker runs. The **Docker Daemon** (or Docker Engine) is the service responsible for managing containers. In our setup, we’ll create a virtual machine, install Docker Engine on it, and start running containers.

Containers are launched from **images**, and these images are stored in a **registry**. One popular registry is [Docker Hub](https://hub.docker.com). If you visit Docker Hub and click on "Explore," you’ll find a massive library of ready-to-use images like Python, PostgreSQL, Ubuntu, Traefik, Redis, Node.js, MongoDB, OpenJDK, MySQL, Golang, and Nginx. You’ll also see official images created by Docker, along with many community-contributed options. Later, we’ll learn how to build our own images and push them to Docker Hub.

Looking at the architecture again, you’ll notice the **Docker Client**, which interacts with the Docker Daemon. The client can run on the same machine or a different one. In our case, we’ll keep both the client and daemon on the same virtual machine. Using simple commands like `docker build`, `docker pull`, and `docker run`, we can build images, download existing ones, and launch containers effortlessly.

---

## 3. Docker Hands-On: Getting Started with Your First Containers

Welcome to the Docker Hands-on session! This section is designed to give you a practical introduction to Docker by walking you through setting up a virtual machine, installing Docker, and running your first containers.

Start by opening your terminal (Git Bash, for example) and creating a directory where you’ll place your working files. You can create it anywhere—just like I’ve created one on `05_container`. Inside this directory, add the [`Vagrantfile`](/05_container/Vagrantfile). This Vagrantfile is based on Ubuntu 20.04 and includes provisioning commands to automatically install the Docker engine.

These installation steps are derived from the official Docker documentation, specifically from the “Get Docker for Linux” section. If you're curious, you can review those commands directly on Docker's site—but everything is already set up in the Vagrantfile for convenience.

Once the file is in place, run:

```bash
vagrant up
```

This command brings up the VM and provisions Docker. After setup completes, log into the VM:

```bash
vagrant ssh
sudo -i
```

Now verify Docker is running:

```bash
systemctl status docker
```

You should see the Docker engine active and running.

### Running Your First Docker Container

To verify Docker is working, run the classic test command:

```bash
docker run hello-world
```

Docker will pull the `hello-world` image from Docker Hub if it isn’t already available locally. It creates a container, executes a simple print job, and exits. You can confirm this with:

```bash
docker images       # Lists downloaded images
docker ps -a        # Shows all containers (including exited ones)
```

### Launching an Nginx Container

Let’s try something more interactive—running a web server using the Nginx image:

```bash
docker run -d --name web01 -p 9080:80 nginx
```

This command creates a container named `web01`, maps port 80 inside the container to port 9080 on the host (the VM), and runs it in detached mode. To confirm it’s running:

```bash
docker ps
```

Now, to access it from your docker, find the IP address of the docker (`docker inspect web01`) and execute `curl http://<VM_IP>:80`. You should see the Nginx welcome page.

And, to access it from your browser, find the IP address of the VM (`ip addr show`) and visit `http://<VM_IP>:9080`. You should see the Nginx welcome page.

### Building Your Own Docker Image

To take it a step further, let’s build a custom image:

1. Create a directory named `images` and `cd` into it `mkdir images && cd images`.
2. Create a file named `Dockerfile`.
3. Paste your Docker instructions inside the file:-

```yaml
# Stage 1: Build and package the template
FROM ubuntu:latest AS BUILD_IMAGE

RUN apt-get update && apt-get install -y wget unzip tar

RUN wget https://www.tooplate.com/zip-templates/2128_tween_agency.zip
RUN unzip 2128_tween_agency.zip && \
    cd 2128_tween_agency && \
    tar -czf /root/tween.tgz .  # Use absolute path here

# Stage 2: Final image with Apache
FROM ubuntu:latest
LABEL "project"="Marketing"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y apache2 git wget tar && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=BUILD_IMAGE /root/tween.tgz /var/www/html/

RUN cd /var/www/html/ && tar -xzf tween.tgz && rm tween.tgz

WORKDIR /var/www/html
VOLUME /var/log/apache2
EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
```

4. Build the image using:

```bash
docker build -t testimg .
```

Once the image is built, check the images with `docker images` and run it:

```bash
docker run -d -P testimg
```

Docker will assign a random host port. Use `docker ps` to find which one, then open your browser and navigate to `http://<VM_IP>:<Assigned_Port>` to see your custom app. Use `ip addr show` to find the VM IP address.

### Cleanup

To prepare for the next session, clean up your environment:

```bash
docker stop web01 <other_container_names>
docker rm web01 <other_container_names>
docker rmi <image_ids>
```

---

## 4. Running the Vprofile Application on Containers: A Preview of Docker in Action

Welcome to this lecture, where we take a first look at running the **Vprofile application on containers**. Think of this as a sneak peek into what's coming next in the Docker section—everything is preconfigured for you, and the goal is to simply get it up and running.

In the earlier Vprofile VM setup, we used separate virtual machines for components like **Nginx**, **Tomcat**, **RabbitMQ**, **Memcached**, and **MySQL**. Now, we’ll see how these same components can run together using **Docker containers** on a single virtual machine. This shift illustrates the power and efficiency of containerization.

To begin, create a folder `cd 05_container/ && mkdir vprofile && cd vprofile`, place the Vagrant file inside, destroy any existing VM using ` vagrant global-status --prune` and bring up the VM with `vagrant up`. This VM is pre-configured to install Docker and its CLI, so ensure no other VMs are running to avoid resource conflicts.

Once the VM is up, SSH into it (`vagrant ssh`), switch to the root user (`sudo -i`), and prepare to use **Docker Compose**, a tool designed to manage multiple containers using a [`docker-compose.yml`](https://github.com/vikas9dev/vprofile-project/blob/docker/docker-compose.yml) file. Create the file `vim docker-compose.yml`.

```bash
mkdir compose && cd compose
wget https://github.com/vikas9dev/vprofile-project/blob/docker/docker-compose.yml
```

It is fails to get the file, you can create the file manually and put the content in it.

With the compose file in place, run the application stack using:

```bash
docker compose up -d
```

This will pull the required images (e.g., Nginx, Tomcat, Memcached, RabbitMQ, MySQL) from Docker Hub (under the `vprocontainers` account), spin up all containers, and connect them as per the compose file. You can verify everything with:

```bash
docker compose ps
docker images
```

To access the application, get the VM's IP address using `ip addr show`, and open the app in your browser. You’ll see the Nginx front-end routing requests to the Tomcat server. After logging in using the credentials:- username: `admin_vp` and password: `admin_vp`, you’ll validate that the database, RabbitMQ, and Memcached containers are all working as expected.

Finally, you can tear everything down using:

```bash
docker compose down
docker system prune -a
```

The `docker system prune -a` will remove:

- all stopped containers
- all networks not used by at least one container
- all images without at least one container associated to them
- all build cache

This stops and removes all containers and unused images, keeping your system clean. Restarting later is as easy as running `docker compose up` again from the same folder.

---

## 5. Monolithic vs Microservices: Understanding the Shift in Modern Application Architecture

In this session, we explore a foundational concept in modern software architecture—**the difference between monolithic and microservices applications**—from both a developer and user perspective, without getting into server or infrastructure specifics.

Let’s begin with **monolithic architecture**. Imagine a Java-based application like _Vprofile_, where the entire functionality—user interface, posts, chat, notifications, and more—resides within a single application deployed on a single server (e.g., via a Tomcat server). All these sub-services are packaged into one artifact (like `vprofile-v2.war`). This tightly coupled structure means that even a small change in one module requires rebuilding and redeploying the entire application. It’s slow to evolve and scale—like moving an elephant.

Now, contrast that with **microservices architecture**. Instead of one large application, each feature—UI, chat, notifications, and so on—is built as an independent service. These services can be developed using different languages (e.g., Java for UI, Node.js for chat, Python for notifications), and can run independently while communicating via well-defined APIs, typically routed through an API gateway. This approach enables teams to work in parallel, use the best-suited technology for each component, and deploy features independently without affecting the rest of the system.

However, with this flexibility comes complexity. Microservices need isolation. Running them on separate servers can get costly and resource-intensive. This is where **containerization**—especially with Docker—solves a key challenge. Instead of setting up multiple servers, we can package each microservice into a container and run them all on a single host using a container runtime. This is why **containers and microservices are often mentioned together**—containers provide the isolation, scalability, and portability that microservices need.

Think of companies like **Amazon**. Their e-commerce platform consists of numerous microservices: login, user dashboard, cart, payment, order tracking, and more. Each of these can be a separate containerized service running independently yet communicating seamlessly through APIs.

From a **DevOps perspective**, microservices represent an **architectural and organizational shift**. It's not just about infrastructure—it's about designing software as a collection of small, independent services that are easier to build, deploy, scale, and maintain. They communicate over APIs, allowing for tech diversity, rapid iteration, and flexible deployments.

If you're diving into DevOps, focus on understanding how microservices are deployed, monitored, scaled, and managed. And if you're a developer, dig deeper into designing and developing these services. Either way, microservices form the backbone of modern, scalable, and efficient application development.

Feel free to explore more resources, videos, and blogs on microservices to solidify your understanding. This foundational knowledge will be crucial as we move ahead into topics like **Docker**, **Kubernetes**, and **AWS**.

---

## Deploying the EMart Microservice Application with Docker

Welcome to this lecture on deploying a microservice-based application. We will be working with **EMart**, an e-commerce platform designed using microservices architecture.

### Application Overview

The EMart application consists of multiple microservices running in separate containers. The **frontend** is an API Gateway built with **NGINX**, which listens at three endpoints:

- **Root (`/`)** – Serves the Angular-based client application.
- **API (`/api`)** – Connects to the **Mart API**, a Node.js application that interacts with a **MongoDB** database.
- **Web API (`/web-api`)** – Connects to the **Books API**, a Java-based service using a **MySQL** database.

![EMart Architecture](images/EMart_Architecture.png)

All components—including **NGINX, Angular, Node.js, Java, MongoDB, and MySQL**—run as **Docker containers**, making the application highly scalable. Additional microservices, such as payment processing or cart management, can be integrated easily.

### Setting Up the Deployment Environment

We will deploy EMart using **Docker and Docker Compose** within a virtual machine (VM). The setup process follows similar steps to a previous monolithic project (**VProfile**), but here, we are working with microservices.

1. **Prepare the Virtual Machine**

   - Ensure no other VMs are running:
     ```sh
     vagrant global-status --prune
     ```
   - Start the VM:
     ```sh
     vagrant up
     ```
   - Log in to the VM:
     ```sh
     vagrant ssh
     sudo -i
     ```

2. **Clone the EMart Repository**

   - Download the source code:
     ```sh
     git clone https://github.com/vikas9dev/emartapp.git
     cd emartapp/
     ls
     ```
   - Open the **Docker Compose** configuration file (`docker-compose.yml`). This file defines multiple services and includes a **build** step to create images directly from Dockerfiles.

3. **Build and Run the Containers**

   - Check for existing images or containers:
     ```sh
     docker ps -a
     ```
   - If no containers are running, start the deployment:
     ```sh
     docker compose up -d
     ```
   - If the build fails, run:
     ```sh
     docker compose build
     docker compose up -d
     ```

4. **Verify Deployment**
   - Check running containers:
     ```sh
     docker compose ps
     ```
   - Ensure all services are active. If any container exits unexpectedly, Docker Compose will restart it automatically.

### Accessing the Application

Once the deployment is complete, access EMart via a web browser:

1. Find the VM’s IP address:
   ```sh
   ip addr show
   ```
2. Open a browser and enter:
   ```
   http://<VM-IP>
   ```
3. Register a new user and log in to explore the platform.

### Cleaning Up

After testing the application, clean up the environment:

```sh
docker compose down
docker system prune -a
exit
vagrant halt
```

### Conclusion

In this lecture, we deployed the EMart microservice application using **Docker and Docker Compose**. The architecture ensures scalability, allowing new microservices to be added seamlessly. In the next session, we will explore Docker concepts in more detail.

---
