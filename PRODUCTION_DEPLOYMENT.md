# 🚀 AGENDEMAIS - Production Deployment Guide

## 📋 **Pre-Deployment Checklist**

### ✅ **AWS Services Setup**
- [ ] AWS Cognito User Pool configured
- [ ] AWS Cognito Identity Pool configured  
- [ ] AWS Lambda functions deployed
- [ ] AWS API Gateway configured
- [ ] S3 bucket for file storage created
- [ ] CloudFront distribution (optional but recommended)

### ✅ **Environment Configuration**
- [ ] Environment variables configured
- [ ] SSL certificates installed
- [ ] Domain name configured
- [ ] CORS headers properly set

### ✅ **Code Review**
- [ ] All mock data removed
- [ ] Authentication properly implemented
- [ ] API endpoints tested
- [ ] Error handling implemented
- [ ] Performance optimizations applied

## 🔧 **Environment Variables**

Create these environment variables for production:

```bash
# AWS Configuration
export AWS_API_ENDPOINT="https://your-api-id.execute-api.region.amazonaws.com/prod"
export AWS_REGION="us-east-1"

# Cognito Configuration
export COGNITO_USER_POOL_ID="us-east-1_YourPoolId"
export COGNITO_APP_CLIENT_ID="your-app-client-id"
export COGNITO_IDENTITY_POOL_ID="us-east-1:your-identity-pool-id"

# S3 Configuration
export S3_BUCKET_NAME="your-bucket-name"
```

## 🏗️ **Build Process**

### 1. **Run Production Build**
```bash
# Make the build script executable
chmod +x build_production.sh

# Run the production build
./build_production.sh
```

### 2. **Manual Build (Alternative)**
```bash
flutter clean
flutter pub get
flutter build web --release --tree-shake-icons \
  --dart-define=AWS_API_ENDPOINT=https://your-api.amazonaws.com/prod \
  --dart-define=AWS_REGION=us-east-1 \
  --dart-define=COGNITO_USER_POOL_ID=us-east-1_YourPoolId \
  --dart-define=COGNITO_APP_CLIENT_ID=your-client-id \
  --dart-define=COGNITO_IDENTITY_POOL_ID=us-east-1:your-identity-pool \
  --dart-define=S3_BUCKET_NAME=your-bucket
```

## 🌐 **Web Server Configuration**

### **Apache (.htaccess)**
The `.htaccess` file is already configured with:
- Compression enabled
- Caching headers
- Security headers  
- PWA asset access
- Flutter routing support

### **Nginx Configuration**
```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    # SSL Configuration
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    # Security Headers
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    
    # PWA Assets - Always accessible
    location ~ ^/(manifest\.json|favicon\.ico|icons/|sw\.js|flutter\.js|flutter_bootstrap\.js)$ {
        root /var/www/agendemais;
        add_header Access-Control-Allow-Origin "*";
        add_header Cache-Control "public, max-age=31536000";
    }
    
    # Static Assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        root /var/www/agendemais;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Flutter Routes
    location / {
        root /var/www/agendemais;
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-cache";
    }
    
    # Compression
    gzip on;
    gzip_types text/plain text/css application/javascript application/json;
}
```

## 🔐 **Security Configuration**

### **HTTPS Setup**
```bash
# Using Let's Encrypt (recommended)
sudo certbot --apache -d yourdomain.com

# Or upload your SSL certificate to your hosting provider
```

### **CORS Configuration**
Ensure your AWS API Gateway has proper CORS configured:
```json
{
  "Access-Control-Allow-Origin": "https://yourdomain.com",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Requested-With"
}
```

## 📱 **PWA Configuration**

### **Service Worker Registration**
Verify service worker is properly registered in production:
```javascript
// Check in browser DevTools -> Application -> Service Workers
// Should show: agendemais-production-v[timestamp]
```

### **PWA Install Verification**
1. Open site in Chrome/Edge
2. Check for install prompt
3. Test offline functionality
4. Verify push notifications (if implemented)

## 🚀 **Deployment Options**

### **Option 1: AWS S3 + CloudFront**
```bash
# Upload to S3
aws s3 sync build/web/ s3://your-bucket-name --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"
```

