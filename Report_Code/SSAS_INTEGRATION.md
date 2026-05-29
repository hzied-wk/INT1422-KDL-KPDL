# SSAS Integration Guide

Hướng dẫn chi tiết để tích hợp OLAP Web Interface với SSAS thực tế.

## 📋 Các Bước Tích Hợp

### Step 1: Cài đặt SSAS Package

```bash
npm install msadomd
# hoặc
npm install xmla-js
# hoặc 
npm install essbase
```

**Các package tùy chọn:**
- **msadomd** - Chính thức từ Microsoft
- **xmla-js** - Library XMLA mở
- **essbase** - Cho Oracle Essbase

### Step 2: Cập nhật File Config

Chỉnh sửa `config/ssas.config.js`:

```javascript
module.exports = {
  server: {
    host: 'your-ssas-server.com',      // SSAS server IP/hostname
    port: 2383,                         // SSAS port
    protocol: 'http',                   // http or https
    path: '/olap/msmdpump.dll'          // XMLA endpoint
  },

  database: 'your-database-name',       // Database name

  auth: {
    mode: 'windows',                    // 'windows' hoặc 'basic'
    username: 'domain\\username',       // Cho basic auth
    password: 'password'                // Cho basic auth
  },

  cubes: {
    // Define your actual cubes
    your_cube_name: {
      name: 'your_cube_name',
      description: 'Your Cube Description',
      // ... dimensions và measures
    }
  }
};
```

### Step 3: Implement Real SSAS Connection

Chỉnh sửa `lib/ssasConnector.js`:

#### Cách 1: Sử dụng msadomd (Microsoft Official)

```javascript
const msadomd = require('msadomd');
const ssasConfig = require('../config/ssas.config');

class SSASConnector {
  constructor() {
    this.connection = null;
    this.isConnected = false;
  }

  async connect() {
    try {
      const connectionString = `
        Provider=MSOLAP;
        Data Source=${ssasConfig.server.host}:${ssasConfig.server.port};
        Initial Catalog=${ssasConfig.database};
        User ID=${ssasConfig.auth.username};
        Password=${ssasConfig.auth.password};
      `.trim();

      this.connection = new msadomd.Connection({
        connectionString: connectionString
      });

      await this.connection.open();
      this.isConnected = true;
      console.log('✓ Connected to SSAS');
      return true;

    } catch (error) {
      console.error('✗ SSAS Connection Error:', error);
      return false;
    }
  }

  async executeQuery(mdxQuery) {
    try {
      if (!this.isConnected) {
        throw new Error('Not connected to SSAS');
      }

      const recordset = await this.connection.execute(mdxQuery);
      return this.formatRecordset(recordset);

    } catch (error) {
      console.error('✗ Query Error:', error);
      throw error;
    }
  }

  formatRecordset(recordset) {
    const result = {
      columns: [],
      rows: []
    };

    // Extract columns
    for (let i = 0; i < recordset.fields.length; i++) {
      result.columns.push(recordset.fields[i].name);
    }

    // Extract rows
    while (!recordset.eof) {
      const row = [];
      for (let i = 0; i < recordset.fields.length; i++) {
        row.push(recordset.fields[i].value);
      }
      result.rows.push(row);
      recordset.moveNext();
    }

    recordset.close();
    return result;
  }

  async disconnect() {
    try {
      if (this.connection && this.isConnected) {
        await this.connection.close();
        this.isConnected = false;
        console.log('✓ Disconnected from SSAS');
      }
    } catch (error) {
      console.error('✗ Disconnect Error:', error);
    }
  }
}

module.exports = SSASConnector;
```

#### Cách 2: Sử dụng XMLA HTTP (Không cần COM objects)

