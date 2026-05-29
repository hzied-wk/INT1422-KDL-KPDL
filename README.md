# OLAP Web Interface & Data Warehouse Project

> **Lưu ý:** 
> - Đây là website phục vụ cho bộ môn **INT1422 - Kho dữ liệu & Khai phá dữ liệu**.
> - **Giao diện Web (Frontend) hiện tại chỉ được xây dựng ở mức cơ bản (chức năng cốt lõi) nhằm mục đích demo báo cáo và chưa được tối ưu hóa về mặt trải nghiệm người dùng (UX/UI).**

Dự án này là một hệ thống phân tích dữ liệu toàn diện (OLAP) kết hợp Data Warehouse (trên nền tảng Oracle) và một ứng dụng web (React + Node.js/Express) để trực quan hóa dữ liệu.

## 🗺 Kế Hoạch Tổng Quan Dự Án

Để hoàn thành toàn bộ hệ thống Kho dữ liệu (Data Warehouse) và giao diện Web (OLAP Web Interface) này, bạn cần thực hiện theo các giai đoạn sau:
1. **Thiết kế & Khởi tạo (Database & User):** Setup kiến trúc PDB trên Oracle và tạo user quản trị độc lập.
2. **Xây dựng Nguồn Dữ Liệu (OLTP):** Tạo các bảng chuẩn hóa (3NF) và nạp dữ liệu giao dịch giả lập.
3. **Thực thi luồng ETL (Extract - Transform - Load):** Rút trích và đổ dữ liệu từ OLTP sang cấu trúc Star Schema (Fact & Dimension) cho Data Warehouse.
4. **Phân tích Khối (CUBE) bằng SSAS:** Kết nối Data Warehouse vào Visual Studio (SSDT) để build OLAP CUBE và xử lý các độ đo (Measures).
5. **Cấu hình & Khởi chạy Web App:** Thiết lập kết nối Node.js với Oracle và chạy giao diện ReactJS để biểu diễn dữ liệu trực quan từ các API.

## 🗂 Cấu Trúc Dự Án

- `/Code`: Chứa toàn bộ mã nguồn của dự án.
  - `/client`: Frontend (ReactJS). Xử lý giao diện người dùng, biểu đồ.
  - `/server`: Backend (Node.js/Express) kết nối Oracle và chứa các script SQL tạo Cube.
  - `start.bat` / `start.sh`: Các file kịch bản khởi chạy dự án.
- `/Report`: Chứa các tài liệu, báo cáo bổ sung của hệ thống.

## 🛠 Yêu Cầu Hệ Thống

1. **Node.js** (Phiên bản 16 trở lên)
2. **Oracle Database** (Oracle 12c, 19c, hoặc 21c - có hỗ trợ PDB).
3. **Visual Studio (Visual Studio Tím - 2019/2022)** kèm theo **SQL Server Data Tools (SSDT)** để xây dựng OLAP CUBE (Analysis Services).

---

## 🚀 Hướng Dẫn Cài Đặt & Khởi Chạy

### 1. Khởi Tạo Cơ Sở Dữ Liệu & Data Warehouse bằng Oracle SQL Developer
Mở thư mục `Code/server/sql`. Bạn cần sử dụng **Oracle SQL Developer** để thực thi các script theo trình tự vô cùng nghiêm ngặt sau:

**Bước 1.1: Tạo PDB và User (Yêu cầu quyền DBA)**
- Trong SQL Developer, tạo một Connection mới đăng nhập bằng tài khoản `SYS` (Role: `SYSDBA`).
- Mở file **`DW_Project_SYS.sql`**.
- Sửa lại đường dẫn `FILE_NAME_CONVERT` hoặc `DATAFILE` trong script cho khớp với cấu trúc ổ cứng của bạn (ví dụ: `C:\app\oracle\oradata\...`).
- Chạy toàn bộ script (nhấn F5) để Oracle tạo Pluggable Database (`PDB_IDB`) mới, đồng thời tạo user `idb_schema` và cấp quyền DBA/Tablespace cho user này.

**Bước 1.2: Xây dựng OLTP (Nguồn dữ liệu)**
- Tạo một Connection mới trong SQL Developer trỏ tới user vừa tạo:
  - **Username:** `idb_schema`
  - **Password:** `IDB#2026Secure!` (hoặc mật khẩu bạn đã đổi)
  - **Service Name:** `PDB_IDB` (hoặc cấu hình SID/Port tuỳ theo hệ thống).
- Khi kết nối thành công, mở file **`DW_Project_IDB.sql`** và chạy toàn bộ lệnh (nhấn F5). Script này sẽ thiết lập cấu trúc bảng chuẩn hóa và nạp dữ liệu giả lập (Dummy Data) cho hệ thống OLTP.

