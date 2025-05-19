#!/bin/bash

# ======= Prompt for Inputs =======
read -p "Is this the first time setting up production on this server? (y/n): " is_first_time
read -p "Enter your Linux user running bench (e.g., frappe): " bench_user
read -p "Enter the full domain (e.g., erp.example.com): " full_domain

# ======= Variables =======
site_name=$full_domain
base_domain=$(echo $full_domain | cut -d. -f2-)
custom_domain="www.$base_domain"

# ======= First Time Setup =======
if [[ "$is_first_time" == "y" || "$is_first_time" == "Y" ]]; then
    echo "⚙️ First-time setup: enabling DNS multitenancy..."
    bench config dns_multitenant on

    echo "🔧 Setting up production environment..."
    sudo bench setup production "$bench_user"

    echo "🧱 Building bench for production..."
    bench build --production
else
    echo "⏭️ Skipping DNS and production setup (not first time)."
fi

# ======= Create Site =======
echo "🏗️ Creating new site: $site_name"
bench new-site "$site_name"

# ======= Install Apps =======
echo "📦 Installing apps on $site_name..."
for app in payments erpnext lending hrms crm print_designer
do
    bench --site "$site_name" install-app "$app"
done

# ======= Setup site =======
echo "🔗 Configuring site..."
bench --site "$site_name" add-to-hosts
bench --site "$site_name" enable-scheduler
bench --site "$site_name" set-maintenance-mode off
bench setup add-domain "$base_domain" --site "$site_name"

# ======= Setup SSL =======
echo "🔐 Setting up Let's Encrypt SSL..."
sudo -H bench setup lets-encrypt "$site_name"
sudo -H bench setup lets-encrypt --custom-domain "$custom_domain" "$site_name"

# ======= Final Clean-up and Restart =======
echo "🧹 Clearing bench cache..."
bench clear-cache

echo "🔄 Restarting bench and services..."
bench restart
sudo supervisorctl restart all
sudo service nginx reload

# ======= Done =======
echo "✅ ERP site setup complete!"
echo "Primary Site: https://$site_name"
echo "Custom SSL Domain: https://$custom_domain"
