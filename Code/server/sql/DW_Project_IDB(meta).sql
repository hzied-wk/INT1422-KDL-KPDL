-- ============================================
-- BẢNG TỔNG KẾT METADATA
-- ============================================
CREATE TABLE METADATA_CATALOG (
    META_ID             NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TABLE_NAME          VARCHAR2(100) NOT NULL,
    COLUMN_NAME         VARCHAR2(100),
    DATA_TYPE           VARCHAR2(50),
    COLUMN_LENGTH       NUMBER,
    IS_PRIMARY_KEY      VARCHAR2(5) DEFAULT 'NO',
    IS_FOREIGN_KEY      VARCHAR2(5) DEFAULT 'NO',
    IS_MEASURE          VARCHAR2(5) DEFAULT 'NO',
    BUSINESS_NAME       VARCHAR2(200),
    BUSINESS_DESC       VARCHAR2(500),
    CALCULATION_RULE    VARCHAR2(300),
    CATEGORY            VARCHAR2(50) CHECK (CATEGORY IN ('DIMENSION', 'FACT', 'METADATA')),
    CREATED_DATE        DATE DEFAULT SYSDATE,
    LAST_UPDATED        DATE DEFAULT SYSDATE
);

COMMENT ON TABLE METADATA_CATALOG IS 'Bảng từ điển dữ liệu - Technical & Business Metadata';
COMMENT ON COLUMN METADATA_CATALOG.BUSINESS_NAME IS 'Tên nghiệp vụ (tiếng Việt)';
COMMENT ON COLUMN METADATA_CATALOG.BUSINESS_DESC IS 'Mô tả ý nghĩa nghiệp vụ';
COMMENT ON COLUMN METADATA_CATALOG.CALCULATION_RULE IS 'Công thức tính (nếu là measure)';
ALTER TABLE METADATA_CATALOG ADD COLUMN_ORDER NUMBER;

-- ============================================
-- BẢNG LOG QUÁ TRÌNH ETL
-- ============================================
CREATE TABLE METADATA_ETL_LOG (
    LOG_ID              NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TABLE_NAME          VARCHAR2(100) NOT NULL,
    ETL_START_TIME      DATE NOT NULL,
    ETL_END_TIME        DATE,
    RECORDS_INSERTED    NUMBER,
    RECORDS_UPDATED     NUMBER DEFAULT 0,
    STATUS              VARCHAR2(20) CHECK (STATUS IN ('RUNNING', 'SUCCESS', 'FAILED')),
    ERROR_MESSAGE       VARCHAR2(1000),
    EXECUTED_BY         VARCHAR2(100) DEFAULT USER,
    CREATED_DATE        DATE DEFAULT SYSDATE
);

COMMENT ON TABLE METADATA_ETL_LOG IS 'Operational Metadata - Log quá trình nạp dữ liệu ETL';


-- ============================================
-- TỰ ĐỘNG TRÍCH XUẤT METADATA TỪ DATA DICTIONARY
-- ============================================

-- 1. DIM_THOIGIAN
INSERT INTO METADATA_CATALOG (TABLE_NAME, COLUMN_NAME, DATA_TYPE, COLUMN_LENGTH, 
    IS_PRIMARY_KEY, BUSINESS_NAME, BUSINESS_DESC, CATEGORY)
SELECT 
    'DIM_THOIGIAN' as TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    DATA_LENGTH,
    CASE WHEN COLUMN_NAME = 'THOIGIAN_KEY' THEN 'YES' ELSE 'NO' END as IS_PRIMARY_KEY,
    CASE COLUMN_NAME
        WHEN 'THOIGIAN_KEY' THEN 'Khóa thời gian'
        WHEN 'NAM' THEN 'Năm'
        WHEN 'QUY' THEN 'Quý'
        WHEN 'THANG' THEN 'Tháng'
        WHEN 'TENTHANG' THEN 'Tên tháng'
        WHEN 'TENQUY' THEN 'Tên quý'
        ELSE COLUMN_NAME
    END as BUSINESS_NAME,
    CASE COLUMN_NAME
        WHEN 'THOIGIAN_KEY' THEN 'Khóa chính định danh thời gian (YYYYMM)'
        WHEN 'NAM' THEN 'Năm dương lịch'
        WHEN 'QUY' THEN 'Quý trong năm (1-4)'
        WHEN 'THANG' THEN 'Tháng trong năm (1-12)'
        WHEN 'TENTHANG' THEN 'Tên tiếng Việt của tháng'
        WHEN 'TENQUY' THEN 'Tên quý (Quý 1, Quý 2...)'
        ELSE 'Thuộc tính thời gian'
    END as BUSINESS_DESC,
    'DIMENSION' as CATEGORY
FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = 'DIM_THOIGIAN'
ORDER BY COLUMN_ID;

-- 2. DIM_KHACHHANG
INSERT INTO METADATA_CATALOG (TABLE_NAME, COLUMN_NAME, DATA_TYPE, COLUMN_LENGTH,
    IS_PRIMARY_KEY, BUSINESS_NAME, BUSINESS_DESC, CATEGORY)
SELECT 
    'DIM_KHACHHANG',
    COLUMN_NAME,
    DATA_TYPE,
    DATA_LENGTH,
    CASE WHEN COLUMN_NAME = 'KHACHHANG_KEY' THEN 'YES' ELSE 'NO' END,
    CASE COLUMN_NAME
        WHEN 'KHACHHANG_KEY' THEN 'Khóa khách hàng'
        WHEN 'MAKH_NGUON' THEN 'Mã khách hàng nguồn'
        WHEN 'TENKH' THEN 'Tên khách hàng'
        WHEN 'LOAIKH' THEN 'Loại khách hàng'
        WHEN 'HUONGDANVIEN' THEN 'Hướng dẫn viên'
        WHEN 'DIACHIBUUDIEN' THEN 'Địa chỉ bưu điện'
        WHEN 'TENTP_SONG' THEN 'Thành phố sinh sống'
        WHEN 'BANG_SONG' THEN 'Bang sinh sống'
        ELSE COLUMN_NAME
    END,
    CASE COLUMN_NAME
        WHEN 'KHACHHANG_KEY' THEN 'Surrogate key cho chiều khách hàng'
        WHEN 'MAKH_NGUON' THEN 'Mã khách hàng từ hệ thống nguồn'
        WHEN 'TENKH' THEN 'Họ và tên đầy đủ của khách hàng'
        WHEN 'LOAIKH' THEN 'Phân loại: DuLich, BuuDien, CaHai'
        WHEN 'HUONGDANVIEN' THEN 'Tên hướng dẫn viên (cho khách du lịch)'
        WHEN 'DIACHIBUUDIEN' THEN 'Địa chỉ nhận hàng qua bưu điện'
        WHEN 'TENTP_SONG' THEN 'Thành phố nơi khách hàng sinh sống'
        WHEN 'BANG_SONG' THEN 'Bang/Vùng nơi khách hàng sinh sống'
        ELSE 'Thuộc tính khách hàng'
    END,
    'DIMENSION'
FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = 'DIM_KHACHHANG'
ORDER BY COLUMN_ID;

-- 3. DIM_CUAHANG
INSERT INTO METADATA_CATALOG (TABLE_NAME, COLUMN_NAME, DATA_TYPE, COLUMN_LENGTH,
    IS_PRIMARY_KEY, BUSINESS_NAME, BUSINESS_DESC, CATEGORY)
SELECT 
    'DIM_CUAHANG',
    COLUMN_NAME,
    DATA_TYPE,
    DATA_LENGTH,
    CASE WHEN COLUMN_NAME = 'CUAHANG_KEY' THEN 'YES' ELSE 'NO' END,
    CASE COLUMN_NAME
        WHEN 'CUAHANG_KEY' THEN 'Khóa cửa hàng'
        WHEN 'MACH_NGUON' THEN 'Mã cửa hàng nguồn'
        WHEN 'TENCH' THEN 'Tên cửa hàng'
        WHEN 'SODIENTHOAI' THEN 'Số điện thoại'
        WHEN 'TENTP' THEN 'Thành phố'
        WHEN 'BANG' THEN 'Bang'
        WHEN 'DIACHIVP' THEN 'Địa chỉ VP'
        ELSE COLUMN_NAME
    END,
    CASE COLUMN_NAME
        WHEN 'CUAHANG_KEY' THEN 'Surrogate key cho chiều cửa hàng'
        WHEN 'MACH_NGUON' THEN 'Mã cửa hàng từ hệ thống nguồn'
        WHEN 'TENCH' THEN 'Tên đầy đủ của cửa hàng'
        WHEN 'SODIENTHOAI' THEN 'Số điện thoại liên hệ'
        WHEN 'TENTP' THEN 'Thành phố nơi cửa hàng đặt trụ sở'
        WHEN 'BANG' THEN 'Bang/Vùng địa lý'
        WHEN 'DIACHIVP' THEN 'Địa chỉ văn phòng đại diện'
        ELSE 'Thuộc tính cửa hàng'
    END,
    'DIMENSION'
FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = 'DIM_CUAHANG'
ORDER BY COLUMN_ID;

-- 4. DIM_MATHANG
INSERT INTO METADATA_CATALOG (TABLE_NAME, COLUMN_NAME, DATA_TYPE, COLUMN_LENGTH,
    IS_PRIMARY_KEY, BUSINESS_NAME, BUSINESS_DESC, CATEGORY)
SELECT 
    'DIM_MATHANG',
    COLUMN_NAME,
    DATA_TYPE,
    DATA_LENGTH,
    CASE WHEN COLUMN_NAME = 'MATHANG_KEY' THEN 'YES' ELSE 'NO' END,
    CASE COLUMN_NAME
        WHEN 'MATHANG_KEY' THEN 'Khóa mặt hàng'
        WHEN 'MAMH_NGUON' THEN 'Mã mặt hàng nguồn'
        WHEN 'NHOMSP' THEN 'Nhóm sản phẩm'
        WHEN 'MOTA' THEN 'Mô tả'
        WHEN 'KICHCO' THEN 'Kích cỡ'
        WHEN 'TRONGLUONG' THEN 'Trọng lượng'
        WHEN 'DONGIAHIENTAI' THEN 'Đơn giá hiện tại'
        ELSE COLUMN_NAME
    END,
    CASE COLUMN_NAME
        WHEN 'MATHANG_KEY' THEN 'Surrogate key cho chiều mặt hàng'
        WHEN 'MAMH_NGUON' THEN 'Mã mặt hàng từ hệ thống nguồn'
        WHEN 'NHOMSP' THEN 'Phân nhóm: Điện tử, Văn phòng, Thời trang, Khác'
        WHEN 'MOTA' THEN 'Mô tả chi tiết mặt hàng'
        WHEN 'KICHCO' THEN 'Kích thước sản phẩm'
        WHEN 'TRONGLUONG' THEN 'Trọng lượng (kg)'
        WHEN 'DONGIAHIENTAI' THEN 'Đơn giá bán hiện tại (VNĐ)'
        ELSE 'Thuộc tính mặt hàng'
    END,
    'DIMENSION'
FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = 'DIM_MATHANG'
ORDER BY COLUMN_ID;

-- 5. FACT_DOANH_SO
INSERT INTO METADATA_CATALOG (TABLE_NAME, COLUMN_NAME, DATA_TYPE, COLUMN_LENGTH,
    IS_PRIMARY_KEY, IS_FOREIGN_KEY, IS_MEASURE, BUSINESS_NAME, BUSINESS_DESC, CATEGORY,
    CALCULATION_RULE)
SELECT 
    'FACT_DOANH_SO',
    COLUMN_NAME,
    DATA_TYPE,
    DATA_LENGTH,
    'NO',
    CASE WHEN COLUMN_NAME LIKE '%_KEY' THEN 'YES' ELSE 'NO' END,
    CASE WHEN COLUMN_NAME IN ('TONGSOLUONG', 'TONGDOANHTHU') THEN 'YES' ELSE 'NO' END,
    CASE COLUMN_NAME
        WHEN 'KHACHHANG_KEY' THEN 'Khóa khách hàng'
        WHEN 'MATHANG_KEY' THEN 'Khóa mặt hàng'
        WHEN 'THOIGIAN_KEY' THEN 'Khóa thời gian'
        WHEN 'TONGSOLUONG' THEN 'Tổng số lượng'
        WHEN 'TONGDOANHTHU' THEN 'Tổng doanh thu'
        ELSE COLUMN_NAME
    END,
    CASE COLUMN_NAME
        WHEN 'KHACHHANG_KEY' THEN 'FK đến DIM_KHACHHANG'
        WHEN 'MATHANG_KEY' THEN 'FK đến DIM_MATHANG'
        WHEN 'THOIGIAN_KEY' THEN 'FK đến DIM_THOIGIAN'
        WHEN 'TONGSOLUONG' THEN 'Tổng số lượng bán trong kỳ'
        WHEN 'TONGDOANHTHU' THEN 'Tổng tiền bán được trong kỳ'
        ELSE 'Khóa ngoại tham chiếu'
    END,
    'FACT',
    CASE COLUMN_NAME
        WHEN 'TONGSOLUONG' THEN 'SUM(SoLuongDat)'
        WHEN 'TONGDOANHTHU' THEN 'SUM(SoLuongDat * GiaDat)'
        ELSE NULL
    END
FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = 'FACT_DOANH_SO'
ORDER BY COLUMN_ID;

-- 6. FACT_TON_KHO
INSERT INTO METADATA_CATALOG (TABLE_NAME, COLUMN_NAME, DATA_TYPE, COLUMN_LENGTH,
    IS_PRIMARY_KEY, IS_FOREIGN_KEY, IS_MEASURE, BUSINESS_NAME, BUSINESS_DESC, CATEGORY,
    CALCULATION_RULE)
SELECT 
    'FACT_TON_KHO',
    COLUMN_NAME,
    DATA_TYPE,
    DATA_LENGTH,
    'NO',
    CASE WHEN COLUMN_NAME LIKE '%_KEY' THEN 'YES' ELSE 'NO' END,
    CASE WHEN COLUMN_NAME IN ('SOLUONGTON', 'GIATRITON') THEN 'YES' ELSE 'NO' END,
    CASE COLUMN_NAME
        WHEN 'CUAHANG_KEY' THEN 'Khóa cửa hàng'
        WHEN 'MATHANG_KEY' THEN 'Khóa mặt hàng'
        WHEN 'THOIGIAN_KEY' THEN 'Khóa thời gian'
        WHEN 'SOLUONGTON' THEN 'Số lượng tồn'
        WHEN 'GIATRITON' THEN 'Giá trị tồn'
        ELSE COLUMN_NAME
    END,
    CASE COLUMN_NAME
        WHEN 'CUAHANG_KEY' THEN 'FK đến DIM_CUAHANG'
        WHEN 'MATHANG_KEY' THEN 'FK đến DIM_MATHANG'
        WHEN 'THOIGIAN_KEY' THEN 'FK đến DIM_THOIGIAN'
        WHEN 'SOLUONGTON' THEN 'Số lượng tồn kho cuối kỳ'
        WHEN 'GIATRITON' THEN 'Giá trị tồn kho (SL * Đơn giá)'
        ELSE 'Khóa ngoại tham chiếu'
    END,
    'FACT',
    CASE COLUMN_NAME
        WHEN 'SOLUONGTON' THEN 'MAX(SoLuongTrongKho) tại ngày quyết toán'
        WHEN 'GIATRITON' THEN 'SoLuongTon * DonGiaHienTai'
        ELSE NULL
    END
FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = 'FACT_TON_KHO'
ORDER BY COLUMN_ID;

COMMIT;


-- ============================================
-- BỔ SUNG BUSINESS METADATA CHO CÁC CUBE
-- ============================================

-- Metadata cho các khối OLAP
INSERT INTO METADATA_CATALOG (TABLE_NAME, BUSINESS_NAME, BUSINESS_DESC, CATEGORY)
VALUES 
('DS_1D_NAM', 'Cube doanh thu năm', 'Phân tích doanh thu theo năm', 'FACT'),
('DS_1D_QUY', 'Cube doanh thu quý', 'Phân tích doanh thu theo quý', 'FACT'),
('DS_1D_THANG', 'Cube doanh thu tháng', 'Phân tích doanh thu theo tháng', 'FACT'),
('TK_1D_NAM', 'Cube tồn kho năm', 'Phân tích tồn kho theo năm', 'FACT'),
('TK_1D_THANG', 'Cube tồn kho tháng', 'Phân tích tồn kho theo tháng', 'FACT');

COMMIT;

-- ============================================
-- VIEW XEM METADATA THEO BẢNG
-- ============================================
CREATE OR REPLACE VIEW VW_METADATA_BY_TABLE AS
SELECT 
    TABLE_NAME,
    CATEGORY,
    COUNT(*) AS SO_COT,
    LISTAGG(
        CASE WHEN IS_PRIMARY_KEY = 'YES' THEN COLUMN_NAME || ' (PK)'
             WHEN IS_MEASURE = 'YES' THEN COLUMN_NAME || ' (Measure)'
             ELSE NULL
        END, ', '
    ) WITHIN GROUP (ORDER BY COLUMN_ORDER) AS COT_QUAN_TRONG
FROM METADATA_CATALOG
GROUP BY TABLE_NAME, CATEGORY
ORDER BY TABLE_NAME;


