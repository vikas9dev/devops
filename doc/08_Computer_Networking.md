# Computer Network

## 1. Fundamentals of Computer Networking

Welcome to the foundational session on **computer networking**—an essential stepping stone before diving into cloud computing, Docker, or Kubernetes. If you're pursuing a DevOps path, networking is a must-know skill. You'll be responsible for managing cloud environments, connecting systems, and automating infrastructure. But as we say, **to automate it, you must first understand it manually**.

This session focuses on the **core concepts of networking**, covering everything from components and models to commands and real-world examples. Here's a quick overview of what we'll explore:

- **Networking components**: We'll begin by understanding the elements responsible for establishing and maintaining networks.
- **OSI model**: You’ll get to know the seven-layer architecture, from the physical cable to the application level.
- **Network classifications**: Learn how networks are categorized based on geography.
- **Networking devices**: Get familiar with switches, routers, and how they interact.
- **Home networks**: Understand your personal Wi-Fi setup and how it connects to the broader internet.
- **IP addresses and protocols**: Discover how data is routed using IPs and how key protocols like DNS and DHCP operate.
- **Hands-on commands**: While this session is theory-heavy (around 90%), we’ll finish with practical networking commands you can use for troubleshooting and system connectivity.

### What Is a Computer Network?

In today’s connected world, billions of devices—smartphones, laptops, IoT gadgets—communicate over networks. At its core, a **computer network** is simply the communication between two or more **network interfaces**, each assigned a unique IP address. Whether it’s an Ethernet port on a laptop or a wireless adapter in a smartphone, these interfaces enable devices to send and receive data across local or global networks.

### Components of a Network

To build a network, you need:

- **Devices** like laptops, smartphones, or IoT gadgets
- **Cables or wireless signals** connecting them
- **Network interface cards (NICs)** on each device
- **Switches** to link devices on a local level
- **Routers** to connect different networks
- **Operating systems and applications** to interpret the incoming data

All these components rely on **standards** to ensure seamless communication.

### The Importance of Standards and the OSI Model

Just like humans need a common language to communicate across cultures, devices need standardized protocols. That’s where the **OSI (Open Systems Interconnection) model**, developed by ISO (International Organization for Standardization), comes in. This seven-layer model, created in 1984, ensures that every device, operating system, and app communicates in a consistent way.

![OSI Model](/doc/images/osi-model.png)

The seven layers of the OSI model are:

1. **Physical** – Actual cables or wireless signals transmitting bits (1s and 0s).
2. **Data Link** – Responsible for error-free transfer between two nodes; deals with MAC addresses and organizes data into **frames**.
3. **Network** – Ensures delivery between networks using **IP addresses**, organizing data into **packets**.
4. **Transport** – Ensures reliable delivery of messages, handles **acknowledgments** and **retransmissions**.
5. **Session** – Manages sessions between devices (start, maintain, and terminate connections).
6. **Presentation** – Handles **encryption**, **decryption**, **compression**, and **data translation**.
7. **Application** – Interfaces with user-facing applications like browsers, email clients, etc.

Think of it like sending a letter:-

- You write it (Application layer)
- You pack and send it through a system (Layers 6 to 2)
- A physical mailman (Layer 1) delivers it
- The receiver unpacks and reads it (Layers 2 to 7 on the receiving end)

Each layer serves a unique role and communicates with adjacent layers through well-defined **interfaces**.

![OSI Model](/doc/images/iso-model-sample.png)

The basic elements of a layered model are:-

- services
- protocols
- and interfaces.

1. A service is a set of actions that a layer offers to another (higher) layer.
2. A protocol is a set of rules that a layer uses to communicate with another (lower) layer.
3. An interface is communication between the layers.

![OSI Model Sending Data](/doc/images/osi-sending-recieving-data.png)

### Devices by Layer

Each OSI layer has associated devices:-

- **Layer 1 (Physical):** Cables, Hubs
- **Layer 2 (Data Link):** Switches
- **Layer 3 (Network):** Routers, Firewalls
- **Layer 4 (Transport):** Gateways
- **Layers 5–7 (Session, Presentation, Application):** Servers, Browsers, Mail clients

