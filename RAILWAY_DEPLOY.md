# Railway Deployment Guide for Sprint5-with-bugs

## Lỗi Build và Cách Khắc Phục

Railway đang cố gắng build từ root directory. Để fix lỗi này, bạn cần deploy từng service riêng biệt.

## Cách Deploy Đúng

### Phương pháp 1: Deploy từng service riêng biệt (Khuyến nghị)

#### Bước 1: Deploy API Service
1. Trên Railway dashboard, tạo "New Project"
2. Chọn "Deploy from GitHub repo" 
3. Chọn repository của bạn
4. Trong **Root Directory**, nhập: `sprint5-with-bugs/API`
5. Railway sẽ detect Laravel và build đúng

#### Bước 2: Deploy UI Service  
1. Tạo service mới trong cùng project
2. Chọn "Deploy from GitHub repo"
3. Chọn cùng repository
4. Trong **Root Directory**, nhập: `sprint5-with-bugs/UI`
5. Railway sẽ detect Angular và build đúng

#### Bước 3: Thêm Database
1. Trong project, click "New Service"
2. Chọn "Database" → "MySQL"
3. Lưu lại connection details

### Phương pháp 2: Sử dụng Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Deploy API
cd sprint5-with-bugs/API
railway up

# Deploy UI (trong terminal mới)
cd sprint5-with-bugs/UI  
railway up
```

## Cấu hình Environment Variables

### Cho API Service:
```
APP_NAME=ToolShop-API
APP_ENV=production
APP_KEY=base64:YOUR_APP_KEY_HERE (generate bằng: php artisan key:generate --show)
APP_DEBUG=false
APP_URL=https://your-api-domain.railway.app

DB_CONNECTION=mysql
DB_HOST=monorail.proxy.rlwy.net (từ Railway MySQL)
DB_PORT=12345 (từ Railway MySQL)
DB_DATABASE=railway
DB_USERNAME=root  
DB_PASSWORD=your-mysql-password (từ Railway MySQL)

LOG_CHANNEL=stack
LOG_LEVEL=error

# CORS Settings để UI có thể connect
FRONTEND_URL=https://your-ui-domain.railway.app
```

### Cho UI Service:
```
NODE_ENV=production
API_URL=https://your-api-domain.railway.app
```

## Cấu hình CORS trong Laravel

Cập nhật file `config/cors.php` trong API:

```php
'allowed_origins' => [
    'https://your-ui-domain.railway.app',
    'http://localhost:4200', // for local development
],
```

## URLs sau khi deploy
- API: `https://your-api-service.railway.app`
- UI: `https://your-ui-service.railway.app`  
- API Docs: `https://your-api-service.railway.app/api/documentation`

## Troubleshooting Build Issues

### Nếu API build fail:
1. Đảm bảo có file `composer.json` trong `sprint5-with-bugs/API`
2. Check PHP version trong `composer.json` (should be ^8.1)
3. Xem logs để debug dependency issues

### Nếu UI build fail:
1. Đảm bảo có file `package.json` trong `sprint5-with-bugs/UI`
2. Check Node version (Railway supports Node 18+)
3. Đảm bảo build script hoạt động: `npm run build`

### Database connection issues:
1. Copy chính xác database credentials từ Railway
2. Đảm bảo `DB_HOST` và `DB_PORT` đúng format từ Railway
3. Test connection trong Railway logs

## Lưu ý quan trọng

1. **Root Directory**: Phải set đúng path khi deploy từ GitHub
2. **Environment Variables**: Cấu hình đầy đủ trước khi deploy
3. **Domain Configuration**: API và UI cần biết domain của nhau
4. **Database Migration**: Sẽ tự động chạy khi API service start lần đầu

## Cấu trúc sau khi deploy thành công:
```
Railway Project
├── API Service (sprint5-with-bugs/API)
├── UI Service (sprint5-with-bugs/UI)  
└── MySQL Database
```