```javascript
const axios = require('axios');
const ssasConfig = require('../config/ssas.config');

class SSASConnector {
  constructor() {
    this.sessionId = null;
    this.baseURL = `http://${ssasConfig.server.host}:${ssasConfig.server.port}/olap/msmdpump.dll`;
  }

  async connect() {
    try {
      // XMLA connection không cần explicit connect
      // Nhưng có thể test kết nối
      const response = await this.executeXMLARequest(
        this.buildDiscoverRequest('DBPROPLIST')
      );

      console.log('✓ Connected to SSAS via XMLA');
      return true;

    } catch (error) {
      console.error('✗ SSAS Connection Error:', error);
      return false;
    }
  }

  buildDiscoverRequest(requestType) {
    return `<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <Discover xmlns="urn:schemas-microsoft-com:xml-analysis">
            <RequestType>${requestType}</RequestType>
            <Restrictions/>
            <Properties/>
          </Discover>
        </soap:Body>
      </soap:Envelope>`;
  }

  buildMDXRequest(mdxQuery, cube, database) {
    return `<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <Execute xmlns="urn:schemas-microsoft-com:xml-analysis">
            <Command>
              <Statement>${this.escapeXML(mdxQuery)}</Statement>
            </Command>
            <Properties>
              <PropertyList>
                <DataSourceInfo>${database}</DataSourceInfo>
                <Catalog>${database}</Catalog>
                <Format>Tabular</Format>
                <AxisFormat>ClusterFormat</AxisFormat>
              </PropertyList>
            </Properties>
          </Execute>
        </soap:Body>
      </soap:Envelope>`;
  }

  escapeXML(str) {
    return str
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&apos;');
  }

  async executeXMLARequest(soapRequest) {
    try {
      const response = await axios.post(this.baseURL, soapRequest, {
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'Authorization': `Basic ${Buffer.from(
            `${ssasConfig.auth.username}:${ssasConfig.auth.password}`
          ).toString('base64')}`
        }
      });

      return response.data;

    } catch (error) {
      console.error('✗ XMLA Request Error:', error);
      throw error;
    }
  }

  async executeQuery(mdxQuery) {
    try {
      const xmlaRequest = this.buildMDXRequest(
        mdxQuery,
        ssasConfig.database,
        ssasConfig.database
      );

      const response = await this.executeXMLARequest(xmlaRequest);
      return this.parseXMLAResponse(response);

    } catch (error) {
      console.error('✗ Query Error:', error);
      throw error;
    }
  }

  parseXMLAResponse(xmlResponse) {
    // Parse XML response và convert thành JSON
    // Cần sử dụng xml2js hoặc tương tự
    const result = {
      columns: [],
      rows: []
    };

    // Implementation tùy vào response format
    // Đây là placeholder
    return result;
  }

  async disconnect() {
    console.log('✓ XMLA Connection closed');
  }
}

module.exports = SSASConnector;
```

### Step 4: Cập nhật Backend API

Chỉnh sửa `server.js`:

```javascript
const express = require('express');
const cors = require('cors');
const SSASConnector = require('./lib/ssasConnector');

const app = express();
const port = 5000;

app.use(cors());
app.use(express.json());

// Initialize SSAS connector
const ssasConnector = new SSASConnector();

// Connect to SSAS on startup
ssasConnector.connect().then(() => {
  console.log('SSAS Connection established');
}).catch((err) => {
  console.error('Failed to connect to SSAS:', err);
});

// Query endpoint - Modified to use real SSAS
app.post('/api/query', async (req, res) => {
  try {
    const { mdxQuery, cube } = req.body;

    // Execute real MDX query
    const result = await ssasConnector.executeQuery(mdxQuery);

    res.json(result);

  } catch (error) {
    res.status(500).json({ 
      error: error.message,
      details: error.toString()
    });
  }
});