| OSI Model     | DoD Model      | Protocols                                                    | Devices/Apps                                  |
| ------------- | -------------- | ------------------------------------------------------------ | --------------------------------------------- |
| Layer 5, 6, 7 | Application    | dns, dhcp, ntp, snmp, https, ftp, ssh, telnet, http, pop3... | web server, mail server, browser, mail client |
| Layer 4       | Host-to-Host   | tcp, udp                                                     | gateway                                       |
| Layer 3       | Internet       | ip, icmp, igmp                                               | router, firewall, layer 3 switch              |
| Layer 2       | Network        | arp (mac), rarp                                              | bridge, layer 2 switch                        |
| Layer 1       | Network Access | ethernet, token ring                                         | hub                                           |

![OSI Layers](/doc/images/osi%20layers.png)

### Key Takeaways

To navigate networks effectively, you need to:

- **Understand the name and function of each OSI layer**
- **Know which devices and protocols operate at which layers**
- **Apply theoretical knowledge with practical tools and commands**

---

## 2. Network Types, Devices, and IP Addressing

When classifying networks based on geography, we’re really talking about the physical distance between the communicating network interfaces. For example, your laptop has a network interface, and so does a Google server. The distance between them determines what kind of network they are part of.

### Types of Networks

Let’s start with the most familiar types of networks:

- **LAN (Local Area Network)**  
  A LAN is where devices are close together — often in the same room or building. Think of a few computers connected with cables or via Wi-Fi in your home or office. They share a switch and can easily communicate with each other.

- **WAN (Wide Area Network)**  
  WANs span much larger distances. The Internet is the biggest example. If you access a website hosted in a European data center from your smartphone in another country, you’re using a WAN.

- **MAN (Metropolitan Area Network)**  
  A MAN covers a city or large campus, such as a municipality's network infrastructure or the computer network of a metro train system.

- **CAN (Campus Area Network)**  
  Used within a limited geographical area like a college or office campus, a CAN connects multiple LANs over a few acres. Many people also refer to this as an **intranet**.

- **PAN (Personal Area Network)**  
  A PAN is for very short distances — like Bluetooth or mobile hotspots. It’s your own tiny network, typically connecting just a few devices.

### Key Networking Devices

Let’s break down the essential hardware used to build and connect networks:

- **Switch**  
  A switch connects multiple devices within the same LAN. If Node1 wants to send data to Node2, the switch intelligently forwards the data to the right port where Node2 is connected. Even your Wi-Fi router has a built-in switch.

  ![Switch](/doc/images/network-switches.png)

- **Router**  
  While switches connect devices within a network, **routers connect different networks**. For example, if your office campus has multiple buildings, each with its own switch, a router enables communication between them. At home, your router connects your LAN to the wider Internet (WAN).

  ![Router](data:image/jpeg;base64,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)

- **Home Network Example**  
  In a home setup, your devices connect to a router — either wired or wirelessly. This router often has:

  - A **modem** to connect to your Internet Service Provider (ISP)
  - A **switch** to connect multiple internal devices
  - **Routing & NAT capabilities** to manage traffic between your internal network and the Internet

  ![Home Network](/doc/images/home_network.png)

  Each device in the network — laptop, phone, router — has an IP address. Corporate networks work the same way but at a larger scale, with many routers, switches, firewalls, and multiple ISPs for redundancy and security.

---

### Subnets and IP Addressing

Larger networks are divided into **subnets**, each with its own IP addressing scheme. For example:

- A subnet for database servers
- A subnet for web servers
- Project-specific subnets

Each device in a subnet has a unique **IPv4 address**, which is a **32-bit binary number** typically shown in decimal format like `192.168.100.1`.

![IPV4 Address](/doc/images/ipv4_address.png)

#### Understanding IPv4

An IPv4 address consists of **four octets**:

- Example: `192.168.100.1`
  - 1st Octet: 192
  - 2nd Octet: 168
  - 3rd Octet: 100
  - 4th Octet: 1

Each octet ranges from **0 to 255**, because in binary, the maximum 8-bit number is `11111111`, which equals 255 in decimal.

