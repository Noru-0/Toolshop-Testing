#!/bin/bash
set -e

echo "=== Pre-deployment Health Check ==="

# Check if essential files exist
echo "Checking essential Laravel files..."
required_files=("composer.json" "artisan" "config/app.php")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
        exit 1
    fi
done

# Check PHP version
echo "Checking PHP version..."
php_version=$(php -r "echo PHP_VERSION;")
echo "PHP Version: $php_version"

# Check composer dependencies
echo "Checking Composer autoload..."
if [ -f "vendor/autoload.php" ]; then
    echo "✅ Composer autoload exists"
else
    echo "❌ Composer dependencies not installed"
    exit 1
fi

# Check critical environment variables
echo "Checking environment variables..."
critical_vars=("APP_KEY" "DB_HOST" "DB_DATABASE")
for var in "${critical_vars[@]}"; do
    if [ ! -z "${!var}" ]; then
        echo "✅ $var is set"
    else
        echo "⚠️ $var is not set"
    fi
done

echo "✅ Pre-deployment health check completed successfully"