-- ============================================
-- VIEW XEM DANH SÁCH MEASURE
-- ============================================
CREATE OR REPLACE VIEW VW_MEASURES_LIST AS
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    BUSINESS_NAME,
    BUSINESS_DESC,
    CALCULATION_RULE,
    DATA_TYPE
FROM METADATA_CATALOG
WHERE IS_MEASURE = 'YES'
ORDER BY TABLE_NAME, COLUMN_NAME;

-- ============================================
-- VIEW XEM HIERARCHY (PHÂN CẤP)
-- ============================================
CREATE OR REPLACE VIEW VW_DIMENSION_HIERARCHY AS
SELECT 
    TABLE_NAME AS TEN_CHIEU,
    BUSINESS_DESC AS MO_TA_CHIEU,
    LISTAGG(BUSINESS_NAME || ' (' || DATA_TYPE || ')', ' → ') 
        WITHIN GROUP (ORDER BY COLUMN_NAME) AS PHAN_CAP
FROM METADATA_CATALOG
WHERE CATEGORY = 'DIMENSION'
GROUP BY TABLE_NAME, BUSINESS_DESC
ORDER BY TABLE_NAME;

-- ============================================
-- PROCEDURE TỰ ĐỘNG LOG ETL
-- ============================================
CREATE OR REPLACE PROCEDURE SP_LOG_ETL_START (
    p_table_name IN VARCHAR2,
    p_log_id OUT NUMBER
) AS
BEGIN
    INSERT INTO METADATA_ETL_LOG (TABLE_NAME, ETL_START_TIME, STATUS)
    VALUES (p_table_name, SYSDATE, 'RUNNING')
    RETURNING LOG_ID INTO p_log_id;
    COMMIT;
END;

CREATE OR REPLACE PROCEDURE SP_LOG_ETL_END (
    p_log_id IN NUMBER,
    p_records_inserted IN NUMBER,
    p_status IN VARCHAR2,
    p_error_message IN VARCHAR2 DEFAULT NULL
) AS
BEGIN
    UPDATE METADATA_ETL_LOG
    SET 
        ETL_END_TIME = SYSDATE,
        RECORDS_INSERTED = p_records_inserted,
        STATUS = p_status,
        ERROR_MESSAGE = p_error_message
    WHERE LOG_ID = p_log_id;
    COMMIT;
END;


-- Xem toàn bộ metadata của 1 bảng
SELECT * FROM METADATA_CATALOG WHERE TABLE_NAME = 'FACT_DOANH_SO';

-- Xem danh sách measures
SELECT * FROM VW_MEASURES_LIST;

-- Xem hierarchy dimensions
SELECT * FROM VW_DIMENSION_HIERARCHY;

-- Xem lịch sử ETL
SELECT * FROM METADATA_ETL_LOG ORDER BY CREATED_DATE DESC;

-- Thống kê metadata
SELECT 
    CATEGORY,
    COUNT(DISTINCT TABLE_NAME) as SO_BANG,
    COUNT(*) as TONG_SO_COT
FROM METADATA_CATALOG
GROUP BY CATEGORY;


-------------------------------------------------------------------
-- ============================================
-- INDEX CHO DIM_THOIGIAN
-- ============================================

-- Index cho khóa chính (Oracle tự tạo khi tạo PK)
-- Nhưng ta tạo thêm index cho các cột thường dùng filter

-- Index cho NĂM (thường dùng để filter)
CREATE INDEX IDX_DIM_THOIGIAN_NAM 
ON DIM_THOIGIAN(NAM)
TABLESPACE USERS
PCTFREE 10
STORAGE (INITIAL 64K NEXT 64K);

-- Index cho QUY
CREATE INDEX IDX_DIM_THOIGIAN_QUY 
ON DIM_THOIGIAN(QUY)
TABLESPACE USERS;

-- Index cho THANG
CREATE INDEX IDX_DIM_THOIGIAN_THANG 
ON DIM_THOIGIAN(THANG)
TABLESPACE USERS;

CREATE INDEX IDX_DIM_THOIGIAN_NAM_THANG
ON DIM_THOIGIAN(NAM, THANG);

-- Composite Index cho phân cấp thời gian
CREATE INDEX IDX_DIM_THOIGIAN_NAM_QUY_THANG 
ON DIM_THOIGIAN(NAM, QUY, THANG)
TABLESPACE USERS;


-- ============================================
-- INDEX CHO DIM_KHACHHANG
-- ============================================

