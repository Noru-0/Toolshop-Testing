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
# Longer wait for Railway database startup
sleep 30

# Test database connection using Laravel artisan instead of mysql client
echo "Testing database connectivity using Laravel..."
# Try multiple times with backoff
for i in {1..5}; do
    if php artisan migrate:status > /dev/null 2>&1; then
        echo "✅ Database connection successful"
        break
    else
        echo "⚠️ Database connection attempt $i failed, retrying in 10 seconds..."
        sleep 10
    fi
done

# Clear all caches
echo "Clearing caches..."
# Ensure storage permissions
chmod -R 775 storage bootstrap/cache || echo "Permission update failed"
php artisan config:clear || echo "Config clear failed"
php artisan cache:clear || echo "Cache clear failed"  
php artisan route:clear || echo "Route clear failed"
php artisan view:clear || echo "View clear failed"

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
# Try database connection before migrations
if php artisan migrate:status > /dev/null 2>&1; then
    echo "✅ Database connection established"
    
    # Run migrations and seed
    echo "Running migrations..."
    php artisan migrate --force > /dev/null 2>&1 || echo "⚠️ Migrations failed, continuing..."

    echo "Seeding database..."
    php artisan db:seed --force > /dev/null 2>&1 || echo "⚠️ Seeding failed, continuing..."
else
    echo "⚠️ Database not available yet, starting without migrations"
    echo "App will still start - database operations will be handled at runtime"
fi

# Generate Swagger documentation
echo "Generating API documentation..."
php artisan l5-swagger:generate > /dev/null 2>&1 || echo "Swagger generation failed, continuing..."

# Create a health check endpoint
echo "Setting up health check..."

# Start the application with enhanced error handling
echo "Starting Laravel application on 0.0.0.0:$PORT"
echo "Health check will be available at: $APP_URL/health"
echo "API health check will be available at: $APP_URL/api/health"
echo "Status check will be available at: $APP_URL/api/status"

# Verify port is numeric and valid
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    echo "ERROR: PORT is not a valid number: $PORT"
    export PORT=8000
    echo "Using fallback PORT: 8000"
fi

echo "Final startup command: php artisan serve --host=0.0.0.0 --port=$PORT"

# Start with exec to replace shell process and enable proper signal handling
echo "Executing Laravel development server..."
exec php artisan serve --host=0.0.0.0 --port=$PORT
