# AWS Re-Architect Web App on AWS Cloud (PAAS & SAAS)

## 1. Refactoring with AWS Project

In our previous project, we deployed the vProfile application stack both on a local machine and on AWS Cloud using the lift-and-shift strategy. Now, we’re taking it a step further by refactoring and rearchitecting our services to enhance agility, scalability, and performance.

### Why Refactor?

Imagine managing an application with services running on physical machines, virtual machines, or even cloud-based EC2 instances. You’re juggling databases, web servers, network services (DNS, DHCP), and more. This setup demands multiple teams—cloud computing, virtualization, datacenter operations, monitoring, and sysadmins—just to keep things running. The operational overhead is immense, with challenges like uptime struggles, scaling difficulties, high capital and operational expenditures, and manual, time-consuming processes.

By leveraging AWS’s **Platform-as-a-Service (PaaS)** and **Software-as-a-Service (SaaS)** offerings instead of traditional Infrastructure-as-a-Service (IaaS), we can drastically reduce operational complexity. Cloud-managed services provide automation, flexibility, and elasticity, with scaling handled by AWS—all on a pay-as-you-go model.

### AWS Services We’ll Use

Instead of manually managing EC2 instances, we’ll use:

- **Elastic Beanstalk** for deploying our Tomcat application (handling EC2, load balancing, auto-scaling, and artifact storage in S3).
- **RDS** for managed MySQL databases (automated backups, scaling, and high availability).
- **ElastiCache** in place of Memcached.
- **Amazon MQ** (ActiveMQ) instead of RabbitMQ.
- **Route 53** for DNS management.
- **CloudFront** as a global Content Delivery Network (CDN).

### Architecture Overview

1. **User Flow**:

   - A user accesses our URL, resolved via **Route 53** to a **CloudFront** endpoint (for fast global delivery).
   - Requests route to an **Application Load Balancer (ALB)** in Elastic Beanstalk, which forwards traffic to EC2 instances in an auto-scaling group.
   - **CloudWatch** monitors performance, triggering scaling as needed.

2. **Backend Services**:
   - **Amazon MQ** (messaging), **ElastiCache** (caching), and **RDS** (database) replace self-managed VMs.
   - Security groups control access between Beanstalk instances and backend services.

![AWS Cloud - Refactor](images/AWS_Refactor.png)

### Execution Steps

1. **Setup**:

   - Log in to AWS and create a key pair for Beanstalk instances.
   - Configure security groups for backend services (RDS, ElastiCache, Amazon MQ).

2. **Backend Deployment**:

   - Launch RDS, ElastiCache, and Amazon MQ.
   - Initialize the RDS database via an EC2 instance.

3. **Beanstalk Configuration**:

   - Deploy the Beanstalk environment (auto-creating EC2, ALB, and scaling policies).
   - Update health checks to `/login` and enable HTTPS (443) on the ALB.
   - Update security groups of backend to allow traffic from Bean security group.
   - Update security groups of backend to allow internal traffic.

4. **Application Deployment**:

   - Build the artifact with updated endpoints (RDS, Amazon MQ, ElastiCache).
   - Deploy to Beanstalk and verify.

5. **Final Touches**:
   - Set up **CloudFront** with an SSL certificate for HTTPS.
   - Update DNS records in Route 53 or GoDaddy.
   - Test the full stack via the live URL.

By refactoring, we achieve a **scalable, low-overhead infrastructure** with automated scaling, managed services, and global performance. Ready to dive in? Let’s get started on the AWS console!

---

## 2. Configuring Security Groups and Key Pairs for the Refactored Stack

In our refactored AWS architecture, **Elastic Beanstalk** will automatically provision EC2 instances to host the vProfile application, along with two security groups:

1. **Application Security Group** – For the EC2 instances running the app.
2. **Load Balancer Security Group** – For the ALB (Elastic Beanstalk auto-configures rules to allow traffic from the ALB to the instances).

### Backend Security Group Setup

