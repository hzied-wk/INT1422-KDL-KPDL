try { require('dotenv').config(); } catch (e) { } // Load .env file nếu đã cài thư viện dotenv
const express = require('express');
const cors = require('cors');
const path = require('path');
const oracledb = require('oracledb');

const app = express();
const env = process.env.NODE_ENV || 'development';
const config = require('./config/environment')[env];
const port = process.env.PORT || config.port || 5000;

// Middleware
app.use(cors(config.cors));
app.use(express.json());

// Security headers (relax for development)
app.use((req, res, next) => {
  res.setHeader('Content-Security-Policy', "default-src *; connect-src *;");
  next();
});

// Khởi tạo Oracle Connection Pool
async function initializeOraclePool() {
  try {
    oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;
    await oracledb.createPool({
      user: config.oracle.user,
      password: config.oracle.password,
      connectString: config.oracle.connectString,
      poolMin: config.oracle.poolMin,
      poolMax: config.oracle.poolMax,
      poolIncrement: config.oracle.poolIncrement
    });
    console.log('✅ Oracle Database connection pool created.');
  } catch (err) {
    console.error('❌ Error creating Oracle connection pool:', err.message);
  }
}
initializeOraclePool();

// Helper thực thi SQL an toàn
async function executeOlapQuery(sql, binds = {}) {
  let connection;
  try {
    connection = await oracledb.getConnection();
    // Giới hạn số lượng dòng trả về (ví dụ 1000 dòng) để tránh lỗi JavaScript heap out of memory (tràn RAM)
    const options = { maxRows: 1000 };
    const result = await connection.execute(sql, binds, options);
    return result;
  } catch (err) {
    console.error('Lỗi truy vấn Oracle:', err.message, '\\nSQL:', sql, '\\nBinds:', binds);
    throw err;
  } finally {
    if (connection) {
      try { await connection.close(); } catch (err) { console.error(err); }
    }
  }
}

// Dynamic SQL Builder
function buildOlapSql(cube, dimensions = [], measures = [], filters = [], operation = '') {
  // Xác định Fact table dựa vào tên cube truyền lên từ frontend
  const factTable = cube === 'inventory_cube' ? 'FACT_TON_KHO' : 'FACT_DOANH_SO';
  const getColName = (item) => typeof item === 'object' && item !== null ? item.column : item;
  
  const groupByCols = dimensions.map(getColName).filter(Boolean);
  const measureCols = measures.map(getColName).filter(Boolean);
  
  let selectClause = '';
  let groupByClause = '';
  
  const selectParts = [];
  if (groupByCols.length > 0) selectParts.push(...groupByCols);
  if (measureCols.length > 0) selectParts.push(...measureCols.map(m => `SUM(${m}) AS ${m}`));
  selectClause = selectParts.length > 0 ? selectParts.join(', ') : '*';
  
  if (groupByCols.length > 0) {
    if (operation === 'roll-up' && groupByCols.length > 1) {
      groupByClause = `GROUP BY ROLLUP(${groupByCols.join(', ')})`;
    } else {
      groupByClause = `GROUP BY ${groupByCols.join(', ')}`;
    }
  }

  const whereConditions = [];
  const binds = {};
  if (Array.isArray(filters)) {
    filters.forEach((f, idx) => {
      const col = f.column || f.name;
      const val = f.value;
      if (col && val !== undefined) {
        const bindName = `filter_${idx}`;
        whereConditions.push(`${col} = :${bindName}`);
        binds[bindName] = val;
      }
    });
  }
  const whereClause = whereConditions.length > 0 ? `WHERE ${whereConditions.join(' AND ')}` : '';
  
  // Logic JOIN cho Star Schema (tự động link Fact với các bảng DIM)
  let fromClause = factTable;
  if (factTable === 'FACT_DOANH_SO') {
    fromClause = `FACT_DOANH_SO 
      LEFT JOIN DIM_KHACHHANG ON FACT_DOANH_SO.KHACHHANG_KEY = DIM_KHACHHANG.KHACHHANG_KEY 
      LEFT JOIN DIM_MATHANG ON FACT_DOANH_SO.MATHANG_KEY = DIM_MATHANG.MATHANG_KEY 
      LEFT JOIN DIM_THOIGIAN ON FACT_DOANH_SO.THOIGIAN_KEY = DIM_THOIGIAN.THOIGIAN_KEY`;
  } else if (factTable === 'FACT_TON_KHO') {
    fromClause = `FACT_TON_KHO 
      LEFT JOIN DIM_CUAHANG ON FACT_TON_KHO.CUAHANG_KEY = DIM_CUAHANG.CUAHANG_KEY 
      LEFT JOIN DIM_MATHANG ON FACT_TON_KHO.MATHANG_KEY = DIM_MATHANG.MATHANG_KEY 
      LEFT JOIN DIM_THOIGIAN ON FACT_TON_KHO.THOIGIAN_KEY = DIM_THOIGIAN.THOIGIAN_KEY`;
  }

  const sql = `SELECT ${selectClause} FROM ${fromClause} ${whereClause} ${groupByClause}`.trim();
  return { sql, binds };
}

