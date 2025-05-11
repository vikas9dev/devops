# Amazon Elastic File System (EFS)

If you're building applications on AWS that require **shared storage**, Amazon Elastic File System (EFS) might be exactly what you need. It's a simple, cloud-native, and scalable file storage service that can be mounted across multiple EC2 instances—making it perfect for distributed systems, content-heavy apps, or web server clusters.

In this post, we'll walk through the essentials of setting up EFS, mounting it to an EC2 instance, and understanding why it’s such a powerful service.

## Why Use EFS?

EFS stands out because it allows **multiple EC2 instances to access the same file system simultaneously**. Unlike EBS (Elastic Block Store), which can only be attached to a single instance at a time, EFS offers true shared storage. You can mount an EFS volume just like a regular directory in your OS, but it's highly scalable, elastic, and built for the cloud.

Some common use cases include:

- **Dynamic web applications** with user-uploaded content (e.g., images or files).
- **Serverless architectures** or containerized apps using ECS/EKS.
- **Big data, analytics, or machine learning** pipelines that need centralized data access.
- **Backup and disaster recovery**, especially for database snapshots.

### Launching the EC2 Instance

1. Navigate to the **EC2 Dashboard** in AWS.
2. Click **Launch Instance** and name it `wave-web`.
3. Choose an OS (Amazon Linux, Ubuntu, or CentOS). For this demo, we’ll use **Amazon Linux** (RPM-based).
4. Select **t2.micro** as the instance type.
5. Either use existing key pair or Create a new key pair (e.g., `web-dev-key`) and download it.
6. Configure the security group (`launch-wizard-1`):
   - Allow **SSH (Port 22)** from your IP.
   - Allow **HTTP (Port 80)** from your IP (for initial testing).
7. In **Advanced Details**, paste the below user data script to automate website setup.
8. Launch the instance.

```bash
#!/bin/bash

# Variable Declaration
URL='https://www.tooplate.com/zip-templates/2137_barista_cafe.zip'
ART_NAME='2137_barista_cafe'
TEMPDIR="/tmp/webfiles"

yum --help &> /dev/null

if [ $? -eq 0 ]
then
   # Set Variables for CentOS
   PACKAGE="httpd wget unzip"
   SVC="httpd"

   echo "Running Setup on CentOS"
   # Installing Dependencies
   echo "########################################"
   echo "Installing packages."
   echo "########################################"
   sudo yum install $PACKAGE -y > /dev/null
   echo

   # Start & Enable Service
   echo "########################################"
   echo "Start & Enable HTTPD Service"
   echo "########################################"
   sudo systemctl start $SVC
   sudo systemctl enable $SVC
   echo

   # Creating Temp Directory
   echo "########################################"
   echo "Starting Artifact Deployment"
   echo "########################################"
   mkdir -p $TEMPDIR
   cd $TEMPDIR
   echo

   wget $URL > /dev/null
   unzip $ART_NAME.zip > /dev/null
   sudo cp -r $ART_NAME/* /var/www/html/
   echo

   # Bounce Service
   echo "########################################"
   echo "Restarting HTTPD service"
   echo "########################################"
   systemctl restart $SVC
   echo

   # Clean Up
   echo "########################################"
   echo "Removing Temporary Files"
   echo "########################################"
   rm -rf $TEMPDIR
   echo

   sudo systemctl status $SVC
   ls /var/www/html/

else
    # Set Variables for Ubuntu
   PACKAGE="apache2 wget unzip"
   SVC="apache2"

   echo "Running Setup on CentOS"
   # Installing Dependencies
   echo "########################################"
   echo "Installing packages."
   echo "########################################"
   sudo apt update
   sudo apt install $PACKAGE -y > /dev/null
   echo

   # Start & Enable Service
   echo "########################################"
   echo "Start & Enable HTTPD Service"
   echo "########################################"
   sudo systemctl start $SVC
   sudo systemctl enable $SVC
   echo

   # Creating Temp Directory
   echo "########################################"
   echo "Starting Artifact Deployment"
   echo "########################################"
   mkdir -p $TEMPDIR
   cd $TEMPDIR
   echo

   wget $URL > /dev/null
   unzip $ART_NAME.zip > /dev/null
   sudo cp -r $ART_NAME/* /var/www/html/
   echo

   # Bounce Service
   echo "########################################"
   echo "Restarting HTTPD service"
   echo "########################################"
   systemctl restart $SVC
   echo

   # Clean Up
   echo "########################################"
   echo "Removing Temporary Files"
   echo "########################################"
   rm -rf $TEMPDIR
   echo

   sudo systemctl status $SVC
   ls /var/www/html/
fi
```

Once the instance is up and running, you can access it using your browser. SSH into it and you can see some images in the `/var/www/html/images` directory. We will move all these images to the EFS file system in the next step. So, if there are multiple instances, the images will be shared among them and modification will be reflected in all instances.

## Setting Up EFS on AWS

We'll now walk through how to configure EFS and mount it to a web server.

### Step 1: Create a Security Group