**Bước 1.3: Thực hiện ETL (Chuyển đổi sang mô hình Star Schema)**
- Vẫn tiếp tục dùng Connection `idb_schema`, mở file **`DW_Project_IDB (mapping)__1.sql`**.
- Chạy toàn bộ script (nhấn F5). Quá trình này sẽ tự động rút trích dữ liệu từ các bảng OLTP, tạo Sinh Khóa Nhân Tạo (Surrogate Keys) và đổ dữ liệu sạch vào các bảng `Dim_...` và `FACT_...` để hoàn thiện kho dữ liệu.

**Bước 1.4: Xây dựng Metadata**
- Cuối cùng, vẫn ở Connection `idb_schema`, mở file **`DW_Project_IDB(meta).sql`** và chạy lệnh. Hành động này tạo ra bảng Từ điển Dữ liệu chứa siêu dữ liệu mô tả ý nghĩa nghiệp vụ của mọi đối tượng trong kho.

### 2. Cài Đặt Dependencies (Thư Viện)
Mở terminal tại thư mục gốc dự án:
- Để cài đặt thư viện cho Backend:
  ```bash
  cd Code/server
  npm install
  ```
- Để cài đặt thư viện cho Frontend:
  ```bash
  cd ../client
  npm install
  ```

### 3. Cấu Hình Biến Môi Trường (Mặc định ở `.env`)
Tạo hoặc kiểm tra file `Code/server/.env` với các thông tin kết nối Oracle:
```env
DB_USER=idb_schema
DB_PASSWORD=IDB#2026Secure!
DB_CONNECTION_STRING=localhost:1521/PDB_IDB
PORT=5000
```

### 4. Khởi Chạy Ứng Dụng
- Tại máy tính Windows: Mở thư mục `Code` và chạy `start.bat` hoặc chạy trên terminal:
  ```bash
  cd Code
  .\start.bat
  ```
- Tại máy tính Linux/Mac:
  ```bash
  sh start.sh
  ```
Hệ thống sẽ tự động mở Server ở `http://localhost:5000` và Frontend ở `http://localhost:3000`.

---

## 📊 Hướng Dẫn Xây Dựng CUBE bằng Visual Studio Tím (SSDT - Analysis Services)

Nếu bạn muốn tạo CUBE chuyên nghiệp bằng SQL Server Analysis Services (SSAS), hãy sử dụng **Visual Studio (bản màu Tím)** với công cụ SSDT:

**Bước 1: Tạo Project Analysis Services**
1. Mở Visual Studio.
2. Chọn **Create a new project**.
3. Tìm kiếm và chọn template **Analysis Services Multidimensional and Data Mining Project**.
4. Đặt tên (ví dụ: `IDB_OLAP_Cube`) và chọn thư mục lưu.

**Bước 2: Cấu Hình Data Source (Nguồn Dữ Liệu)**
1. Trong cửa sổ **Solution Explorer**, chuột phải vào thư mục **Data Sources** > **New Data Source**.
2. Chọn tạo một connection mới trỏ tới CSDL Oracle của bạn (Có thể cần cài đặt *Oracle OLE DB Provider*).
3. Nhập thông tin kết nối tới user `idb_schema` (PDB_IDB) và lưu Data Source.

**Bước 3: Tạo Data Source View (DSV)**
1. Chuột phải vào **Data Source Views** > **New Data Source View**.
2. Chọn Data Source vừa tạo ở Bước 2.
3. Chuyển các bảng trong Data Warehouse từ trái sang phải: `FACT_DOANH_SO`, `FACT_TON_KHO`, `Dim_KhachHang`, `Dim_CuaHang`, `Dim_MatHang`, `Dim_ThoiGian`.
4. (Tùy chọn) Kéo thả các đường nối (Relationships) giữa các Khóa chính trong các bảng Dim và Khóa ngoại trong bảng Fact nếu Visual Studio không tự động nhận diện.

**Bước 4: Tạo Dimension (Các Chiều Phân Tích)**
1. Chuột phải vào **Dimensions** > **New Dimension**.
2. Dùng Wizard tự động, chọn bảng Dim tương ứng (VD: `Dim_ThoiGian`).
3. Khai báo phân cấp (Hierarchies). Ví dụ đối với thời gian: `Năm -> Quý -> Tháng`.

**Bước 5: Tạo Cube**
1. Chuột phải vào **Cubes** > **New Cube**.
2. Chọn **Use existing tables** và đánh dấu các bảng Fact (`FACT_DOANH_SO`, `FACT_TON_KHO`).
3. Đánh dấu các độ đo (Measures) bạn muốn tính toán: `TongSoLuong`, `TongDoanhThu`, `SoLuongTon`, `GiaTriTon`.
4. Chọn các Dimensions đã tạo ở Bước 4.

**Bước 6: Deploy & Process (Triển Khai & Xử Lý)**
1. Chuột phải vào Project trong Solution Explorer > Chọn **Properties** để chắc chắn `Target Server` trỏ tới Server SSAS của bạn (VD: `localhost`).
2. Chuột phải vào Project > Chọn **Deploy**.
3. Sau khi Deploy thành công, bạn có thể click tab **Browser** (trong file .cube) hoặc dùng Excel (Connect to Analysis Services) để kéo thả, lập biểu đồ Pivot Table trực quan.

