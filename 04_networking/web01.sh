#!/bin/bash

apt update
apt install apache2 wget unzip -y
systemctl enable --now apache2
cd /tmp/
wget https://www.tooplate.com/zip-templates/2135_mini_finance.zip
unzip -o 2135_mini_finance.zip
cp -r 2135_mini_finance/* /var/www/html
systemctl restart apache2