// Drill Down - Modified to build real MDX
app.post('/api/operations/drill-down', async (req, res) => {
  try {
    const { dimension, currentLevel, cube } = req.body;

    // Build MDX query for drill down
    const mdxQuery = `
      SELECT NON EMPTY [Measures].[Amount] ON 0,
      NON EMPTY [${dimension}].Level(${currentLevel + 1}).Members ON 1
      FROM [${cube}]
    `;

    const result = await ssasConnector.executeQuery(mdxQuery);

    res.json({
      operation: 'drill-down',
      nextLevel: currentLevel + 1,
      ...result
    });

  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Similar updates for roll-up, slice-dice, pivot...

app.listen(port, () => {
  console.log(`OLAP Server running at http://localhost:${port}`);
});
```

### Step 5: Xây dựng MDX Queries Chính Xác

#### Drill Down Query
```mdx
SELECT NON EMPTY [Measures].[Amount] ON 0,
NON EMPTY [DIM_MATHANG].[Category].Members ON 1
FROM [sales_cube]
```

#### Roll Up Query
```mdx
SELECT NON EMPTY [Measures].[Amount] ON 0,
NON EMPTY [DIM_MATHANG].Members ON 1
FROM [sales_cube]
```

#### Slice & Dice Query
```mdx
SELECT NON EMPTY [Measures].[Amount] ON 0,
NON EMPTY [DIM_MATHANG].Members ON 1
FROM [sales_cube]
WHERE ([DIM_THOIGIAN].[2024], [DIM_KHACHHANG].[North])
```

#### Pivot Query
```mdx
SELECT NON EMPTY [DIM_MATHANG].Members ON 0,
NON EMPTY [DIM_THOIGIAN].[Year].Members ON 1
FROM [sales_cube]
WHERE [Measures].[Amount]
```

---

## 🔐 Security Best Practices

### 1. Connection String Security
```javascript
// ✗ KHÔNG tốt - Credentials trong code
const connectionString = `...User ID=admin;Password=123456`;

// ✓ TỐT - Từ environment variables
const connectionString = `
  ...User ID=${process.env.SSAS_USER};
  Password=${process.env.SSAS_PASSWORD}
`;
```

### 2. Environment Variables (.env)
```
SSAS_HOST=your-ssas-server.com
SSAS_PORT=2383
SSAS_DATABASE=your_database
SSAS_USER=domain\username
SSAS_PASSWORD=your_password
NODE_ENV=production
```

### 3. Authentication
```javascript
// Windows Authentication
auth: {
  mode: 'windows',
  // Use current user or service account
}

// Basic Authentication
auth: {
  mode: 'basic',
  username: process.env.SSAS_USER,
  password: process.env.SSAS_PASSWORD
}

// HTTPS for production
const https = require('https');
const fs = require('fs');

https.createServer({
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('cert.pem')
}, app).listen(443);
```

### 4. Rate Limiting
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 100  // limit each IP to 100 requests per windowMs
});

app.use('/api/', limiter);
```

---

## 🧪 Testing SSAS Connection

### Test Script
```javascript
// test-ssas.js
const SSASConnector = require('./lib/ssasConnector');

async function testConnection() {
  const connector = new SSASConnector();

  try {
    const connected = await connector.connect();

    if (connected) {
      console.log('✓ Connected to SSAS');

      // Test simple query
      const result = await connector.executeQuery(
        'SELECT [Measures].Members ON 0 FROM [sales_cube]'
      );

      console.log('✓ Query executed successfully');
      console.log('Result:', result);

    } else {
      console.log('✗ Connection failed');
    }

  } catch (error) {
    console.error('✗ Error:', error);
  } finally {
    await connector.disconnect();
  }
}

testConnection();
```

Run test:
```bash
node test-ssas.js
```

---

## 📊 Troubleshooting

### Problem: Connection Timeout
**Solution:**
- Verify SSAS server is running
- Check firewall rules
- Test connectivity: `telnet ssas-host 2383`

### Problem: Authentication Failed
**Solution:**
- Verify username/password
- Check Windows domain format: `domain\username`
- Ensure service account has SSAS permissions

### Problem: Invalid Cube/Database
**Solution:**
- List available cubes: Use SSMS (SQL Server Management Studio)
- Verify cube name matches exactly
- Check database name

### Problem: MDX Query Syntax Error
**Solution:**
- Test queries in SSMS
- Check dimension/measure names
- Verify hierarchy levels

### Problem: XMLA Response Parse Error
**Solution:**
- Install xml2js: `npm install xml2js`
- Implement proper XML parsing
- Check SOAP response format

---

## 📚 Resources

- [Microsoft SSAS Documentation](https://docs.microsoft.com/en-us/analysis-services/)
- [XMLA Protocol Reference](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-ssas/)
- [MDX Language Reference](https://docs.microsoft.com/en-us/sql/mdx/mdx-language-reference/)
- [MDX Tutorial](https://www.tutorialspoint.com/mdx/)

---

## ✅ Verification Checklist

- [ ] SSAS server hostname/IP verified
- [ ] SSAS port is accessible (default 2383)
- [ ] Database name is correct
- [ ] Cube names match SSAS
- [ ] Authentication credentials work
- [ ] SSAS package installed (msadomd or xmla-js)
- [ ] Connection string format verified
- [ ] MDX queries tested in SSMS
- [ ] Environment variables set
- [ ] Security policies configured
- [ ] Rate limiting configured
- [ ] Error handling implemented
- [ ] Logging configured
- [ ] Test script passes

---

Last Updated: 2024-05-04