#### Public vs Private IPs

IPv4 addresses are divided into two categories:-

- **Public IPs** – Used on the Internet; provided by ISPs
- **Private IPs** – Used within private networks

When you get an Internet connection, your ISP assigns you a **public IP**, often dynamically. For internal networking, you use **private IP ranges**, categorized as:

- **Class A**: `10.0.0.0` to `10.255.255.255`
- **Class B**: `172.16.0.0` to `172.31.255.255`
- **Class C**: `192.168.0.0` to `192.168.255.255`

Examples:

- `192.168.0.174` (Class C – commonly used in home networks)
- `172.16.12.30` (Class B)
- `10.1.5.2` (Class A)

Addresses outside these ranges are typically **public**. For instance, `172.32.36.87` is **not** a private IP.

### Scaling Up: From Home Networks to Enterprise Setups

Your home setup might have one LAN and one router. In enterprise networks or data centers:

- You’ll see **multiple LANs** and **subnets**
- Routers connect different parts of the network
- Switches create individual local networks
- Redundant devices ensure **high availability**
- **Firewalls and security appliances** are added for protection

Understanding your home network lays the foundation for comprehending larger and more complex networks.

---

## 3. Understanding Protocols, TCP vs UDP, and the Role of Port Numbers

In networking, a **protocol** is a formal set of rules that defines how communication occurs between devices. It covers how data is formatted, transmitted, and how errors are handled. Popular protocols include HTTP, FTP, and SSH. Both the client and server must understand and follow the same protocol for communication to be successful.

At the **Transport Layer (Layer 4)**, two primary protocols manage data transfer: **TCP** and **UDP**. Higher-layer protocols (Layers 5, 6, and 7) typically build on top of either TCP or UDP, depending on the communication needs.

### TCP (Transmission Control Protocol)

- **Connection-Oriented**: Establishes a connection between sender and receiver using a three-way handshake.
- **Reliable**: Ensures data arrives at the destination without errors and in the correct order.
- **Error Detection and Recovery**: Identifies lost or corrupted packets and retransmits them.
- **Acknowledgment-Based**: Data transfer is confirmed with acknowledgments from the receiver.
- **Use Cases**: Suitable for applications requiring guaranteed delivery, such as web browsing (HTTP/HTTPS), file transfers (FTP), and email (SMTP).

Example: When you send an email or upload a photo using HTTPS, TCP guarantees that your data is delivered completely and accurately.

### UDP (User Datagram Protocol)

- **Connectionless**: No formal connection is established before sending data.
- **Unreliable**: No guarantee that the data will reach the destination.
- **No Acknowledgments**: Once the data is sent, there is no confirmation of receipt.
- **Faster Transmission**: Minimal overhead compared to TCP, making it much quicker.
- **Use Cases**: Ideal where speed is critical and occasional data loss is acceptable, such as DNS queries, video streaming, VoIP calls, and DHCP.

Example: When you type a URL and your browser quickly needs to resolve it into an IP address via DNS, UDP makes it lightning fast without waiting for confirmations.

### Default Port Numbers for Common Protocols

Each service on a computer communicates over a specific **port number**, helping the system differentiate between multiple services running on the same IP address. Here's a table listing some common protocols and their default ports:

| Label on Column | Service Name              | UDP and TCP Port Numbers Included |
| --------------- | ------------------------- | --------------------------------- |
| DNS             | Domain Name Service – UDP | UDP 53                            |
| DNS TCP         | Domain Name Service – TCP | TCP 53                            |
| HTTP            | Web                       | TCP 80                            |
| HTTPS           | Secure Web (SSL)          | TCP 443                           |
| SMTP            | Simple Mail Transport     | TCP 25                            |
| POP             | Post Office Protocol      | TCP 109, 110                      |
| SNMP            | Simple Network Management | TCP 161, 162 / UDP 161, 162       |
| TELNET          | Telnet Terminal           | TCP 23                            |
| FTP             | File Transfer Protocol    | TCP 20, 21                        |
| SSH             | Secure Shell (terminal)   | TCP 22                            |
| AFP IP          | Apple File Protocol/IP    | TCP 447, 548                      |

