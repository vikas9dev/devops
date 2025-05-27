#!/bin/bash

set -e  # Exit on any error

# Import Amazon Corretto public key and add repo
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo

# Use dnf instead of yum for CentOS Stream 9
sudo dnf install -y java-17-amazon-corretto-devel wget

# Create directories
sudo mkdir -p /opt/nexus/
sudo mkdir -p /tmp/nexus/
cd /tmp/nexus/

# Download Nexus binary
NEXUSURL="https://download.sonatype.com/nexus/3/nexus-unix-x86-64-3.78.0-14.tar.gz"
wget $NEXUSURL -O nexus.tar.gz

# Extract and get directory name
EXTOUT=$(tar -tzf nexus.tar.gz | head -1 | cut -f1 -d"/")
tar -xzf nexus.tar.gz
rm -f nexus.tar.gz

# Copy files to /opt/nexus
sudo cp -r $EXTOUT/ /opt/nexus/

# Create nexus user if not exists
if ! id -u nexus >/dev/null 2>&1; then
  sudo useradd -r -s /sbin/nologin nexus
fi

# Create directory to store logs (expected by nexus)
sudo mkdir -p /opt/nexus/sonatype-work/nexus3

# Set ownership
sudo chown -R nexus:nexus /opt/nexus

# Create systemd service file
sudo bash -c 'cat > /etc/systemd/system/nexus.service <<EOF
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/'"$EXTOUT"'/bin/nexus start
ExecStop=/opt/nexus/'"$EXTOUT"'/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF'

# Configure nexus to run as nexus user
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/$EXTOUT/bin/nexus.rc

# Reload systemd, start and enable service
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus
