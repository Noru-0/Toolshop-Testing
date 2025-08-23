#!/bin/bash

echo "🧪 TESTING DEPLOYMENT FIXES LOCALLY"
echo "==================================="

# Test API health check
echo "1. Testing API health endpoint..."
cd sprint5-with-bugs/API

# Check if Laravel can start
echo "   Checking Laravel configuration..."
php artisan config:clear
php artisan config:cache

# Test health check route
echo "   Testing health check route..."
php artisan route:list | grep health

echo ""
echo "2. Testing UI build process..."
cd ../UI

# Test build process
echo "   Running build test..."
npm run build

if [ -d "dist/toolshop" ]; then
    echo "   ✅ UI build successful"
    echo "   Build output size: $(du -sh dist/toolshop | cut -f1)"
else
    echo "   ❌ UI build failed"
fi

echo ""
echo "3. Testing environment variable replacement..."
export API_URL="https://test-api.railway.app"
npm run build:railway

if grep -r "test-api.railway.app" dist/toolshop/ > /dev/null; then
    echo "   ✅ API URL replacement working"
else
    echo "   ❌ API URL replacement failed"
fi

echo ""
echo "🎯 LOCAL TEST COMPLETE"
echo "If all tests pass, your fixes are ready for Railway deployment!"
