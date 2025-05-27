#!/bin/bash

set -e

echo "[INFO] Starting SonarQube Setup..."

# ⚠️ Fix system settings (Don't use ulimit in sysctl.conf)
cp /etc/sysctl.conf /root/sysctl.conf_backup
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
echo "fs.file-max=65536" >> /etc/sysctl.conf
sysctl -p

cp /etc/security/limits.conf /root/sec_limit.conf_backup
cat <<EOT> /etc/security/limits.conf
sonar   -   nofile   65536
sonar   -   nproc    4096
EOT

echo "[INFO] Installing JDK 17..."
apt-get update -y
apt-get install openjdk-17-jdk zip net-tools wget gnupg2 nginx -y

# PostgreSQL setup
echo "[INFO] Installing PostgreSQL..."
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
apt-get update && apt install postgresql postgresql-contrib -y
systemctl enable postgresql
systemctl start postgresql

echo "postgres:admin123" | chpasswd
runuser -l postgres -c "createuser sonar"
sudo -i -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED PASSWORD 'admin123';"
sudo -i -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;"
systemctl restart postgresql

# SonarQube download and setup
mkdir -p /sonarqube/
cd /sonarqube/
curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.8.100196.zip
unzip -o sonarqube-9.9.8.100196.zip -d /opt/
mv /opt/sonarqube-9.9.8.100196 /opt/sonarqube

groupadd sonar
useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar
chown sonar:sonar /opt/sonarqube/ -R

# Configuration
cat <<EOT> /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin123
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.log.level=INFO
sonar.path.logs=logs
EOT

# Systemd service
cat <<EOT> /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target postgresql.service

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable sonarqube

# NGINX reverse proxy
rm -f /etc/nginx/sites-enabled/default
cat <<EOT> /etc/nginx/sites-available/sonarqube
server {
    listen 80;
    server_name localhost;

    access_log  /var/log/nginx/sonar.access.log;
    error_log   /var/log/nginx/sonar.error.log;

    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    location / {
        proxy_pass  http://127.0.0.1:9000;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;

        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto http;
    }
}
EOT

ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/sonarqube
systemctl enable nginx

# ⚠️ No reboot for Vagrant – just start services
systemctl start sonarqube
systemctl restart nginx

echo "[INFO] SonarQube is accessible at http://localhost:9000 or http://localhost"