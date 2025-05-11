# EBS (Elastic Block Storage)

## 1. Understanding and Using Amazon EBS with EC2

In this section, we’ll explore Amazon Elastic Block Store (EBS), a key storage service used with EC2 instances in AWS. Think of EBS as the virtual hard drive attached to your EC2 instance—it stores your operating system, applications, and any additional data like website files or databases.

### What is EBS?

Amazon EBS provides two main features:

1. **EBS Volumes** – These are block-level storage devices that function like traditional hard drives.
2. **Snapshots** – These are point-in-time backups of your EBS volumes.

EBS volumes are essential for running your EC2 instance's operating system (OS). For example, when you launch an EC2 instance and see an 8GB root volume, that’s an EBS volume storing your OS. You can also attach additional volumes for storing application-specific data like web files or databases.

### Key Characteristics of EBS

- **Block Storage**: Similar to physical disks, EBS uses block-level storage, allowing fine-grained control and consistent performance.
- **Availability Zone Specific**: When creating an EBS volume, you must select the same Availability Zone (AZ) as your EC2 instance for it to be attachable.
- **Replication**: EBS volumes are automatically replicated within the same AZ to protect against hardware failure, but not across multiple AZs.

### EBS Volume Types

AWS offers several types of EBS volumes, each designed for specific use cases:

- **General Purpose SSD (gp2/gp3)**: Ideal for most workloads, offering a balance between cost and performance.
- **Provisioned IOPS SSD (io1/io2)**: Designed for high-performance databases where speed and consistency are crucial.
- **Throughput Optimized HDD (st1)**: Best for big data, log processing, and data warehousing.
- **Cold HDD (sc1)**: Low-cost storage for infrequently accessed data such as backups.
- **Magnetic (standard)**: Previous-generation, lowest cost option, suitable for archival.

For most general workloads, **General Purpose SSD (gp3)** is recommended due to its good balance of price and performance. See more about EBS volume types [here](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html).

### Creating and Attaching a New EBS Volume

In the session, we walked through creating a CentOS EC2 instance with a root EBS volume and then adding an additional 5GB EBS volume to store web server images. The key steps included:

1. **Launch an EC2 instance** with CentOS Stream 9 using the AWS Marketplace.
2. **Create a new EBS volume** (5GB, gp2) in the same Availability Zone as the instance.
3. **Attach the new volume** to the EC2 instance.

Let us Launch an EC2 instance with `Amazon Linux` AMI  :

- Name: `web01`
- Image: `Amazon Linux`. It gives default user name: `ec2-user`
- Instance Type: `t2.micro` (free tier)
- Root Volume: `8 GB` of `gp2`
- Availability Zone: `us-east-1d`
- Assign existing key pair: `web-dev-key`
- Assign existing security group: `web-sg` (Make Sure the inbound rule allows SSH (port 22) from _My IP_ and HTTP (port 80) from _My IP_)
- Launch the instance.

After the instance is launched, login to it using the SSH command:

```bash
cd c/install/aws-keys/
chmod 400 web-dev-key.pem # Important: Change the file permission
ssh -i web-dev-key.pem ec2-user@13.218.121.43
```

Run the below commands:-

```bash
#!/bin/bash
yum install httpd wget unzip -y
systemctl start httpd
systemctl enable httpd
cd /tmp
wget https://www.tooplate.com/zip-templates/2119_gymso_fitness.zip
unzip -o 2119_gymso_fitness.zip
cp -r 2119_gymso_fitness/* /var/www/html/
systemctl restart httpd
```

Open the browser and visit: `http://<Public_IP>`

In the storage section, you can see the root volume. After clicking on the Volume ID, it will take you to the EBS console. Rename the Volume to `web01-ROOT-Volume` for better readability. The `web01-ROOT-Volume` will be in the same Availability Zone as the instance.

---

## 2. Creating and Attaching a New EBS Volume in AWS

When working with Amazon EC2 instances, there may be a need to expand your storage by attaching additional volumes. Amazon Elastic Block Store (EBS) provides block-level storage that can be attached to EC2 instances. In this section, we’ll walk through the step-by-step process of creating a new EBS volume, attaching it to an instance, and preparing it for use — including partitioning, formatting, and mounting it.

### 1. **Understanding the Requirement**

Suppose we have a web server running on an EC2 instance, and we want to store image files in a dedicated volume separate from the root volume. The requirement is to add a 5 GB EBS volume for these images, ensuring we stay within AWS's 30 GB free tier limit.

### 2. **Creating an EBS Volume**

1. **Navigate to the EC2 Dashboard:**

   - Go to the **Volumes** section under **Elastic Block Store** in the EC2 console.

2. **Click on “Create Volume”:**

   - **Volume type**: Select **General Purpose SSD (gp2)** — ideal for most workloads and covered under the free tier.
   - **Size**: Enter `5 GiB`.
   - **Availability Zone**: Make sure this matches the zone of your EC2 instance (e.g., `us-east-1d`). Volumes can only be attached to instances in the same zone.
   - (Optional) **Tag the volume** for easy identification, e.g., `Name: web01-images`.

