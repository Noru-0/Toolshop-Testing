#!/bin/bash

# Build the Angular application
ng build --configuration production

# Replace API_URL placeholder with environment variable if set
if [ ! -z "$API_URL" ]; then
    echo "Replacing API URL with: $API_URL"
    find dist/toolshop -name "*.js" -exec sed -i "s|http://localhost:8091|$API_URL|g" {} \;
fi

echo "Build completed successfully!"