-- Index cho khóa ngoại tham chiếu
CREATE INDEX IDX_DIM_KHACHHANG_MAKH_NGUON 
ON DIM_KHACHHANG(MAKH_NGUON)
TABLESPACE USERS;

-- Index cho LOAIKH (thường dùng để filter)
CREATE INDEX IDX_DIM_KHACHHANG_LOAIKH 
ON DIM_KHACHHANG(LOAIKH)
TABLESPACE USERS;

-- Index cho thành phố
CREATE INDEX IDX_DIM_KHACHHANG_TENTP_SONG 
ON DIM_KHACHHANG(TENTP_SONG)
TABLESPACE USERS;

-- Composite index cho phân loại
CREATE INDEX IDX_DIM_KHACHHANG_LOAI_TP 
ON DIM_KHACHHANG(LOAIKH, TENTP_SONG)
TABLESPACE USERS;

-- ============================================
-- INDEX CHO DIM_CUAHANG
-- ============================================

CREATE INDEX IDX_DIM_CUAHANG_MACH_NGUON 
ON DIM_CUAHANG(MACH_NGUON)
TABLESPACE USERS;

CREATE INDEX IDX_DIM_CUAHANG_BANG 
ON DIM_CUAHANG(BANG)
TABLESPACE USERS;

CREATE INDEX IDX_DIM_CUAHANG_TENTP 
ON DIM_CUAHANG(TENTP)
TABLESPACE USERS;

-- Composite index cho hierarchy địa lý
CREATE INDEX IDX_DIM_CUAHANG_BANG_TP 
ON DIM_CUAHANG(BANG, TENTP)
TABLESPACE USERS;

-- ============================================
-- INDEX CHO DIM_MATHANG
-- ============================================
CREATE INDEX IDX_DIM_MATHANG_MAMH_NGUON 
ON DIM_MATHANG(MAMH_NGUON)
TABLESPACE USERS;

CREATE INDEX IDX_DIM_MATHANG_NHOMSP 
ON DIM_MATHANG(NHOMSP)
TABLESPACE USERS;

-- ============================================
-- INDEX CHO FACT_DOANH_SO
-- ============================================

-- Index cho từng khóa ngoại (RẤT QUAN TRỌNG cho JOIN)
CREATE INDEX IDX_FACT_DOANH_SO_KHACHHANG_KEY 
ON FACT_DOANH_SO(KHACHHANG_KEY)
TABLESPACE USERS
PCTFREE 10
STORAGE (INITIAL 128K NEXT 128K);

