#!/bin/bash

# Wait for database to be ready
echo "Waiting for database connection..."
sleep 10

# Generate application key if not set
if [ -z "$APP_KEY" ]; then
    echo "Generating APP_KEY..."
    php artisan key:generate --force
fi

# Clear and cache config
php artisan config:clear
php artisan config:cache

# Run migrations and seed the database
echo "Running migrations and seeding database..."
php artisan migrate:fresh --seed --force

# Generate Swagger documentation
echo "Generating API documentation..."
php artisan l5-swagger:generate

# Start the application
echo "Starting Laravel application on port $PORT..."
php artisan serve --host=0.0.0.0 --port=$PORT
