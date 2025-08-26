#!/bin/bash
set -e

echo "=== Starting Laravel Application (Production Mode) ==="
echo "PORT: $PORT"
echo "APP_ENV: $APP_ENV"
echo "APP_URL: $APP_URL"

# Validate critical environment variables
if [ -z "$PORT" ]; then
    echo "ERROR: PORT environment variable is not set"
    export PORT=8000
    echo "Using default PORT: 8000"
fi

# Wait for database
echo "Waiting for database connection..."
sleep 15

# Clear all caches
echo "Clearing caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Generate application key if not set
if [ -z "$APP_KEY" ]; then
    echo "Generating APP_KEY..."
    php artisan key:generate --force
fi

# Cache config for production
echo "Caching configuration for production..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run migrations
echo "Running migrations..."
php artisan migrate --force

# Seed database
echo "Seeding database..."
php artisan db:seed --force

# Generate Swagger documentation
echo "Generating API documentation..."
php artisan l5-swagger:generate

# Start the application
echo "Starting Laravel application on 0.0.0.0:$PORT"
exec php artisan serve --host=0.0.0.0 --port=$PORT
