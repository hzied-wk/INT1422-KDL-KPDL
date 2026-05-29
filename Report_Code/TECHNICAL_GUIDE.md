# OLAP Operations Technical Guide

## 📚 Understanding OLAP Operations

### 1. **Drill Down** (Khoan sâu xuống)

**Định nghĩa**: Xem chi tiết dữ liệu ở mức độ thấp hơn

**Ví dụ**:
```
Tất cả Sản phẩm (Total)
  ↓ Drill Down
Loại Sản phẩm (Electronics, Clothing, ...)
  ↓ Drill Down
Chi tiết Sản phẩm (Laptop Dell XPS, iPhone 14, ...)
```

**Thực hiện trong API**:
```javascript
POST /api/operations/drill-down
{
  "cube": "sales_cube",
  "dimension": "DIM_MATHANG",
  "currentLevel": 0
}
```

**Dữ liệu trả về**:
```json
{
  "operation": "drill-down",
  "nextLevel": 1,
  "columns": ["Member", "Amount"],
  "rows": [
    ["Laptop", 50000],
    ["Desktop", 30000],
    ["Tablet", 20000]
  ]
}
```

---

### 2. **Roll Up** (Cuộn lên)

**Định nghĩa**: Gộp dữ liệu từ mức độ chi tiết lên mức độ cao hơn

**Ví dụ**:
```
Chi tiết Sản phẩm (Laptop Dell, Laptop HP, ...)
  ↑ Roll Up
Loại Sản phẩm (Electronics, ...)
  ↑ Roll Up
Tất cả Sản phẩm (Total)
```

**Thực hiện trong API**:
```javascript
POST /api/operations/roll-up
{
  "cube": "sales_cube",
  "dimension": "DIM_MATHANG",
  "currentLevel": 1
}
```

**Dữ liệu trả về**:
```json
{
  "operation": "roll-up",
  "nextLevel": 0,
  "columns": ["Category", "Amount"],
  "rows": [
    ["Electronics", 100000]
  ]
}
```

---

### 3. **Slice & Dice** (Chiếu chọn)

**Định nghĩa**: Lọc dữ liệu theo một hoặc nhiều điều kiện

**Slice** = Lọc theo 1 dimension
**Dice** = Lọc theo nhiều dimensions

**Ví dụ Slice**:
```
Tất cả dữ liệu bán hàng
  ↓ Slice (Vùng = Bắc)
Bán hàng ở vùng Bắc
```

**Ví dụ Dice**:
```
Tất cả dữ liệu bán hàng
  ↓ Dice (Vùng = Bắc AND Năm = 2024 AND Sản phẩm = Electronics)
Bán hàng ở vùng Bắc, năm 2024, sản phẩm Electronics
```

**Thực hiện trong API**:
```javascript
POST /api/operations/slice-dice
{
  "cube": "sales_cube",
  "filters": {
    "DIM_THOIGIAN": "2024",
    "DIM_KHACHHANG": "North",
    "DIM_MATHANG": "Electronics"
  }
}
```

**Dữ liệu trả về**:
```json
{
  "operation": "slice-dice",
  "filters": { ... },
  "columns": ["Product", "Region", "Amount"],
  "rows": [
    ["Laptop", "North", 15000],
    ["Desktop", "North", 8000]
  ]
}
```

---

### 4. **Pivot** (Xoay)

**Định nghĩa**: Sắp xếp lại chiều của bảng dữ liệu (hàng ↔ cột)

**Ví dụ**:
```
Bảng thường:
| Product | 2023    | 2024    |
|---------|---------|---------|
| Laptop  | 50000   | 60000   |
| Desktop | 30000   | 35000   |

Pivot (Xoay 90 độ):
| Year    | Laptop  | Desktop |
|---------|---------|---------|
| 2023    | 50000   | 30000   |
| 2024    | 60000   | 35000   |
```

**Thực hiện trong API**:
```javascript
POST /api/operations/pivot
{
  "cube": "sales_cube",
  "rows": ["DIM_MATHANG"],
  "columns": ["DIM_THOIGIAN"],
  "measures": ["Amount"]
}
```

**Dữ liệu trả về**:
```json
{
  "operation": "pivot",
  "rows": ["DIM_MATHANG"],
  "columns": ["DIM_THOIGIAN"],
  "data": [
    [
      { "label": "Laptop", "2023": 50000, "2024": 60000 },
      { "label": "Desktop", "2023": 30000, "2024": 35000 }
    ]
  ]
}
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                React Frontend (Port 3000)            │
├─────────────────────────────────────────────────────┤
│  CubeSelector | OLAPOperations | DataViewer         │
└─────────────────────────────────────────────────────┘
                         ↕️ HTTP/REST
┌─────────────────────────────────────────────────────┐
│           Express Backend (Port 5000)                │
├─────────────────────────────────────────────────────┤
│  API Routes | OLAP Logic | SSAS Connector           │
└─────────────────────────────────────────────────────┘
                         ↕️ XMLA
┌─────────────────────────────────────────────────────┐
│    SSAS Server (SQL Server Analysis Services)        │
├─────────────────────────────────────────────────────┤
│  Cubes | Dimensions | Measures | Facts              │
└─────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow

### 1. Fetching Initial Data
```
User selects Cube
  ↓
