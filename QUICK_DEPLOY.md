# Quick Railway Deploy Guide

## ⚡ Fast Deploy Steps

### 1. Deploy API Service First
1. Go to [Railway](https://railway.app) → New Project
2. "Deploy from GitHub repo" → Select your repo
3. **Important**: Set Root Directory to: `sprint5-with-bugs/API`
4. Add MySQL database to project
5. Set environment variables (see below)

### 2. Deploy UI Service
1. In same project → New Service  
2. "Deploy from GitHub repo" → Same repo
3. **Important**: Set Root Directory to: `sprint5-with-bugs/UI`
4. Set UI environment variables

### 3. Required Environment Variables

**API Service:**
```
APP_KEY=base64:your-key-here
APP_URL=https://your-api.railway.app
DB_HOST=your-mysql-host
DB_PORT=your-mysql-port  
DB_PASSWORD=your-mysql-password
```

**UI Service:**
```
API_URL=https://your-api.railway.app
```

### 4. Get Database Credentials
- In Railway MySQL service → Variables tab
- Copy HOST, PORT, PASSWORD values

### 5. Test Deployment
- API: `https://your-api.railway.app/status`
- UI: `https://your-ui.railway.app`
- Swagger: `https://your-api.railway.app/api/documentation`

---

**❌ Common Issues:**

1. **"Nixpacks build failed"** → Make sure you set the correct Root Directory for each service!

2. **"npm ERESOLVE dependency conflict"** → Fixed! The build now uses `--legacy-peer-deps` to handle Angular version conflicts.

3. **"Node.js version v18.x detected. Angular CLI requires minimum v20.19"** → Fixed! Now using Node.js 20.

4. **"Database connection refused"** → Wait a few minutes after first deploy for database to initialize.

**✅ Success:** Both services should be running independently with shared database.