CREATE INDEX IDX_FACT_DOANH_SO_MATHANG_KEY 
ON FACT_DOANH_SO(MATHANG_KEY8
TABLESPACE USERS
PCTFREE 10
STORAGE (INITIAL 128K NEXT 128K);

CREATE INDEX IDX_FACT_DOANH_SO_THOIGIAN_KEY 
ON FACT_DOANH_SO(THOIGIAN_KEY)
TABLESPACE USERS
PCTFREE 10
STORAGE (INITIAL 128K NEXT 128K);

-- Composite Index cho các chiều thường query cùng nhau
CREATE INDEX IDX_FACT_DOANH_SO_KH_THG 
ON FACT_DOANH_SO(KHACHHANG_KEY, THOIGIAN_KEY)
TABLESPACE USERS
PCTFREE 10;

CREATE INDEX IDX_FACT_DOANH_SO_MH_THG 
ON FACT_DOANH_SO(MATHANG_KEY, THOIGIAN_KEY)
TABLESPACE USERS
PCTFREE 10;

-- Bitmap Index cho các cột có ít giá trị distinct (tùy chọn)
-- Chỉ dùng khi fact table rất lớn (> 1 triệu dòng)
-- CREATE BITMAP INDEX IDX_FACT_DOANH_SO_BITMAP_THG 
-- ON FACT_DOANH_SO(THOIGIAN_KEY)
-- TABLESPACE USERS;

-- ============================================
-- INDEX CHO FACT_TON_KHO
-- ============================================

CREATE INDEX IDX_FACT_TON_KHO_CUAHANG_KEY 
ON FACT_TON_KHO(CUAHANG_KEY)
TABLESPACE USERS
PCTFREE 10
STORAGE (INITIAL 128K NEXT 128K);

CREATE INDEX IDX_FACT_TON_KHO_MATHANG_KEY 
ON FACT_TON_KHO(MATHANG_KEY)
TABLESPACE USERS
PCTFREE 10
STORAGE (INITIAL 128K NEXT 128K);

CREATE INDEX IDX_FACT_TON_KHO_THOIGIAN_KEY 
ON FACT_TON_KHO(THOIGIAN_KEY)
TABLESPACE USERS
PCTFREE 10
STORAGE (INITIAL 128K NEXT 128K);

-- Composite index cho tồn kho theo cửa hàng và thời gian
CREATE INDEX IDX_FACT_TON_KHO_CH_THG 
ON FACT_TON_KHO(CUAHANG_KEY, THOIGIAN_KEY)
TABLESPACE USERS
PCTFREE 10;

CREATE INDEX IDX_FACT_TON_KHO_MH_THG 
ON FACT_TON_KHO(MATHANG_KEY, THOIGIAN_KEY)
TABLESPACE USERS
PCTFREE 10;

-- Composite index cho query tồn kho theo vùng
CREATE INDEX IDX_FACT_TON_KHO 
ON FACT_TON_KHO(CUAHANG_KEY, MATHANG_KEY, THOIGIAN_KEY)
TABLESPACE USERS
PCTFREE 10;

-- ============================================
-- INDEX CHO METADATA_CATALOG
-- ============================================

CREATE INDEX IDX_METADATA_TABLE_NAME 
ON METADATA_CATALOG(TABLE_NAME)
TABLESPACE USERS;

CREATE INDEX IDX_METADATA_CATEGORY 
ON METADATA_CATALOG(CATEGORY)
TABLESPACE USERS;

CREATE INDEX IDX_METADATA_COLUMN_NAME 
ON METADATA_CATALOG(COLUMN_NAME)
TABLESPACE USERS;

-- Composite index
CREATE INDEX IDX_METADATA_TABLE_COL 
ON METADATA_CATALOG(TABLE_NAME, COLUMN_NAME)
TABLESPACE USERS;

-- ============================================
-- INDEX CHO METADATA_ETL_LOG
-- ============================================

CREATE INDEX IDX_ETL_LOG_TABLE_NAME 
ON METADATA_ETL_LOG(TABLE_NAME)
TABLESPACE USERS;

CREATE INDEX IDX_ETL_LOG_STATUS 
ON METADATA_ETL_LOG(STATUS)
TABLESPACE USERS;

CREATE INDEX IDX_ETL_LOG_CREATED_DATE 
ON METADATA_ETL_LOG(CREATED_DATE)
TABLESPACE USERS;

-- Composite index cho query theo thời gian
CREATE INDEX IDX_ETL_LOG_DATE_STATUS 
ON METADATA_ETL_LOG(CREATED_DATE, STATUS)
TABLESPACE USERS;

-- ============================================
-- QUERY KIỂM TRA TẤT CẢ INDEX
-- ============================================

-- Xem danh sách index của 1 bảng
SELECT 
    INDEX_NAME,
    INDEX_TYPE,
    TABLESPACE_NAME,
    STATUS,
    UNIQUENESS
FROM USER_INDEXES
WHERE TABLE_NAME IN ('FACT_DOANH_SO', 'FACT_TON_KHO', 'DIM_KHACHHANG')
ORDER BY TABLE_NAME, INDEX_NAME;

-- Xem các cột trong index
SELECT 
    i.INDEX_NAME,
    i.TABLE_NAME,
    ic.COLUMN_NAME,
    ic.COLUMN_POSITION,
    ic.DESCEND
FROM USER_INDEXES i
JOIN USER_IND_COLUMNS ic ON i.INDEX_NAME = ic.INDEX_NAME
WHERE i.TABLE_NAME = 'FACT_DOANH_SO'
ORDER BY i.INDEX_NAME, ic.COLUMN_POSITION;

-- Xem kích thước index
SELECT 
    SEGMENT_NAME as INDEX_NAME,
    SEGMENT_TYPE,
    ROUND(BYTES/1024/1024, 2) as SIZE_MB,
    TABLESPACE_NAME
FROM USER_SEGMENTS
WHERE SEGMENT_TYPE LIKE 'INDEX%'
AND SEGMENT_NAME LIKE 'IDX_%'
ORDER BY BYTES DESC;

-- ============================================
-- SCRIPT EXPORT METADATA RA FILE CSV
-- ============================================

-- ============================================
-- SCRIPT EXPORT METADATA RA FILE CSV
-- ============================================

-- ============================================
-- SCRIPT EXPORT METADATA RA FILE CSV
-- ============================================

SET PAGESIZE 0
SET LINESIZE 200
SET HEADING OFF
SET FEEDBACK OFF
SET TERMOUT OFF

SPOOL C:\metadata_catalog.csv

-- Xuất header
SELECT 'TABLE_NAME,COLUMN_NAME,DATA_TYPE,BUSINESS_NAME,BUSINESS_DESC,CATEGORY,IS_MEASURE,CALCULATION_RULE'
FROM dual;

-- Xuất dữ liệu
SELECT 
    TABLE_NAME || ',' ||
    COLUMN_NAME || ',' ||
    DATA_TYPE || ',' ||
    BUSINESS_NAME || ',' ||
    BUSINESS_DESC || ',' ||
    CATEGORY || ',' ||
    IS_MEASURE || ',' ||
    CALCULATION_RULE
FROM METADATA_CATALOG
ORDER BY TABLE_NAME, COLUMN_NAME;

SPOOL OFF


-- ============================================
-- REBUILD INDEX (khi index bị phân mảnh)
-- ============================================
-- ============================================
-- XÓA INDEX (khi không cần)
-- ============================================

-- DROP INDEX IDX_FACT_DOANH_SO_KHACHHANG_KEY;

SET PAGESIZE 0
SET LINESIZE 1000
SET HEADING OFF
SET FEEDBACK OFF

SPOOL C:\metadata_report.html

SELECT '<html><head><title>Metadata Report</title></head><body>' FROM DUAL;
SELECT '<h1>Metadata Catalog - Data Warehouse</h1>' FROM DUAL;
SELECT '<h2>Generated: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') || '</h2>' FROM DUAL;

