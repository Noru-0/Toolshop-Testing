# 🚨 Railway Deployment Troubleshooting Guide

## Current Error: "Application failed to respond"

### 🔍 **Possible Causes & Solutions:**

## 1. **Port Configuration Issues**

### API Service (Laravel):
Check if the API is binding to the correct port:

**In `start.sh`:**
```bash
php artisan serve --host=0.0.0.0 --port=$PORT
```

**Alternative fix - Create new start script:**
```bash
#!/bin/bash
echo "Starting Laravel on port $PORT"
php artisan serve --host=0.0.0.0 --port=${PORT:-8000}
```

### UI Service (Angular):
**In Procfile:**
```
web: npm run build && serve -s dist/toolshop -l $PORT
```

## 2. **Database Connection Issues**

### Check Environment Variables:
```
DB_HOST=your-mysql-host-from-railway
DB_PORT=your-mysql-port-from-railway  
DB_DATABASE=railway
DB_USERNAME=root
DB_PASSWORD=your-mysql-password-from-railway
```

### Test Database Connection:
Add to `start.sh`:
```bash
# Test database connection
echo "Testing database connection..."
php artisan migrate:status || echo "Database connection failed"
```

## 3. **Missing APP_KEY**

**Generate APP_KEY:**
```bash
php artisan key:generate --show
```

Copy the output and set as environment variable:
```
APP_KEY=base64:your-generated-key-here
```

## 4. **Health Check Endpoint**

Create a simple health check route in Laravel:

**routes/web.php:**
```php
Route::get('/health', function () {
    return response()->json(['status' => 'OK', 'timestamp' => now()]);
});
```

## 5. **Logs Analysis**

### Check Railway Logs:
1. Go to Railway dashboard
2. Select your service
3. Click "Deployments" tab
4. Check build and runtime logs

### Common Log Errors:
- `Connection refused` → Database issue
- `Port already in use` → Port configuration
- `Class not found` → Composer autoload issue
- `Permission denied` → File permissions

## 6. **Quick Fixes to Try:**

### Fix 1: Update start.sh with better error handling
```bash
#!/bin/bash
set -e

echo "=== Starting Laravel Application ==="
echo "PORT: $PORT"
echo "DB_HOST: $DB_HOST"

# Wait for database
echo "Waiting for database..."
sleep 10

# Clear caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Generate key if missing
if [ -z "$APP_KEY" ]; then
    echo "Generating APP_KEY..."
    php artisan key:generate --force
fi

# Run migrations
echo "Running migrations..."
php artisan migrate --force

# Seed database (optional)
echo "Seeding database..."
php artisan db:seed --force || echo "Seeding failed, continuing..."

# Start server
echo "Starting server on 0.0.0.0:$PORT"
exec php artisan serve --host=0.0.0.0 --port=$PORT
```

### Fix 2: Update Dockerfile for better reliability
```dockerfile
FROM php:8.2-cli

# Install dependencies
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy files
COPY . .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Set permissions
RUN chmod +x start.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:$PORT/health || exit 1

EXPOSE $PORT

CMD ["./start.sh"]
```

## 7. **Environment Variables Checklist:**

### API Service:
```
APP_NAME=ToolShop-API
APP_ENV=production
APP_KEY=base64:your-generated-key
APP_DEBUG=false
APP_URL=https://your-api-domain.railway.app

DB_CONNECTION=mysql
DB_HOST=your-mysql-host
DB_PORT=your-mysql-port
DB_DATABASE=railway
DB_USERNAME=root
DB_PASSWORD=your-mysql-password

LOG_CHANNEL=stack
LOG_LEVEL=error
```

### UI Service:
```
NODE_ENV=production
API_URL=https://your-api-domain.railway.app
```

## 8. **Test Locally First:**

Before deploying, test with Docker locally:
```bash
cd sprint5-with-bugs/API
docker build -t toolshop-api .
docker run -p 8000:8000 -e PORT=8000 toolshop-api
```

## 🚀 **Immediate Action Steps:**

1. **Check Railway logs** for specific error messages
2. **Verify environment variables** are set correctly
3. **Update start.sh** with the improved version above
4. **Test health endpoint** after deployment
5. **Check database connectivity** in logs

## 📞 **If Still Failing:**

1. Try deploying a minimal version first (without database)
2. Add logging to see where it fails
3. Check Railway service resources (CPU/Memory limits)
4. Verify the correct Root Directory is set for each service

---

**Next: Follow the immediate action steps above to resolve the deployment issue.**