### **Option 2: Traditional Web Hosting**
```bash
# Upload via FTP/SFTP
scp -r build/web/* user@yourserver:/var/www/agendemais/

# Or use hosting provider's file manager
```

### **Option 3: Google App Engine**
```bash
# Deploy using app.yaml (already configured)
gcloud app deploy build/web/app.yaml
```

## 📊 **Performance Monitoring**

### **Core Web Vitals Setup**
```html
<!-- Add to index.html head section -->
<script>
  // Web Vitals tracking
  import {getCLS, getFID, getFCP, getLCP, getTTFB} from 'web-vitals';

  getCLS(console.log);
  getFID(console.log);
  getFCP(console.log);
  getLCP(console.log);
  getTTFB(console.log);
</script>
```

### **Performance Targets**
- **LCP (Largest Contentful Paint)**: < 2.5s
- **FID (First Input Delay)**: < 100ms
- **CLS (Cumulative Layout Shift)**: < 0.1
- **Bundle Size**: < 3MB (initial load)

## 🧪 **Production Testing**

### **Pre-Launch Tests**
```bash
# 1. Performance Test
lighthouse https://yourdomain.com --output=json

# 2. Security Test
nmap -sV yourdomain.com

# 3. Load Test (using artillery or similar)
artillery quick --count 100 --num 5 https://yourdomain.com

# 4. PWA Test
# Install as PWA and test offline functionality
```

### **User Acceptance Testing**
- [ ] User registration flow
- [ ] Login/logout functionality  
- [ ] Dashboard data loading
- [ ] Appointment creation/management
- [ ] PIX payment generation
- [ ] Reports functionality
- [ ] Settings management
- [ ] Mobile responsiveness
- [ ] PWA installation
- [ ] Offline functionality

## 🔄 **Post-Deployment**

### **Monitoring Setup**
1. **Error Tracking**: Setup Sentry or similar
2. **Analytics**: Google Analytics 4
3. **Uptime Monitoring**: UptimeRobot or Pingdom
4. **Performance**: Google PageSpeed Insights

### **Backup Strategy**
```bash
# Automated backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
tar -czf "backup_${DATE}.tar.gz" /var/www/agendemais
aws s3 cp "backup_${DATE}.tar.gz" s3://your-backup-bucket/
```

## 🆘 **Troubleshooting**

### **Common Issues**

**1. Manifest.json 401 Error**
- ✅ Fixed: Public access configured in .htaccess
- Verify: `curl -I https://yourdomain.com/manifest.json`

**2. Service Worker Not Loading**
- Check: Network tab in DevTools
- Verify: HTTPS is enabled
- Clear: Browser cache and reload

**3. Authentication Issues**
- Verify: Cognito configuration
- Check: API Gateway CORS settings
- Test: JWT token validity

**4. Bundle Size Issues**
- Run: `flutter build web --analyze-size`
- Optimize: Remove unused dependencies
- Enable: Tree shaking

## 📞 **Support & Maintenance**

### **Regular Maintenance Tasks**
- [ ] Weekly: Monitor performance metrics
- [ ] Monthly: Update dependencies
- [ ] Quarterly: Security audit
- [ ] Annually: Review infrastructure costs

### **Emergency Contacts**
- AWS Support: [Your AWS Support Plan]
- Domain Provider: [Your Domain Provider]
- SSL Certificate Provider: [Your SSL Provider]
- Hosting Provider: [Your Hosting Provider]

---

## ✅ **Production Readiness Verification**

Before going live, verify all these items:

- [ ] ✅ All mock data removed
- [ ] ✅ Real AWS services configured
- [ ] ✅ Authentication working
- [ ] ✅ HTTPS enabled
- [ ] ✅ PWA installable
- [ ] ✅ Offline functionality working
- [ ] ✅ Performance optimized
- [ ] ✅ Security headers configured
- [ ] ✅ Error handling implemented
- [ ] ✅ Monitoring setup
- [ ] ✅ Backup strategy in place

## 🎉 **Go Live!**

Once all checks pass:
1. Point your domain to the production server
2. Update DNS records
3. Test from multiple locations
4. Monitor for the first 24 hours
5. Celebrate! 🚀

---

**© 2024 AGENDEMAIS - Production Ready SaaS Platform**