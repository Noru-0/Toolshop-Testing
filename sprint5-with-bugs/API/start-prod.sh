#!/bin/bash
set -e

# Production startup script - minimal logging, faster startup

# Run deployment health check first
echo "Running pre-deployment health check..."
chmod +x deploy-check.sh
./deploy-check.sh > /dev/null 2>&1

echo "=== Starting Laravel Application (Production Mode) ==="
echo "PORT: $PORT"
echo "APP_ENV: $APP_ENV"

# Validate critical environment variables
if [ -z "$PORT" ]; then
    echo "ERROR: PORT environment variable is not set"
    export PORT=8000
    echo "Using default PORT: 8000"
fi

# Clear all caches silently
echo "Clearing caches..."
php artisan config:clear > /dev/null 2>&1
php artisan cache:clear > /dev/null 2>&1
php artisan route:clear > /dev/null 2>&1
php artisan view:clear > /dev/null 2>&1

# Generate application key if not set
if [ -z "$APP_KEY" ]; then
    echo "Generating APP_KEY..."
    php artisan key:generate --force > /dev/null 2>&1
fi

# Cache config for production
echo "Caching configuration..."
php artisan config:cache > /dev/null 2>&1

# Wait for database
echo "Waiting for database connection..."
sleep 10

# Test database connection using Laravel artisan
echo "Testing database connectivity using Laravel..."
php artisan migrate:status > /dev/null 2>&1 && echo "✅ Database connection successful" || echo "⚠️ Database connection failed, continuing anyway..."

# Run migrations only (skip seeding for production)
echo "Running migrations..."
php artisan migrate --force > /dev/null 2>&1 && echo "✅ Migrations completed" || echo "⚠️ Migrations failed, continuing..."

# Skip seeding in production to avoid log spam
echo "Skipping database seeding in production mode"

# Generate Swagger documentation
echo "Generating API documentation..."
php artisan l5-swagger:generate > /dev/null 2>&1 || echo "Swagger generation failed, continuing..."

# Start the application
echo "Starting Laravel application on 0.0.0.0:$PORT"
echo "Health check available at: $APP_URL/health"
echo "API health check available at: $APP_URL/api/health"

# Verify port is numeric and valid
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    echo "ERROR: PORT is not a valid number: $PORT"
    export PORT=8000
    echo "Using fallback PORT: 8000"
fi

echo "Laravel development server starting..."
exec php artisan serve --host=0.0.0.0 --port=$PORT