First, create a security group that allows NFS traffic on port 2049. Set the inbound rule to allow access from the security group associated with your EC2 instances. This ensures secure communication between your web servers and EFS.

- Security Group Name: `efs-wave-img`
- Description: `Allows NFS traffic on port 2049`
- Inbound Rule:
  - Type: **NFS**
  - Protocol: **TCP**
  - Port Range: **2049**
  - Source: **Your EC2 Security Group (`launch-wizard-1`)**
  - Description: **Allows waver web servers to mount EFS file system**

### Step 2: Create the EFS File System

Head over to the EFS console and click "Create File System." Give it a name (e.g., `wave-web-image`) and click "Customize."

1. Go to **Amazon EFS > Create file system**.
2. **Name**: `wave-web-image`

a. Configure General Settings

- **Availability Zones**: Choose **only `us-east-1d`** to avoid unnecessary charges.
- Subnet: Select the one your EC2 instance is in (`us-east-1d`)
- Disable "Automatic Backup".
- In Lifecycle Management: Select **`None`**. "None – do not transition files to EFS Infrequent Access (IA)".
- Enable Encryption.
- Throughput mode: **Bursting**

> 💡 Deselect other AZs to avoid multiple mount targets and extra costs.

b. Network Settings

- VPC: Select the same one your EC2 instance is in.
- Security Group: Select the **`efs-wave-img`** created earlier

C. Policy Options: Default.

✅ **Free Tier Tips**

- Use only **one AZ (`us-east-1d`)**
- Don’t enable **provisioned throughput**
- Limit storage to **<5GB**
- Avoid **EFS One Zone – IA (Infrequent Access)** if not needed

d. Review and Create

- Click **Create**

### Step 3: Create an Access Point

We can access it through the IAM user also but we can also create an access point (in the Elastic File System console). Access points help simplify permissions and path management. Create a new access point for your file system. You'll use this to mount EFS more securely and easily.

Select the file system you just created, and click **Create Access Point**.

### Step 4: Install Amazon EFS Utilities

To mount the file system, we'll use the **Amazon EFS Utilities** package. We'll need to install this package on the EC2 instance.

See more: [Mounting EFS file systems](https://docs.aws.amazon.com/efs/latest/ug/mounting-fs.html)

On your EC2 instance (preferably running Amazon Linux), install the EFS utilities package:

```bash
sudo yum install -y amazon-efs-utils
```

If you’re using another Linux distribution (Ubuntu, CentOS, etc.), you’ll need to build the package from source. This acts as a "driver" for mounting the EFS file system.

### Step 5: Backup and Prepare the Mount Point

Assume you want to store uploaded images under `/var/www/html/images`. First, back up the existing images:

```bash
mkdir /tmp/img-backup
mv /var/www/html/images/* /tmp/img-backup/
```

Now you're ready to mount EFS to this directory.

### Step 6: Configure fstab for Auto-Mount

Edit `/etc/fstab` and add an entry like this:

```fstab
fs-<file-system-id> <efs-mount-point> efs _netdev,tls,accesspoint=fsap-<access-point-id> 0 0
```

Replace `<file-system-id>` and `<access-point-id>` with your actual values, and `<efs-mount-point>` with the directory where you want to mount EFS. In this case, it's `/var/www/html/images`.

```fstab
fs-00583303991cdbf49 /var/www/html/images efs _netdev,tls,accesspoint=fsap-0592d22ee698bdd22 0 0
```

Mount the file system:

```bash
# mount -fav
/                        : ignored
/boot/efi                : already mounted
/var/www/html/images     : successfully mounted
```

If successful, the EFS mount will be live at `/var/www/html/images`. Restore your images:

```bash
mv /tmp/img-backup/* /var/www/html/images/
```

Use `df -h` to verify that EFS is now mounted.

## Final Steps: Create an AMI

Once your EC2 instance is fully configured with EFS, you can create an Amazon Machine Image (AMI). This will allow you to use the setup in an Auto Scaling Group (in the next session), ensuring new instances can mount the same EFS volume automatically.

Delete older AMIs or snapshots if necessary to stay organized (deregister the AMIs, and delete the snapshots). Go to EC2 → Instances → Select your instance → Actions → Image → Create Image. Give it a meaningful name (e.g., `wave-web-img-efs`). Once AMIs is ready, you can terminate the original EC2 instance.

## Cost Considerations

The best part? **EFS comes with 5 GB of free storage for the first 12 months** under the AWS Free Tier. Even beyond that, pricing is reasonable for the flexibility and scalability it offers.

Amazon EFS is one of those services that looks simple on the surface but adds tremendous value to your architecture. Whether you're running multiple web servers or building a fault-tolerant microservices platform, having shared, centralized storage can save you time, reduce complexity, and boost reliability.

In the next session, we’ll use this setup in an Auto Scaling Group to automatically spin up EC2 instances that mount the same EFS volume. Stay tuned!

See more: [AWS Elastic File System](https://aws.amazon.com/efs/)