// Health check route
app.get('/', (req, res) => {
  res.json({
    status: 'running',
    message: 'OLAP Web Interface API',
    version: '1.0.0',
    apiEndpoints: {
      cubes: 'GET /api/cubes',
      query: 'POST /api/query',
      drillDown: 'POST /api/operations/drill-down',
      rollUp: 'POST /api/operations/roll-up',
      sliceDice: 'POST /api/operations/slice-dice',
      pivot: 'POST /api/operations/pivot'
    }
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// --- API Endpoints cho OLAP (Oracle Dynamic SQL) ---

// Get dimensions (Meta-data)
app.post('/api/dimensions', async (req, res) => {
  try {
    const { cube } = req.body;
    // Tùy thuộc vào Oracle Schema, bạn có thể query `all_tab_columns`
    // Hoặc query 1 bảng metadata. Dưới đây là ví dụ tĩnh:
    res.json({
      dimensions: [
        { name: 'DIM_MATHANG', hierarchies: ['Category', 'Product'] },
        { name: 'DIM_THOIGIAN', hierarchies: ['Year', 'Quarter', 'Month'] },
        { name: 'DIM_KHACHHANG', hierarchies: ['Region', 'Customer'] }
      ]
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Helper format dữ liệu cho React frontend
function formatForReact(result, isPivot = false) {
  const columns = result.metaData ? result.metaData.map(m => m.name) : [];
  if (isPivot) {
    // React mong đợi pivot data là mảng object có chứa field 'label'
    const data = result.rows.map(r => {
      const obj = { label: 'Data Row' };
      columns.forEach(c => obj[c] = r[c]);
      return obj;
    });
    return { columns, rows: columns, measures: [], data: [data] };
  } else {
    // Dữ liệu bình thường mong đợi dạng array of arrays
    const rows = result.rows.map(r => columns.map(c => r[c]));
    return { columns, rows };
  }
}

// General OLAP Query (Fetch Data ban đầu)
app.post('/api/query', async (req, res) => {
  try {
    let { cube, rows = [], measures = [], filters = [], operation = 'query', mdxQuery } = req.body;

    // React (khi load lần đầu) gửi `mdxQuery` thay vì rows/measures
    if (mdxQuery && rows.length === 0) {
      rows = ['NAM', 'QUY'];
      measures = cube === 'inventory_cube' ? ['SOLUONGTON'] : ['TONGDOANHTHU'];
    }

    const { sql, binds } = buildOlapSql(cube, rows, measures, filters, operation);

    try {
      const result = await executeOlapQuery(sql, binds);
      res.json({ sqlGenerated: sql, ...formatForReact(result) });
    } catch (dbErr) {
      res.json({ mockWarning: dbErr.message, sqlGenerated: sql, columns: [], rows: [] });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Chuyển hướng và map dữ liệu cho các thao tác OLAP từ React
app.post('/api/operations/:type', async (req, res) => {
  try {
    const { type } = req.params;
    let { cube, dimension, currentLevel, filters: frontFilters, rows: pRows } = req.body;
    
    let rows = [];
    let measures = cube === 'inventory_cube' ? ['SOLUONGTON'] : ['TONGDOANHTHU'];
    let filters = [];

    // Map the selectedDimension từ React ('DIM_MATHANG', etc.) thành tên cột thực tế
    const mapDimToCol = (dim) => {
      if (dim === 'DIM_MATHANG') return 'NHOMSP';
      if (dim === 'DIM_THOIGIAN') return 'NAM';
      // Nếu đang ở inventory_cube (không có Khách Hàng), đổi thành lọc theo Cửa Hàng (TENCH) để không bị crash
      if (dim === 'DIM_KHACHHANG') return cube === 'inventory_cube' ? 'TENCH' : 'TENKH';
      return dim;
    };

    // Định nghĩa các cấu trúc phân cấp (Hierarchy) cho từng Dimension
    const getHierarchy = (dim, isInventory) => {
      if (dim === 'DIM_THOIGIAN') return ['NAM', 'QUY', 'THANG'];
      if (dim === 'DIM_MATHANG') return ['NHOMSP', 'MOTA'];
      if (dim === 'DIM_KHACHHANG') return isInventory ? ['TENCH', 'TENTP'] : ['TENKH', 'LOAIKH'];
      return [mapDimToCol(dim)];
    };

    if (type === 'drill-down') {
      const hierarchy = getHierarchy(dimension, cube === 'inventory_cube');
      const targetLevel = currentLevel + 1;
      // Cắt lấy số lượng cột tương ứng với level hiện tại (ví dụ level 1 lấy 2 cột NAM, QUY. Level 2 lấy 3 cột)
      rows = hierarchy.slice(0, Math.min(targetLevel + 1, hierarchy.length));
    } else if (type === 'roll-up') {
      const hierarchy = getHierarchy(dimension, cube === 'inventory_cube');
      const targetLevel = Math.max(0, currentLevel - 1);
      rows = hierarchy.slice(0, targetLevel + 1);
    } else if (type === 'slice' || type === 'dice') {
      // Khi lọc Slice/Dice, mặc định hiển thị cột theo các dimension đã filter
      rows = frontFilters ? Object.keys(frontFilters).map(mapDimToCol) : ['NAM'];
      if (type === 'dice') {
         // Dice thường đi kèm phân tích các nhóm nên ta thêm cột phụ
         if (!rows.includes('QUY')) rows.push('QUY');
      }
      if (frontFilters) {
        Object.keys(frontFilters).forEach(k => {
          if (frontFilters[k]) {
             filters.push({ column: mapDimToCol(k), value: frontFilters[k] });
          }
        });
      }
    } else if (type === 'pivot') {
      rows = pRows ? pRows.map(mapDimToCol) : ['NAM'];
      measures = cube === 'inventory_cube' ? ['SOLUONGTON', 'GIATRITON'] : ['TONGDOANHTHU', 'TONGSOLUONG'];
    }

    const operation = type === 'roll-up' ? 'roll-up' : 'query';
    const { sql, binds } = buildOlapSql(cube, rows, measures, filters, operation);
    
    try {
      const result = await executeOlapQuery(sql, binds);
      res.json({ sqlGenerated: sql, operation: type, ...formatForReact(result, type === 'pivot') });
    } catch (dbErr) {
      res.json({ mockWarning: dbErr.message, sqlGenerated: sql, columns: [], rows: [] });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get cube members
app.get('/api/cubes', (req, res) => {
  res.json({
    cubes: [
      { name: 'sales_cube', description: 'Sales Data Cube' },
      { name: 'inventory_cube', description: 'Inventory Data Cube' }
    ]
  });
});

// Suppress Chrome DevTools 404 CSP error
app.get('/.well-known/appspecific/com.chrome.devtools.json', (req, res) => {
  res.status(404).json({});
});

app.listen(port, () => {
  console.log(`OLAP Server running at http://localhost:${port}`);
  console.log(`Environment: ${env}`);
});