3. **Click “Create Volume”**.

### 3. **Attaching the Volume to the EC2 Instance**

1. **After the volume is created**, select it from the Volumes list.
2. Click on **Actions > Attach Volume**.
3. **Select the instance** (e.g., `web01`) from the dropdown that appears.
4. Device: Select **/dev/sdf**.
5. Click **Attach**.

### 4. **Preparing the Volume in the EC2 Instance**

After the volume is attached, log in to your EC2 instance via SSH.

```bash
ssh -i path/to/key.pem ec2-user@<INSTANCE_PUBLIC_IP>
```

Switch to the root user:

```bash
sudo -i
```

### 5. **Identify the New Volume**

Use the `lsblk` or `fdisk` command to list block devices:

```bash
lsblk
fdisk -l
```

You should see a new device (e.g., `/dev/xvdf`) with no partitions.

```bash
# fdisk -l
Disk /dev/xvda: 8 GiB, 8589934592 bytes, 16777216 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 1C33C38B-2E58-44EC-8AEF-2FC4CC9AC6D8

Device       Start      End  Sectors Size Type
/dev/xvda1   24576 16777182 16752607   8G Linux filesystem
/dev/xvda127 22528    24575     2048   1M BIOS boot
/dev/xvda128  2048    22527    20480  10M EFI System

Partition table entries are not in disk order.

Disk /dev/xvdf: 5 GiB, 5368709120 bytes, 10485760 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

```bash
# df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        4.0M     0  4.0M   0% /dev
tmpfs           475M     0  475M   0% /dev/shm
tmpfs           190M  460K  190M   1% /run
/dev/xvda1      8.0G  1.6G  6.4G  20% /
tmpfs           475M  3.7M  472M   1% /tmp
/dev/xvda128     10M  1.3M  8.7M  13% /boot/efi
tmpfs            95M     0   95M   0% /run/user/1000
```

### 6. **Partition the Volume**

Use `fdisk` to create a new partition on the volume:

```bash
fdisk /dev/xvdf
```

Then follow these steps inside `fdisk`:
- Press `m` for help to get all the options.
- Press `n` to create a new partition.
- Press `p` to choose a primary partition.
- Accept default partition number and sectors by pressing Enter.
- First selector => Hit enter.
- Last selector => Hit enter. Or, give +3G for 3 GiB.
- Press `p` to print the partition table.
- Press `w` to write the partition and exit.

### 7. **Format the Partition**

Type `mkfs` and hit `Tab` button 2 times to get all the options.

Format the new partition (`/dev/xvdf1`) with the ext4 filesystem:

```bash
mkfs.ext4 /dev/xvdf1
```

### **Moving Existing Data (Optional)**

If the `/images` folder has content on the root volume, move it to a backup before mounting:

```bash
mkdir -p /tmp/img-backup
mv /var/www/html/images/* /tmp/img-backup/
```

Try accessing the ip address of the instance, you won't see any image on the website.

Then, after mounting the new volume, we will move the files back (Not now):

```bash
mv /tmp/img-backup/* /var/www/html/images/
```

### 8. **Create a Mount Point and Mount the Volume**

1. Create the directory where you want to mount the volume:

```bash
mkdir -p /var/www/html/images
```

2. Temporarily mount the volume:

```bash
mount /dev/xvdf1 /var/www/html/images
```

3. Verify the mount:

```bash
# df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        4.0M     0  4.0M   0% /dev
tmpfs           475M     0  475M   0% /dev/shm
tmpfs           190M  464K  190M   1% /run
/dev/xvda1      8.0G  1.6G  6.4G  20% /
tmpfs           475M  4.4M  471M   1% /tmp
/dev/xvda128     10M  1.3M  8.7M  13% /boot/efi
tmpfs            95M     0   95M   0% /run/user/1000
/dev/xvdf1      4.9G   24K  4.6G   1% /var/www/html/images
```

To unmount the volume:

```bash
umount /var/www/html/images
```

This is a temporary mount, so if you reboot, you will have to mount it again.

### 9. **Make the Mount Persistent**

To ensure the volume mounts automatically on reboot:

1. Edit the fstab file:

```bash
nano /etc/fstab
```

2. Add the following line at the end:

```
/dev/xvdf1  /var/www/html/images  ext4  defaults  0  0
```

3. Save and exit, then test the configuration:

```bash
mount -a
```

If no errors appear, the mount configuration is correct.

### 11. **Verify Web Server Access**

Restart your web server (e.g., Apache):

```bash
systemctl restart httpd
```

After mounting the new volume, we will move the files back (Not now):

```bash
mv /tmp/img-backup/* /var/www/html/images/
```

Check that your images are served correctly from the browser. Note:- use different browser to check the images because previous cache may be there (if the same browser used).

If they do not appear, it may be due to **SELinux** policies.

### 12. **Optional: Disable SELinux (for troubleshooting)**

If SELinux is blocking access and you’re in a testing environment:

1. Edit the config:

```bash
nano /etc/selinux/config
```

2. Change `SELINUX=enforcing` to `SELINUX=disabled` and reboot:

```bash
reboot
```

By following this process, you've successfully created, attached, and mounted a new EBS volume to your EC2 instance. This setup not only helps with better data organization but also allows for scalable storage expansion in the future.

Don't terminate the instance, we will use it in the next section.

---

## 3. Managing EBS Volumes and Snapshots in AWS

In this section, we’ll explore how to manage EBS volumes and use snapshots effectively — especially in scenarios where you might lose data or need to recover from failure. This builds upon what we covered previously.

Let’s start by renaming our EC2 instance from `web01` to `db01`. If you've terminated your previous instance, go ahead and launch a new EC2 instance using the **Amazon Linux AMI** and **t2.micro**.

### Unmounting and Mounting Volumes

First, unmount any existing attached volumes:

```bash
df -h
umount /var/www/html/images
```

If the unmount command fails, it’s likely because a process (like Apache) is using that directory. Use `lsof` to find the process:

```bash
yum install lsof -y
lsof /var/www/html/images
```

Once you identify the process, you can either stop it or move out of the directory before unmounting. Avoid using `umount -l` unless necessary, as it doesn’t actually stop the process — just detaches the mount point.

```bash
cd 
kill -9 pid
lsof /var/www/html/images
umount /var/www/html/images
```

After unmounting, go to the **Volumes** section in the AWS console and detach the volume. If detaching takes too long, try a **force detach**, or shut down the instance if needed. Once detached, delete the volume to avoid unnecessary charges.

### Creating and Attaching a New Volume for MySQL

Now, create a new volume (e.g., 5 GB, General Purpose SSD gp2) in the same availability zone. Name it `db01-volume`, and attach it to your EC2 instance as `/dev/sdf`.

Back on the instance (CLI), if logged out then login again:

```bash
fdisk -l
fdisk /dev/xvdf
# Press 'n' for new partition, 'p' for primary, '1' for partition number, First sector => Hit Enter, Last sector => +3G
# Press Enter for default sectors, specify size (e.g., +3G), then 'w' to write

mkfs.ext4 /dev/xvdf1
mkdir /var/lib/mysql
```

Update the `/etc/fstab` file to mount the volume at boot. Then:

```bash
vi /etc/fstab
# update the line
# /dev/xvdf1 /var/lib/mysql ext4 defaults 0 0
```

```bash
mount -a
df -h
```

### Installing MySQL and Using the Mounted Volume

Install MariaDB (MySQL alternative for CentOS):

```bash
sudo -i
dnf update -y
dnf install mariadb105-server -y
systemctl enable --now mariadb
```

Ensure that `/var/lib/mysql` is now being used to store database files. Always mount and prepare your volumes before installing the database service.

### Taking and Using Snapshots

To protect your data, use **snapshots** — AWS’s backup solution for EBS volumes. If you ever lose your data:

1. **Unmount the volume** immediately to prevent data from being overwritten.
2. **Detach the volume**.
3. **Create a new volume from the snapshot** and attach it to your instance.
4. Mount the new volume — it will already contain the restored data.

Snapshots are especially useful because:

* You can create new volumes of different types or sizes from them.
* You can change availability zones.
* You can encrypt an unencrypted volume via a snapshot.
* Snapshots can be copied across regions or shared with other AWS accounts.

To take a snapshot:

1. Go to the **Volumes** section.
2. Select your volume → **Actions → Create Snapshot**.
3. Provide a name and description `db volume snapshot`.

You can monitor the progress in the **Snapshots** tab.

### Recovery Example

If you accidentally delete `/var/lib/mysql` data:

1. Stop the MariaDB service.
2. Unmount the volume and mark it as “corrupted”.
3. Create a new volume from your snapshot.
4. Attach the new volume and mount it — your data should be back.

```bash
cd /var/lib/mysql
lsrm -rf *
df -h
systemctl stop mariadb
cd ..
umount /var/lib/mysql
fdisk -l
```
5. Rename the volume from `db01-volume` to `db01-volume-old` and Detach the old volume from Volume Explorer.
6. Detach the new volume from Volume Explorer.
7. Create a new volume from your snapshot. In snapshots section, select your snapshot → Actions → Create Volume from Snapshot. Add tags:- Name: `db01-volume-db-recovered`.  Create the volume.
8. Attach the new volume and mount it. Check it using `df -h`.

```bash
# ls /var/lib/mysql/
# mount -a
# ls /var/lib/mysql/
aria_log.00000001  ib_logfile0  lost+found         mysql.sock
aria_log_control   ibdata1      multi-master.info  mysql_upgrade_info
ib_buffer_pool     ibtmp1       mysql              performance_schema
```

9. Start the MariaDB service.

### Cleanup and Cost Management

- Using snapshots, we can transfer data from **one region to another** without losing any data.
- We can make the snapshot public also.
- Or, we can share it with other AWS accounts.

After you're done:

* Terminate your EC2 instance.
* After EC2 instance termination, Delete any unused volumes and snapshots to avoid charges.
* Ensure that your **EC2 dashboard** shows zero running volumes and snapshots.

By following this practice, you not only ensure recoverability but also manage your AWS costs effectively.

---
