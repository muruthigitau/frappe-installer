#!/bin/bash

echo "Enter the full domain (e.g., erp.example.com):"
read full_domain

# Extract site name and base domain
site_name=$full_domain
base_domain=$(echo $full_domain | cut -d. -f2-)
custom_domain="www.$base_domain"

echo "Setting up site: $site_name"
echo "Using custom domain for SSL: $custom_domain"
echo "-------------------------------"

# 1. Create new site
bench new-site "$site_name"

# 2. Install apps
for app in payments erpnext lending hrms crm insights print_designer
do
    bench --site "$site_name" install-app "$app"
done

# 3. Use the site
bench use "$site_name"

# 4. Add to hosts
bench --site "$site_name" add-to-hosts

# 5. Enable scheduler and disable maintenance mode
bench --site "$site_name" enable-scheduler
bench --site "$site_name" set-maintenance-mode off

# 6. Enable DNS multitenant
bench config dns_multitenant on

# 7. Add domain and setup SSL
bench setup add-domain "$base_domain" --site "$site_name"

sudo -H bench setup lets-encrypt "$site_name"
sudo -H bench setup lets-encrypt --custom-domain "$custom_domain" "$site_name"

echo "✅ ERP site setup complete!"
echo "Site: https://$site_name"
echo "SSL Custom Domain: https://$custom_domain"
