# OLAP Web Interface - Deployment Guide

## 📋 Prerequisites

- Node.js 14+ 
- npm 6+
- SSAS Server (SQL Server Analysis Services) installed and running
- Administrator privileges (for some operations)

## 🚀 Local Development Setup

### Step 1: Clone or Download the Project
```bash
cd C:\olap_web
```

### Step 2: Install Dependencies

#### Backend
```bash
npm install
```

#### Frontend
```bash
cd client
npm install
cd ..
```

### Step 3: Configure SSAS Connection

Edit `config/ssas.config.js` and update:
```javascript
server: {
  host: 'your-ssas-server',
  port: 2383,
  protocol: 'http',
  path: '/olap/msmdpump.dll'
},
database: 'your-database-name'
```

### Step 4: Run Development Servers

**Option A: Using batch file (Windows)**
```bash
start.bat
```

**Option B: Manual start**

Terminal 1 (Backend):
```bash
npm start
```

Terminal 2 (Frontend):
```bash
cd client
npm start
```

Backend will run on: `http://localhost:5000`
Frontend will run on: `http://localhost:3000`

## 📦 Production Deployment

### Build Frontend
```bash
cd client
npm run build
cd ..
```

### Setup for Production

1. **Copy backend files:**
```bash
mkdir production
cp server.js production/
cp config/ production/
cp lib/ production/
cp package.json production/
cp package-lock.json production/
```

2. **Install production dependencies:**
```bash
cd production
npm install --only=production
```

3. **Create .env file:**
```
NODE_ENV=production
PORT=5000
SSAS_HOST=your-ssas-server
SSAS_PORT=2383
SSAS_DATABASE=your-database
```

4. **Serve frontend with Express:**

Edit `server.js` and add:
```javascript
const path = require('path');
const express = require('express');

app.use(express.static(path.join(__dirname, '../client/build')));

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../client/build', 'index.html'));
});
```

5. **Start production server:**
```bash
NODE_ENV=production npm start
```

## 🐳 Docker Deployment

### Create Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy backend
COPY package*.json ./
RUN npm install --only=production

# Copy frontend build
COPY client/build ./public

COPY server.js .
COPY config/ ./config/
COPY lib/ ./lib/

EXPOSE 5000

CMD ["npm", "start"]
```

### Build and run Docker image

```bash
docker build -t olap-web .
docker run -p 5000:5000 -e SSAS_HOST=your-ssas-server olap-web
```

## ☁️ Azure/Cloud Deployment

### Using Azure App Service

1. **Prepare files:**
```bash
# Create deployment package
mkdir azure-deploy
cp -r . azure-deploy/
cd azure-deploy
```

2. **Configure web.config for IIS:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <system.webServer>
    <handlers>
      <add name="iisnode" path="server.js" verb="*" modules="iisnode" />
    </handlers>
    <rewrite>
      <rules>
        <rule name="sendToNode">
          <match url="/*" />
          <action type="Rewrite" url="server.js" />
        </rule>
      </rules>
    </rewrite>
  </system.webServer>
</configuration>
```

3. **Deploy using Azure CLI:**
```bash
az webapp up --name my-olap-web --resource-group my-group
```

## 🔒 Security Considerations

1. **HTTPS**: Always use HTTPS in production
```javascript
const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('cert.pem')
};

https.createServer(options, app).listen(5000);
```

2. **CORS**: Configure CORS properly
```javascript
app.use(cors({
  origin: ['https://yourdomain.com'],
  credentials: true
}));
```

3. **Authentication**: Implement auth middleware
```javascript
const authenticateToken = (req, res, next) => {
  const token = req.headers['authorization'];
  // Verify token
  next();
};

app.post('/api/query', authenticateToken, (req, res) => {
  // Handle query
});
```

4. **Rate Limiting**: Add rate limiting
```bash
npm install express-rate-limit
```

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});

app.use('/api/', limiter);
```

## 📊 Monitoring

### Add logging
```bash
npm install winston
```

### Monitor performance
- Use tools like New Relic, DataDog, or Application Insights
- Monitor SSAS query performance
- Track API response times

## 🐛 Troubleshooting

### SSAS Connection Issues
- Verify SSAS is running: `telnet localhost 2383`
- Check firewall rules
- Verify credentials in config

### Port already in use
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Linux/Mac
lsof -i :5000
kill <PID>
```

### Build issues
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
```

## 📞 Support

For issues and questions:
1. Check README.md
2. Review logs in console
3. Check network tab in browser DevTools
4. Verify SSAS connectivity

## ✅ Deployment Checklist

- [ ] Node.js installed (14+)
- [ ] Dependencies installed
- [ ] SSAS connection configured
- [ ] Environment variables set
- [ ] Frontend built (`npm run build`)
- [ ] Ports available (5000, 3000)
- [ ] HTTPS configured (production)
- [ ] Authentication implemented
- [ ] Rate limiting configured
- [ ] Logging enabled
- [ ] Monitoring setup
- [ ] Backup configured
- [ ] Documentation updated

---

Last updated: 2024
