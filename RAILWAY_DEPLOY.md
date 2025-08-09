# Railway Deployment Guide for Sprint5-with-bugs

## Chuẩn bị deploy lên Railway

### 1. Tạo tài khoản Railway
- Truy cập [railway.app](https://railway.app)
- Đăng ký/đăng nhập bằng GitHub account

### 2. Chuẩn bị repository
- Push code lên GitHub repository
- Đảm bảo có các file: `railway.toml`, `Dockerfile`, `Procfile` đã được tạo

### 3. Deploy bằng Railway

#### Cách 1: Deploy từ GitHub (Khuyến nghị)
1. Trên Railway dashboard, click "New Project"
2. Chọn "Deploy from GitHub repo"
3. Chọn repository chứa project
4. Railway sẽ tự động detect và deploy

#### Cách 2: Deploy bằng Railway CLI
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Deploy
railway up
```

### 4. Cấu hình Environment Variables

#### Cho API Service:
```
APP_NAME=ToolShop-API
APP_ENV=production
APP_KEY=base64:YOUR_APP_KEY_HERE
APP_DEBUG=false
APP_URL=https://your-api-domain.railway.app

DB_CONNECTION=mysql
DB_HOST=railway-mysql-host
DB_PORT=3306
DB_DATABASE=railway
DB_USERNAME=root
DB_PASSWORD=railway-mysql-password

LOG_CHANNEL=stack
LOG_LEVEL=error

MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=your-username
MAIL_PASSWORD=your-password
```

#### Cho UI Service:
```
NODE_ENV=production
API_URL=https://your-api-domain.railway.app
```

### 5. Thêm MySQL Database
1. Trong Railway project, click "New Service"
2. Chọn "Database" → "MySQL"
3. Railway sẽ tạo MySQL instance và cung cấp connection details

### 6. Connect Services
- Đảm bảo UI service có thể connect tới API service
- Cấu hình CORS trong Laravel API để accept requests từ UI domain

### 7. Custom Domains (Optional)
- Trong service settings, có thể add custom domain
- Hoặc sử dụng domain mặc định của Railway

## Lưu ý quan trọng

1. **Database Migration**: API service sẽ tự động chạy migrations khi deploy
2. **Environment Variables**: Phải cấu hình đầy đủ trước khi deploy
3. **File Storage**: Railway có ephemeral file system, cân nhắc sử dụng cloud storage cho files
4. **Logs**: Có thể xem logs trực tiếp trên Railway dashboard

## Troubleshooting

### Build fails:
- Kiểm tra Dockerfile và dependencies
- Xem logs để debug

### Database connection fails:
- Verify database environment variables
- Đảm bảo database service đã được tạo

### CORS errors:
- Cấu hình CORS trong Laravel config/cors.php
- Thêm domain của UI vào allowed origins

## URL sau khi deploy
- API: `https://your-api-service.railway.app`
- UI: `https://your-ui-service.railway.app`
- Database: Accessible internally trong Railway network
