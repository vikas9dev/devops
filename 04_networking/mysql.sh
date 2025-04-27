#!/bin/bash
sudo yum install mariadb-server -y
sudo systemctl enable --now mariadb
mysql -u root -e 'CREATE DATABASE wordpress;'
mysql -u root -e 'GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@localhost IDENTIFIED BY "admin123";'
mysql -u root -e 'FLUSH PRIVILEGES;'