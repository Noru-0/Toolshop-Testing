#!/bin/bash

# Generate application key if not set
if [ -z "$APP_KEY" ]; then
    php artisan key:generate --force
fi

# Run migrations and seed the database
php artisan migrate:fresh --seed --force

# Start the application
php artisan serve --host=0.0.0.0 --port=$PORT