Knowing these default ports is crucial when setting up **firewalls**, **security groups** (in AWS), or troubleshooting network issues.

### Practical Example: vProfile Project

In our **vProfile project**, a Java-based multi-tier application, multiple services will be running across different virtual machines. Each VM will have a unique IP address and host specific services on standard ports:

| Service  | Default Port | Example Usage           |
| -------- | ------------ | ----------------------- |
| Nginx    | 80           | Web server              |
| Tomcat   | 8080         | Java application server |
| RabbitMQ | 5672         | Messaging service       |
| Memcache | 11211        | Caching service         |
| MySQL    | 3306         | Database service        |

Understanding **which service runs where**, **on which IP address**, and **on which port** is critical when configuring firewalls, load balancers, and ensuring smooth inter-service communication.

---

## 4. Basic Networking Commands in Linux and Windows

Let us explore essential networking commands for both Linux and Windows systems. To demonstrate, set up two virtual machines using a Vagrant file:- `cd 04_Networking`

- **`web01`**: Static IP `192.168.40.11`, running **Apache2** on Ubuntu.
- **`db01`**: Static IP `192.168.40.12`, running **MariaDB**.

**Apache2** runs on port **80**, and **MariaDB** operates on port **3306**, which we’ll verify during our exercises.

### Setting Up and Basic Connectivity

Let us log into `web01`. This acts as our testing environment, but remember, these commands can be run from any Linux machine (and some even from Windows). Since some commands require administrative privileges, I'll often switch to the **root** user.

- **View network interfaces**:

  - `ifconfig`
  - Alternative: `ip addr show` (if `ifconfig` is unavailable)

- **Check network connectivity**:
  - `ping <IP address or hostname>` sends ICMP packets.
  - In Linux, it keeps pinging until stopped with **Ctrl+C**.
  - For hostnames, update `/etc/hosts` to map names to IP addresses (e.g., `192.168.40.12 db01`). Then use `ping db01` instead of `ping 192.168.40.12`.

### Tracing the Network Path

To trace the route packets take:

- **Linux**: `traceroute <destination>`
- **Windows**: `tracert <destination>`

Example:- `tracert www.google.in` This helps diagnose where any delays or packet loss occur. In VirtualBox, it might not work perfectly — better to test it from your **host machine**.

### Viewing Open Ports and Services

- **View open TCP ports**:

  - `netstat -antp`
  - Displays ports like 22 (SSH) and 80 (HTTP) and their associated processes.
  - Use `ps -ef | grep <PID>` to find more about a process.

- **Modern alternative**:
  - `ss -tunlp`
  - Provides detailed network socket info with process names.

### Scanning Networks

- **Scan for open ports**:
  - Install `nmap` if needed: `apt install nmap`
  - Usage:
    - `nmap localhost`
    - `nmap <target IP>` (e.g., `db01`)

⚡ **Important**: Use `nmap` responsibly. Unauthorized scanning can be illegal in some regions!

### DNS Queries and Name Resolution

- **Check DNS records**:

  - `dig <domain>` (e.g., `dig www.google.com`)
  - Shows IP addresses and DNS server details.

- **Older alternative**:
  - `nslookup <domain>`

### Routing and Address Tables

- **View routing table**:

  - `route -n`
  - Shows gateways for each network interface.

- **View ARP cache**:
  - `arp`
  - Lists IP and MAC address mappings known to the machine.

### Live Network Monitoring

- **Dynamic traceroute**:
  - `mtr <destination>` (e.g., `mtr www.google.com`)
  - Continuously shows live packet loss and latency at each hop.

Ideal for spotting intermittent issues between your machine and the destination.

### Testing Specific Ports

- **Test if a port is open**:
  - `telnet <IP or hostname> <port>`
  - Example: `telnet 192.168.40.12 3306` (check MariaDB port).

If connected, it means the port is reachable, even if the service itself rejects the session.

While there are many more networking tools (like `tcpdump` and `Wireshark`), mastering these basics will be enough for efficient troubleshooting. We will continue using these tools throughout the course.

---
