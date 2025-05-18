#!/bin/bash

echo "🔄 Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

sudo chmod 701 .
sudo chmod -R o+rx .

echo "📦 Installing core dependencies..."
sudo apt-get install git -y
sudo apt install git python-is-python3 python3-dev python3-pip python3-venv redis-server -y
sudo apt-get install xvfb libfontconfig wkhtmltopdf libmysqlclient-dev -y
sudo apt install mariadb-server mariadb-client -y

echo "🐍 Installing Frappe Bench CLI..."
sudo pip install frappe-bench --break-system-packages

echo "♻️ Refreshing shell cache..."
hash -r

echo "🧰 Setting up Node.js and Yarn..."
sudo apt install curl -y
sudo apt-get remove --purge nodejs -y
sudo apt-get autoremove -y
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install npm -y
sudo npm install -g yarn

echo "🔒 Installing Certbot and NGINX..."
sudo apt-get install certbot -y
sudo apt install nginx -y

sudo systemctl start nginx
sudo systemctl enable nginx

echo "🛡️ Securing MariaDB..."
sudo mysql_secure_installation

echo "⚙️ Configuring MySQL for utf8mb4..."
CONFIG_BLOCK="[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

[mysql]
default-character-set = utf8mb4"

echo "$CONFIG_BLOCK" | sudo tee -a /etc/mysql/my.cnf
sudo service mysql restart
hash -r

echo "✅ All dependencies installed and configured!"
