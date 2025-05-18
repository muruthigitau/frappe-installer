#!/bin/bash

echo "Enter name for new bench (e.g., mybench):"
read bench_name

echo "Creating new bench: $bench_name"
bench init --frappe-branch version-15 "$bench_name"
cd "$bench_name" || exit

echo "Fetching required apps..."
bench get-app payments
bench get-app --branch version-15 erpnext
bench get-app --branch version-15 hrms
bench get-app --branch version-15 lending
bench get-app crm
bench get-app insights
bench get-app print_designer

echo "✅ Bench setup complete in ./$bench_name"
