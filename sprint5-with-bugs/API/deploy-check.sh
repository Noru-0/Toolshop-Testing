#!/bin/bash

echo "=== RAILWAY DEPLOYMENT HEALTH CHECK ==="
echo "Timestamp: $(date)"
echo ""

# Environment variables check
echo "🔍 ENVIRONMENT VARIABLES:"
echo "PORT: ${PORT:-'NOT SET'}"
echo "APP_KEY: ${APP_KEY:0:20}..." 
echo "APP_URL: ${APP_URL:-'NOT SET'}"
echo "DB_HOST: ${DB_HOST:-'NOT SET'}"
echo "DB_PORT: ${DB_PORT:-'NOT SET'}"
echo "DB_DATABASE: ${DB_DATABASE:-'NOT SET'}"
echo "DB_USERNAME: ${DB_USERNAME:-'NOT SET'}"
echo "APP_ENV: ${APP_ENV:-'NOT SET'}"
echo ""

# Port validation
if [ -z "$PORT" ]; then
    echo "❌ CRITICAL: PORT environment variable is missing!"
    echo "   Railway requires the PORT variable to be set."
    exit 1
else
    echo "✅ PORT is set to: $PORT"
fi

# APP_KEY validation
if [ -z "$APP_KEY" ]; then
    echo "⚠️  WARNING: APP_KEY is not set"
    echo "   Generating one now..."
    php artisan key:generate --force
else
    echo "✅ APP_KEY is configured"
fi

# Database connection test
echo ""
echo "🔍 DATABASE CONNECTION TEST:"
if [ -z "$DB_HOST" ]; then
    echo "❌ DB_HOST not set - database connection will fail"
else
    echo "Testing connection to: $DB_HOST:$DB_PORT"
    
    # Simple connection test
    php artisan migrate:status > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ Database connection successful"
    else
        echo "❌ Database connection failed"
        echo "   Check your Railway MySQL database configuration"
    fi
fi

echo ""
echo "🚀 STARTING APPLICATION..."
echo "   Health check will be available at: $APP_URL/api/health"
echo "   Simple status at: $APP_URL/api/status"
echo ""

# Test if port is available
if netstat -tuln | grep ":$PORT " > /dev/null; then
    echo "⚠️  WARNING: Port $PORT appears to be in use"
fi

echo "✅ Pre-deployment checks complete"
echo "=== END HEALTH CHECK ==="
echo ""
