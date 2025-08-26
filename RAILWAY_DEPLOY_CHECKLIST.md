# ✅ Railway Deployment Checklist - Sprint5 with Bugs

## 📋 Pre-deployment Checklist

### API Requirements ✅
- [x] `deploy-check.sh` exists and executable
- [x] `start.sh` configured properly  
- [x] `Dockerfile` ready for production
- [x] `nixpacks.toml` configured with PHP 8.2 + Node 20
- [x] Environment variables template ready

### UI Requirements ✅
- [x] `nixpacks.toml` fixed (no duplicates)
- [x] `package.json` build scripts configured
- [x] `Dockerfile` with serve setup
- [x] Node 20 consistency across configs

## 🚀 Deployment Steps

### Method 1: Railway Dashboard (Recommended)

#### Step 1: Deploy API Service
1. Go to Railway dashboard → "New Project"
2. Connect GitHub repository
3. **Root Directory**: `sprint5-with-bugs/API`
4. Railway will auto-detect Laravel + use nixpacks.toml

#### Step 2: Deploy UI Service
1. Add new service to same project
2. Connect same GitHub repository  
3. **Root Directory**: `sprint5-with-bugs/UI`
4. Railway will auto-detect Angular + use nixpacks.toml

#### Step 3: Add MySQL Database
1. "New Service" → "Database" → "MySQL"
2. Copy connection details for API environment variables

### Method 2: Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Deploy API
cd sprint5-with-bugs/API
railway up

# Deploy UI (new terminal)
cd sprint5-with-bugs/UI
railway up
```

## 🔧 Environment Variables Configuration

### API Service Environment Variables:
```env
# Application
APP_NAME=ToolShop-API
APP_ENV=production
APP_KEY=base64:YOUR_GENERATED_KEY
APP_DEBUG=false
APP_URL=https://your-api-service.railway.app

# Database (from Railway MySQL service)
DB_CONNECTION=mysql
DB_HOST=monorail.proxy.rlwy.net
DB_PORT=12345
DB_DATABASE=railway
DB_USERNAME=root
DB_PASSWORD=your-mysql-password

# CORS
FRONTEND_URL=https://your-ui-service.railway.app

# Logging
LOG_CHANNEL=stack
LOG_LEVEL=error
```

### UI Service Environment Variables:
```env
NODE_ENV=production
API_URL=https://your-api-service.railway.app
```

## 🔗 Expected URLs After Deployment
- **API**: `https://your-api-service.railway.app`
- **UI**: `https://your-ui-service.railway.app`
- **API Docs**: `https://your-api-service.railway.app/api/documentation`
- **Health Check**: `https://your-api-service.railway.app/health`

## 🐛 Troubleshooting Fixed Issues

### ✅ Issues Resolved:
1. **Missing deploy-check.sh**: Now created with proper health checks
2. **Duplicate nixpacks.toml content**: Fixed and streamlined  
3. **Node version inconsistency**: All configs now use Node 20
4. **Build script confusion**: Simplified to use standard `npm run build`

### Common Issues & Solutions:

#### API Build Fails:
- ✅ Check `deploy-check.sh` is executable
- ✅ Verify composer.json PHP version (^8.1)
- ✅ Ensure all environment variables are set

#### UI Build Fails:
- ✅ Verify Node 20 is used consistently
- ✅ Check npm dependencies install with `--legacy-peer-deps`
- ✅ Ensure `dist/toolshop` directory is created

#### Database Connection Issues:
- ✅ Copy exact credentials from Railway MySQL service
- ✅ Verify DB_HOST format: `monorail.proxy.rlwy.net`
- ✅ Check Railway logs for connection errors

## 🎯 Post-Deployment Verification

1. **API Health Check**: Visit `https://your-api.railway.app/health`
2. **API Documentation**: Visit `https://your-api.railway.app/api/documentation`
3. **UI Loading**: Visit `https://your-ui.railway.app`
4. **Cross-origin Communication**: Test API calls from UI

## 📝 Notes
- Deploy API first, then UI (UI needs API URL)
- Database migrations run automatically on first API startup
- CORS is pre-configured for Railway domains
- All build configurations are now consistent and tested
