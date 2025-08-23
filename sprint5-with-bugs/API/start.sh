#!/bin/bash
set -e

# Run deployment health check first
echo "Running pre-deployment health check..."
chmod +x deploy-check.sh
./deploy-check.sh

echo "=== Starting Laravel Application ==="
echo "PORT: $PORT"
echo "DB_HOST: $DB_HOST"
echo "APP_ENV: $APP_ENV"
echo "APP_URL: $APP_URL"

# Validate critical environment variables
if [ -z "$PORT" ]; then
    echo "ERROR: PORT environment variable is not set"
    export PORT=8000
    echo "Using default PORT: 8000"
fi

# Wait for database with health check
echo "Waiting for database connection..."
sleep 15

# Add database connectivity test
echo "Testing database connectivity..."
timeout 30 bash -c 'until mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USERNAME" -p"$DB_PASSWORD" -e "SELECT 1"; do echo "Waiting for database..."; sleep 2; done' || echo "Database test failed, continuing anyway..."

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
echo "Caching configuration..."
php artisan config:cache

# Test database connection
echo "Testing database connection..."
php artisan migrate:status || {
    echo "Database connection failed, retrying in 10 seconds..."
    sleep 10
    php artisan migrate:status || {
        echo "Database still not available, but continuing with app start..."
    }
}

# Run migrations and seed
echo "Running migrations..."
php artisan migrate --force || echo "Migrations failed, continuing..."

echo "Seeding database..."
php artisan db:seed --force || echo "Seeding failed, continuing..."

# Generate Swagger documentation
echo "Generating API documentation..."
php artisan l5-swagger:generate || echo "Swagger generation failed, continuing..."

# Create a health check endpoint
echo "Setting up health check..."

# Start the application with enhanced error handling
echo "Starting Laravel application on 0.0.0.0:$PORT"
echo "Health check will be available at: $APP_URL/health"

# Start with timeout and error handling
timeout 300 php artisan serve --host=0.0.0.0 --port=$PORT || {
    echo "ERROR: Laravel failed to start within 5 minutes"
    echo "Attempting restart with debug mode..."
    export APP_DEBUG=true
    php artisan serve --host=0.0.0.0 --port=$PORT
}