For **Amazon MQ (ActiveMQ), RDS, and ElastiCache**, we’ll create a dedicated **Backend Security Group** with two critical rules:

1. **Internal Communication**: Allow all traffic _within the same security group_ so backend services (RDS, cache, messaging) can interact seamlessly. Create the security group with name `vprofile-rearch-backend-sg` without any rules. Once the security group is created, then edit the inbound rules to allow "All Traffic" from _its own Security Group ID_.
2. **Beanstalk Access**: Later, we’ll add a rule to permit traffic from the Beanstalk instance security group (ensuring the app can connect to the backend).

### Key Pair for Troubleshooting

While Beanstalk manages EC2 instances, we’ll create a **PEM key pair** (`vprofile-rearch-key.pem`) for emergency SSH access—useful for debugging.

With this setup, our backend services can securely communicate, and Beanstalk will later integrate via security group updates. Next up: **launching the RDS instance!**

---

## 3. Setting Up a Managed MySQL Database with Amazon RDS

In our application modernization journey, we're replacing self-managed MySQL on EC2 with **Amazon RDS**, AWS's fully managed relational database service. This shift eliminates database maintenance burdens while providing enterprise-grade availability, scalability, and security. Here's our comprehensive implementation approach:

### Architectural Foundations

**a. Parameter Groups for Fine-Tuned Control**
We will create a custom DB parameter group (`vProfile-RDS-Rearch-ParaGroup`) specifically configured for MySQL 8.0. This gives us granular control over 300+ database parameters without needing server access. While we're using defaults initially, this setup allows future performance tuning as our application scales.

Go to the AWS RDS section => Parameter Groups => Create Parameter Group => Name: vProfile-RDS-Rearch-ParaGroup => Engine: MySQL Community => Parameter group family: MySQL 8.0 => Type: DB Parameter Group => Create

**b. Network Isolation Strategy**
Our dedicated DB subnet group spans multiple Availability Zones, establishing the foundation for high availability. Though we're currently using a single instance (for cost optimization), this design allows seamless transition to Multi-AZ deployment when needed. The database is completely isolated from public internet access, with connectivity restricted to:

- Our Beanstalk application tier
- Designated backend services
- Authorized administrative EC2 instances

Go to the AWS RDS section => Subnet Groups => Create Subnet Group => Name: vProfile-RDS-Rearch-SubnetGroup => VPC: Choose Default => Availability Zones: Add all AZs (default) => Subnets: Add all subnets => Create

### RDS Configuration Details

**🚀 Database Configuration Details**

Here's your enhanced content with perfectly matched emojis for maximum clarity and technical accuracy:

**🔧 Database Configuration Details**

- **🛠️ Creation Method**: Standard Create
- **⚙️ Engine**: MySQL 8.0.41 (maintained and patched by AWS 🛡️)
- **🏷️ Template**: Free Tier 🆓
- **🌐 Availability & Durability**: Single AZ DB instance 📍
- **🏷️ DB instance identifier**: `vprofile-rds-rearch`
- **👨💻 Master username**: `admin`
- **🔑 Credentials Management**: Self Managed
- **🎲 Auto Generate Password**: Yes ✅
- **💻 Compute**: db.t4g.micro (Free Tier eligible 🆓, 2 vCPUs 🖥️, 1GB RAM)
- **💾 Storage**: 20GB GP2 SSD (baseline 3,000 IOPS ⚡, scalable to 16,000 📈)
- **⚙️ Additional Storage Configuration**: ⚙️❌ Disable storage autoscaling
- **🔌 Connectivity**: 🚫 Don't connect to an EC2 compute instance (we'll do it manually later ✋)
- **🌐 VPC**: Use the default VPC 🏠
- **🛰️ DB Subnet group**: `vProfile-RDS-Rearch-SubnetGroup` (pre-created) 🔄
- **🌍 Publicly accessible**: No 🚫
- **🛡️ VPC Security Groups**:
  - ➖ Remove default
  - ➕ Add `vprofile-rearch-backend-sg` security group 🔒
