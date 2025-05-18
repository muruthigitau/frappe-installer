#!/bin/bash

read -p "Enter your Linux user running bench (e.g., frappe): " bench_user

echo "⚙️ Enabling DNS multitenancy..."
bench config dns_multitenant on

echo "🔧 Setting up production environment..."
sudo bench setup production "$bench_user"

echo "🧱 Building bench for production..."
bench build --production


echo "🔧 Setting up production environment..."
sudo bench setup production "$bench_user"

echo "🧹 Clearing bench cache..."
bench clear-cache

echo "🔄 Restarting bench..."
bench restart

echo "✅ Bench commands completed. Restarting services..."
sudo supervisorctl restart all
sudo service nginx reload
