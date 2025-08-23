#!/bin/bash

echo "🔍 RAILWAY DEPLOYMENT ACCESS DIAGNOSTIC"
echo "======================================"
echo "Timestamp: $(date)"
echo ""

# Function to test URL accessibility
test_url() {
    local url=$1
    local description=$2
    
    echo "Testing: $description"
    echo "URL: $url"
    
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200\|301\|302"; then
        echo "✅ ACCESSIBLE"
    else
        local status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        echo "❌ FAILED (HTTP $status)"
    fi
    echo ""
}

# Get Railway service URLs from user input
echo "Please provide your Railway service URLs:"
echo ""
read -p "Enter your API service URL (https://your-api.railway.app): " API_URL
read -p "Enter your UI service URL (https://your-ui.railway.app): " UI_URL

echo ""
echo "🧪 TESTING ACCESSIBILITY..."
echo ""

# Test API endpoints
if [ ! -z "$API_URL" ]; then
    test_url "$API_URL" "API Root"
    test_url "$API_URL/api/health" "API Health Check"
    test_url "$API_URL/api/status" "API Status"
else
    echo "⚠️ No API URL provided"
fi

# Test UI endpoints  
if [ ! -z "$UI_URL" ]; then
    test_url "$UI_URL" "UI Root"
    test_url "$UI_URL/index.html" "UI Index Page"
else
    echo "⚠️ No UI URL provided"
fi

echo "🔍 DETAILED DIAGNOSTICS..."
echo ""

# Test API health endpoint with details
if [ ! -z "$API_URL" ]; then
    echo "API Health Response:"
    curl -s "$API_URL/api/health" | jq . 2>/dev/null || curl -s "$API_URL/api/health"
    echo ""
fi

echo "📝 DIAGNOSTIC COMPLETE"
echo ""
echo "If tests show ❌ FAILED, check:"
echo "1. Railway dashboard - services are Active"
echo "2. Railway logs - deployment errors"
echo "3. Environment variables - all required vars set"
echo "4. Browser console - JavaScript errors"
