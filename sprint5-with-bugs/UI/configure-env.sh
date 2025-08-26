#!/bin/bash

echo "=== Configuring Environment for Railway ==="

# Create environment file with API URL from environment variable
API_URL_VALUE=${API_URL:-"https://toolshop-testing-production.up.railway.app/api"}
echo "Using API URL: $API_URL_VALUE"

# Create production environment file
cat > src/environments/environment.prod.ts << EOF
export const environment = {
  production: true,
  apiUrl: '$API_URL_VALUE'
};
EOF

echo "Environment configuration completed"