---

## 🗃 Hướng Dẫn Xây Dựng & Quản Trị Metadata & Index

Việc thiết lập Từ điển dữ liệu (Metadata) và Chỉ mục (Index) đóng vai trò quyết định trong việc đảm bảo hiệu năng và dễ dàng bảo trì kho dữ liệu.

### 1. Quản lý Metadata (Từ Điển Dữ Liệu)
Metadata giúp định nghĩa rõ ràng các khái niệm nghiệp vụ, kiểu dữ liệu và ý nghĩa của từng bảng/cột.
- **Cách xây dựng:** Chạy file `DW_Project_IDB(meta).sql` trong thư mục `Code/server/sql`.
- **Cấu trúc lưu trữ:** Dữ liệu sẽ được tạo ra tại bảng `METADATA_CATALOG`. 
- **Cách sử dụng:** Bất kỳ Developer hoặc Data Analyst nào khi bắt đầu phân tích dữ liệu đều cần truy vấn vào bảng `METADATA_CATALOG` để tra cứu thông tin (ví dụ: `BUSINESS_NAME`, `BUSINESS_DESC`, `CALCULATION_RULE`). 
- **Quản trị duy trì:** Mỗi khi thêm cột mới hoặc bảng Dimension/Fact mới vào mô hình, cần Insert bổ sung thông tin tương ứng vào bảng `METADATA_CATALOG` để tài liệu luôn đồng bộ với Code.

### 2. Tối Ưu Hóa Truy Vấn bằng Index
Khi lượng dữ liệu trong Data Warehouse lớn lên, Index là bắt buộc để hỗ trợ tăng tốc OLAP queries.
- **Xây dựng Index cơ bản (B-Tree):** Các Foreign Keys (Khóa Ngoại) kết nối từ Fact sang Dimension nên được đánh Index (ví dụ trong bảng `KhachHang`, `DonDatHang`, `MatHangDuocDat` đã được thiết lập mặc định).
- **Cách tối ưu cho Data Warehouse (Bitmap Index):** 
  Khác với OLTP, Data Warehouse rất phù hợp để sử dụng **Bitmap Index** trên các cột có số lượng giá trị trùng lặp lớn (low-cardinality) ở các bảng Dimension.
  ```sql
  -- Ví dụ tạo Bitmap Index:
  CREATE BITMAP INDEX idx_dim_kh_loaikh ON Dim_KhachHang(LoaiKH);
  CREATE BITMAP INDEX idx_dim_ch_bang ON Dim_CuaHang(Bang);
  ```
- **Lưu ý khi sử dụng:** 
  - Trong quá trình Load ETL đợt lớn (Bulk Insert), bạn nên dùng lệnh `ALTER INDEX ... UNUSABLE` để tạm tắt Index (giúp insert nhanh hơn).
  - Sau khi Load dữ liệu xong, tiến hành `ALTER INDEX ... REBUILD` để hệ thống tự động cập nhật lại các chỉ mục nhằm phục vụ việc Select nhanh chóng.

---
## 📝 Đánh Giá Kiến Trúc SQL & Logic ETL (Dành cho Developer)

- **Mô Hình OLTP:** Chuẩn hóa tốt (3NF), tách rời các thực thể (Khách hàng, Cửa hàng, Sản phẩm). Việc áp dụng subtype (Khách hàng Du lịch, Bưu điện) rõ ràng, phục vụ tốt cho quản lý vận hành.
- **Mô Hình OLAP:** Sử dụng Star Schema cổ điển (Kimball) là một lựa chọn tuyệt vời. Việc hợp nhất các thông tin rời rạc ở OLTP vào các Dimension phẳng (Denormalization) giúp truy vấn lấy báo cáo (Fact) cực kỳ nhanh chóng.
- **Quy tắc ETL (Extract, Transform, Load):** 
  - Tạo Surrogate Keys (SK) kiểu `INT` và giữ Natural Keys (`MaKH_Nguon`, `MaCH_Nguon`) là best-practice, cho phép dễ dàng track sự thay đổi dữ liệu (SCD).
  - Fact tồn kho được thiết kế dưới dạng *Periodic Snapshot Fact Table* (chụp hình tồn kho cuối kỳ). Việc sử dụng Subquery `MAX(NgayKiemKho)` trong mapping đã xử lý tốt nghiệp vụ lấy số tồn cuối tháng. Tuy nhiên có thể cải thiện nhẹ bằng Window Function để tăng tốc độ nếu dữ liệu scale lên hàng triệu dòng.
- **Quản trị (SYS):** Áp dụng kiến trúc Multitenant (CDB/PDB) của Oracle mới, phân quyền Role chặt chẽ là một điểm cộng lớn về bảo mật.