Frontend sends request to /api/query
  ↓
Backend processes query
  ↓
Backend returns data (mock or from SSAS)
  ↓
Frontend renders Table + Chart
```

### 2. Drill Down Flow
```
User clicks "Drill Down" button
  ↓
Frontend sends POST /api/operations/drill-down
  ↓
Backend increments currentLevel
  ↓
Backend returns drill-down data
  ↓
Frontend updates table with detailed data
  ↓
Level counter increases
```

### 3. Roll Up Flow
```
User clicks "Roll Up" button
  ↓
Check: currentLevel > 0?
  ↓
Frontend sends POST /api/operations/roll-up
  ↓
Backend decrements currentLevel
  ↓
Backend returns aggregated data
  ↓
Frontend updates table with summary data
  ↓
Level counter decreases
```

---

## 📐 Hierarchy Levels

### Time Dimension (DIM_THOIGIAN)
```
Level 0: All
Level 1: Year (2023, 2024, ...)
Level 2: Quarter (Q1, Q2, Q3, Q4)
Level 3: Month (Jan, Feb, Mar, ...)
Level 4: Day (01, 02, 03, ...)
```

### Product Dimension (DIM_MATHANG)
```
Level 0: All
Level 1: Category (Electronics, Clothing, ...)
Level 2: SubCategory (Phones, Laptops, ...)
Level 3: Product (iPhone 14, Laptop Dell XPS, ...)
```

### Customer Dimension (DIM_KHACHHANG)
```
Level 0: All
Level 1: Region (North, South, East, West)
Level 2: CustomerSegment (Corporate, Individual, ...)
Level 3: Customer (Customer ID, Name, ...)
```

---

## 💾 Measures Available

### Sales Cube
- **Amount**: Sum of sales amount
- **Quantity**: Count of items sold
- **OrderCount**: Number of orders

### Inventory Cube
- **StockLevel**: Average inventory level
- **StockValue**: Total value of inventory
- **ReorderPoints**: Average reorder point

---

## 🔌 API Response Format

All responses follow this format:

```json
{
  "operation": "operation_name",
  "columns": ["Column1", "Column2", "Column3"],
  "rows": [
    ["Value1", "Value2", 1000],
    ["Value3", "Value4", 2000]
  ],
  "metadata": {
    "totalRows": 2,
    "timestamp": "2024-01-20T10:30:00Z"
  }
}
```

---

## 🧪 Testing OLAP Operations

### Manual Testing Steps

1. **Test Drill Down**
   - Start at Level 0
   - Click Drill Down
   - Verify Level increases to 1
   - Click Drill Down again
   - Verify Level increases to 2

2. **Test Roll Up**
   - Drill Down to Level 2
   - Click Roll Up
   - Verify Level decreases to 1
   - Click Roll Up again
   - Verify Level decreases to 0

3. **Test Slice & Dice**
   - Select a dimension (e.g., DIM_THOIGIAN)
   - Click Slice & Dice
   - Verify filtered data is displayed

4. **Test Pivot**
   - Click Pivot button
   - Verify table structure changes
   - Rows and columns should be swapped

---

## 📊 Example MDX Queries

### Basic Query
```mdx
SELECT
  NON EMPTY [Measures].[Amount] ON 0,
  NON EMPTY [DIM_MATHANG].Members ON 1
FROM [sales_cube]
```

### Drill Down Query
```mdx
SELECT
  NON EMPTY [Measures].[Amount] ON 0,
  NON EMPTY [DIM_MATHANG].[Category].Members ON 1
FROM [sales_cube]
```

### Slice Query (with WHERE)
```mdx
SELECT
  NON EMPTY [Measures].[Amount] ON 0,
  NON EMPTY [DIM_MATHANG].Members ON 1
FROM [sales_cube]
WHERE [DIM_THOIGIAN].[2024]
```

### Pivot Query
```mdx
SELECT
  NON EMPTY [DIM_MATHANG].Members ON 0,
  NON EMPTY [DIM_THOIGIAN].[Year].Members ON 1
FROM [sales_cube]
WHERE [Measures].[Amount]
```

---

## 🚀 Performance Tips

1. **Limit data**: Use NON EMPTY to exclude null values
2. **Cache results**: Store frequently accessed data
3. **Aggregate early**: Roll up at server level
4. **Use indexes**: Ensure SSAS has proper indexes
5. **Monitor queries**: Track slow queries

---

Last Updated: 2024