- **📍 Availability Zone**: No Preference (default) ⚙️
- **🔐 Database Authentication**: Password Authentication 🔑

**⚙️ Additional Configuration**:

- **🗃️ Initial DB Name**: `accounts`
- **⚙️ DB Parameter group**: `vProfile-RDS-Rearch-ParaGroup` (pre-created) 🔧
- **💾 Backup**: Not required for now ⏸️
- **🔏 Encryption**: Keep default 🔄

**✅ Final Steps**:

- **🖱️ Create** button to launch instance 🚀
- **📋 View Credential Details** from the banner - Store securely! 🔒 (Password cannot be retrieved later) ⚠️

**Key Security Notes**:

- 🚫 Database is not publicly accessible
- 🔒 Uses dedicated security group
- 🔏 Encrypted by default
- 🔑 Credentials available only during creation

**Key Highlights**:

- 🆓 Free Tier eligible configuration for cost savings
- 🔄 Single AZ setup for development environments
- ⚡ Scalable storage performance when needed
- 📈 High availability for production deployments
- 🛡️ AWS-managed security and patching

---

## 4. 🚀 Setting Up ElastiCache Memcached for High-Performance Caching

In our cloud modernization journey, we're now configuring **Amazon ElastiCache** 🏗️ to replace our self-managed Memcached instances. This fully managed service delivers blazing-fast 🚀 in-memory caching while eliminating operational overhead. Here's our step-by-step implementation: Search for the ElastiCache. Let us first create Parameter group and Subnet Group.

### 🔧 Pre-Configuration Setup

**1. Parameter Group Creation**

- Name: `vprofile-cache-parameter-group` ⚙️
- Family: **Memcached 1.6** engine (tested and verified for vProfile compatibility ✅)
- Create 🎉.
- Open the created parameter group and you can see the default 150+ parameters.

**2. Subnet Group Configuration**

- Name: `vprofile-rearch-cache-subgrp` 🌐
- VPC: Use the default VPC 🏠
- Subnets: By default all the subnets are selected 🔄
- Create 🛡️

### ⚡ Cache Cluster Deployment

Go to the ElastiCache Dashboard and create a cache cluster: Create cache => Select Create Memcached.

**Core Specifications**:

- **Deployment Option**: "Design your own cache" 📊 & "Standard Create"
- **Location**: AWS Cloud
- **Name**: `vprofile-rearch-cache`
- **Engine**: Memcached 1.6.22 (latest stable version 🔝)
- **Port**: 11211 (matches application properties 🔌)
- **Parameter Group**: `vprofile-cache-parameter-group` (pre-created)
- **Node Type**: cache.t2.micro (Free Tier eligible 🆓 - 0.5GB RAM) - Choose the smallest one.
- **Number of nodes**: 1 (default)
- **Subnet Group**: `vprofile-rearch-cache-subgrp` (pre-created)
- **Availability Zone**: No Preference (default)
- **Security Groups**: Manage => ➕ Add `vprofile-rearch-backend-sg` security group 🔒
- **Maintenance Window**: No preference (temporary environment)
- **Create**: Launch the cache cluster 🚀

**Advanced Options**:

- Disabled SNS notifications (enable for production monitoring 📢)
- Verified all settings before creation 👁️

### 🚦 Creation Process

The cluster takes ~5-10 minutes to initialize ⏳. During this time:

- AWS provisions the specified compute resources 💻
- Configures networking according to our specifications 🌐
- Applies our custom parameter group settings ⚙️

"**AWS bills for ElastiCache like a hotel room - you pay for every hour it's reserved, whether you sleep there or not.**" 🏨💳. No "pausing" or "stopping" mechanism exists. Node type (cache.t2.micro = ~$0.018/hr ≈ $13/month).Additional charges for: - Data transfer (if applicable), - Backup storage (if enabled).

🛑 Cost Control Options:
**DELETE When Not Needed**

- Terminate via AWS Console → ElastiCache → Delete Cluster
- Recreate later (loses all cached data)

---

## 5.

---

## 6.

---

## 7.
