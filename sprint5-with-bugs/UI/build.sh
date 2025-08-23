#!/bin/bash

echo "=== Building Angular Application for Railway ==="
echo "NODE_ENV: ${NODE_ENV:-development}"
echo "API_URL: ${API_URL:-http://localhost:8091}"

# Build the Angular application
echo "Running Angular build..."
ng build --configuration production

# Replace API_URL placeholder with environment variable if set
if [ ! -z "$API_URL" ]; then
    echo "Replacing API URL with: $API_URL"
    find dist/toolshop -name "*.js" -exec sed -i "s|http://localhost:8091|$API_URL|g" {} \;
    echo "API URL replacement completed"
else
    echo "No API_URL provided, using default localhost"
fi

# Verify build output
if [ -d "dist/toolshop" ]; then
    echo "✅ Build completed successfully!"
    echo "Build output directory: dist/toolshop"
    echo "Files in build:"
    ls -la dist/toolshop/ | head -10
else
    echo "❌ Build failed - dist/toolshop directory not found"
    exit 1
fi

echo "=== Build process completed ==="