SELECT '<h3>Dimensions</h3>' FROM DUAL;
SELECT '<table border="1"><tr><th>Table</th><th>Column</th><th>Business Name</th><th>Description</th></tr>' FROM DUAL;

SELECT '<tr><td>' || TABLE_NAME || '</td><td>' || COLUMN_NAME || '</td><td>' || 
       NVL(BUSINESS_NAME, '-') || '</td><td>' || NVL(BUSINESS_DESC, '-') || '</td></tr>'
FROM METADATA_CATALOG
WHERE CATEGORY = 'DIMENSION'
ORDER BY TABLE_NAME, COLUMN_ID;

SELECT '</table>' FROM DUAL;

-- Tương tự cho Fact tables
SELECT '<h3>Facts & Measures</h3>' FROM DUAL;
SELECT '<table border="1"><tr><th>Table</th><th>Measure</th><th>Formula</th></tr>' FROM DUAL;

SELECT '<tr><td>' || TABLE_NAME || '</td><td>' || COLUMN_NAME || '</td><td>' || 
       NVL(CALCULATION_RULE, '-') || '</td></tr>'
FROM METADATA_CATALOG
WHERE IS_MEASURE = 'YES'
ORDER BY TABLE_NAME;

SELECT '</table></body></html>' FROM DUAL;

SPOOL OFF





WITH Source_Agg AS (
  SELECT dd.MaKH, md.MaMH, 
         TO_NUMBER(TO_CHAR(dd.NgayDatHang,'YYYYMM')) AS TG,
         SUM(md.SoLuongDat) AS SL, SUM(md.SoLuongDat * md.GiaDat) AS DT
  FROM MatHangDuocDat md
  JOIN DonDatHang dd ON md.MaDon = dd.MaDon
  GROUP BY dd.MaKH, md.MaMH, TO_NUMBER(TO_CHAR(dd.NgayDatHang,'YYYYMM'))
),
DW_Agg AS (
  SELECT dk.MaKH_Nguon, dm.MaMH_Nguon, f.ThoiGian_Key, f.TongSoLuong, f.TongDoanhThu
  FROM FACT_DOANH_SO f
  JOIN Dim_KhachHang dk ON f.KhachHang_Key = dk.KhachHang_Key
  JOIN Dim_MatHang dm ON f.MatHang_Key = dm.MatHang_Key
)
SELECT COUNT(*) AS DIFF_COUNT FROM (
  SELECT * FROM Source_Agg FULL OUTER JOIN DW_Agg 
  ON MaKH = MaKH_Nguon AND MaMH = MaMH_Nguon AND TG = ThoiGian_Key
  WHERE NVL(SL,0) <> NVL(TongSoLuong,0) OR NVL(DT,0) <> NVL(TongDoanhThu,0)
);



