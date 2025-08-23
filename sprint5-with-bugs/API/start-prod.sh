#!/bin/bash
set -e

# Production startup script - minimal logging, faster startup

echo "=== Starting Laravel Application (Production Mode) ==="
echo "PORT: $PORT"
echo "APP_ENV: $APP_ENV"

# Validate critical environment variables
if [ -z "$PORT" ]; then
    echo "ERROR: PORT environment variable is not set"
    export PORT=8000
    echo "Using default PORT: 8000"
fi

# Clear all caches silently but show errors
echo "Clearing caches..."
php artisan config:clear > /dev/null 2>&1 || echo "❌ Config clear failed"
php artisan cache:clear > /dev/null 2>&1 || echo "❌ Cache clear failed"  
php artisan route:clear > /dev/null 2>&1 || echo "❌ Route clear failed"
php artisan view:clear > /dev/null 2>&1 || echo "❌ View clear failed"

# Generate application key if not set
if [ -z "$APP_KEY" ]; then
    echo "Generating APP_KEY..."
    php artisan key:generate --force > /dev/null 2>&1 || echo "❌ Key generation failed"
fi

# Cache config for production
echo "Caching configuration..."
php artisan config:cache > /dev/null 2>&1 || echo "❌ Config cache failed"

# Wait for database
echo "Waiting for database connection..."
sleep 5

# Test database connection using Laravel artisan
echo "Testing database connectivity..."
php artisan migrate:status > /dev/null 2>&1 && echo "✅ Database connection successful" || echo "⚠️ Database connection failed, continuing anyway..."

# Run migrations only (skip seeding for production)
echo "Running migrations..."
php artisan migrate --force > /dev/null 2>&1 && echo "✅ Migrations completed" || echo "⚠️ Migrations failed, continuing..."

# Skip seeding in production to avoid log spam
echo "Skipping database seeding in production mode"

# Start the application
echo "Starting Laravel application on 0.0.0.0:$PORT"
echo "Health check available at: $APP_URL/health"

# Verify port is numeric and valid
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    echo "ERROR: PORT is not a valid number: $PORT"
    export PORT=8000
    echo "Using fallback PORT: 8000"
fi

echo "Executing Laravel development server..."
exec php artisan serve --host=0.0.0.0 --port=$PORT
