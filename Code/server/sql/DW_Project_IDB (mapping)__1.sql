-- Bước 1: Tạo bảng Dim_KhachHang
CREATE TABLE Dim_KhachHang (
    KhachHang_Key     INT PRIMARY KEY,
    MaKH_Nguon        VARCHAR2(20) NOT NULL,
    TenKH             VARCHAR2(100),
    LoaiKH            VARCHAR2(20) CHECK (LoaiKH IN ('DuLich', 'BuuDien', 'CaHai')),
    HuongDanVien      VARCHAR2(100),
    DiaChiBuuDien     VARCHAR2(200),
    TenTP_Song        VARCHAR2(50),
    Bang_Song         VARCHAR2(50)
);

-- Bước 2: Chèn dữ liệu vào Dim_KhachHang
INSERT INTO Dim_KhachHang (
    KhachHang_Key, MaKH_Nguon, TenKH, LoaiKH, 
    HuongDanVien, DiaChiBuuDien, TenTP_Song, Bang_Song
)
WITH MaxKey AS (
    SELECT NVL(MAX(KhachHang_Key), 0) AS MaxVal FROM Dim_KhachHang
),
SourceMerge AS (
    SELECT 
        kh.MaKH,
        kh.TenKH,
        kh.MaThanhPho,
        dl.HuongDanVienDuLich,
        bd.DiaChiBuuDien,
        CASE 
            WHEN dl.MaKH IS NOT NULL AND bd.MaKH IS NOT NULL THEN 'CaHai'
            WHEN dl.MaKH IS NOT NULL THEN 'DuLich'
            ELSE 'BuuDien'
        END AS LoaiKH
    FROM KhachHang kh
    LEFT JOIN KHACHHANGDULICH dl ON kh.MaKH = dl.MaKH
    LEFT JOIN KHACHHANGBUUDIEN bd ON kh.MaKH = bd.MaKH
),
WithGeo AS (
    SELECT 
        sm.*,
        vp.TenThanhPho AS TenTP_Song,
        vp.Bang AS Bang_Song
    FROM SourceMerge sm
    LEFT JOIN VanPhongDaiDien vp ON sm.MaThanhPho = vp.MaThanhPho
),
WithSK AS (
    SELECT 
        wm.*,
        (SELECT MaxVal FROM MaxKey) + ROW_NUMBER() OVER (ORDER BY wm.MaKH) AS KhachHang_Key
    FROM WithGeo wm
)
SELECT 
    KhachHang_Key,
    MaKH,
    TRIM(TenKH),
    LoaiKH,
    CASE WHEN LoaiKH IN ('DuLich', 'CaHai') THEN HuongDanVienDuLich ELSE NULL END,
    CASE WHEN LoaiKH IN ('BuuDien', 'CaHai') THEN DiaChiBuuDien ELSE NULL END,
    TenTP_Song,
    Bang_Song
FROM WithSK;

COMMIT;

-- Đếm tổng số khách hàng theo loại
SELECT LoaiKH, COUNT(*) AS SoLuong 
FROM Dim_KhachHang 
GROUP BY LoaiKH 
ORDER BY LoaiKH;

-- Xem mẫu 5 bản ghi đầu tiên
SELECT * FROM Dim_KhachHang WHERE ROWNUM <= 5;

-- Kiểm tra tính toàn vẹn: không có MaKH_Nguon trùng
SELECT MaKH_Nguon, COUNT(*) 
FROM Dim_KhachHang 
GROUP BY MaKH_Nguon 
HAVING COUNT(*) > 1;
-- Kết quả mong đợi: 0 dòng
--------------------------------------------------------------------------------
-- Bước 1: Tạo bảng Dim_CuaHang
CREATE TABLE Dim_CuaHang (
    CuaHang_Key     INT PRIMARY KEY,
    MaCH_Nguon      VARCHAR2(20) NOT NULL,
    TenCH           VARCHAR2(100),
    SoDienThoai     VARCHAR2(20),
    TenTP           VARCHAR2(50),
    Bang            VARCHAR2(50),
    DiaChiVP        VARCHAR2(200)
);

-- Bước 2: Chèn dữ liệu vào Dim_CuaHang
INSERT INTO Dim_CuaHang (
    CuaHang_Key, MaCH_Nguon, TenCH, SoDienThoai, TenTP, Bang, DiaChiVP
)
WITH MaxKey AS (
    SELECT NVL(MAX(CuaHang_Key), 0) AS MaxVal FROM Dim_CuaHang
),
SourceJoin AS (
    SELECT 
        ch.MaCuaHang,
        ch.SoDienThoai,
        ch.MaThanhPho,
        vp.TenThanhPho,
        vp.Bang,
        vp.DiaChiVP
    FROM CuaHang ch
    LEFT JOIN VanPhongDaiDien vp ON ch.MaThanhPho = vp.MaThanhPho
),
WithSK AS (
    SELECT 
        sj.*,
        (SELECT MaxVal FROM MaxKey) + ROW_NUMBER() OVER (ORDER BY sj.MaCuaHang) AS CuaHang_Key
    FROM SourceJoin sj
)
SELECT 
    CuaHang_Key,
    MaCuaHang,
    'CH_' || MaCuaHang AS TenCH,
    REGEXP_REPLACE(SoDienThoai, '[^0-9]', '') AS SoDienThoai,
    TenThanhPho,
    Bang,
    DiaChiVP
FROM WithSK;

COMMIT;

-- Đếm tổng số cửa hàng theo Bang
SELECT Bang, COUNT(*) AS SoCuaHang 
FROM Dim_CuaHang 
GROUP BY Bang 
ORDER BY Bang;

-- Xem mẫu 5 bản ghi đầu tiên
SELECT * FROM Dim_CuaHang WHERE ROWNUM <= 5;

-- Kiểm tra tính toàn vẹn: không có MaCH_Nguon trùng
SELECT MaCH_Nguon, COUNT(*) 
FROM Dim_CuaHang 
GROUP BY MaCH_Nguon 
HAVING COUNT(*) > 1;
-- Kết quả mong đợi: 0 dòng
--------------------------------------------------------------------------------
-- Bước 1: Tạo bảng đích nếu chưa tồn tại
CREATE TABLE Dim_MatHang (
    MatHang_Key      INT PRIMARY KEY,
    MaMH_Nguon       VARCHAR2(20) NOT NULL,
    NhomSP           VARCHAR2(50),
    MoTa             VARCHAR2(255),
    KichCo           VARCHAR2(50),
    TrongLuong       DECIMAL(10,2),
    DonGiaHienTai    DECIMAL(18,2)
);

-- Bước 2: Chèn dữ liệu vào Dim_MatHang
INSERT INTO Dim_MatHang (
    MatHang_Key, MaMH_Nguon, NhomSP, MoTa, KichCo, TrongLuong, DonGiaHienTai
)
WITH MaxKey AS (
    SELECT NVL(MAX(MatHang_Key), 0) AS MaxVal FROM Dim_MatHang
),
SourceData AS (
    SELECT 
        mh.MaMH,
        mh.MoTa,
        mh.KichCo,
        mh.TrongLuong,
        mh.Gia,
        CASE 
            WHEN LOWER(mh.MoTa) LIKE '%laptop%' OR LOWER(mh.MoTa) LIKE '%điện thoại%' OR LOWER(mh.MoTa) LIKE '%tablet%' THEN 'Điện tử'
            WHEN LOWER(mh.MoTa) LIKE '%giấy%' OR LOWER(mh.MoTa) LIKE '%bút%' OR LOWER(mh.MoTa) LIKE '%vở%' THEN 'Văn phòng'
            WHEN LOWER(mh.MoTa) LIKE '%quần%' OR LOWER(mh.MoTa) LIKE '%áo%' OR LOWER(mh.MoTa) LIKE '%giày%' THEN 'Thời trang'
            ELSE 'Khác'
        END AS NhomSP
    FROM MatHang mh
),
WithSK AS (
    SELECT 
        sd.*,
        (SELECT MaxVal FROM MaxKey) + ROW_NUMBER() OVER (ORDER BY sd.MaMH) AS MatHang_Key
    FROM SourceData sd
)
SELECT 
    MatHang_Key,
    MaMH,
    NhomSP,
    TRIM(MoTa),
    TRIM(KichCo),
    ROUND(TrongLuong, 2),
    ROUND(Gia, 2)
FROM WithSK;

COMMIT;

-- Đếm số lượng mặt hàng theo nhóm
SELECT NhomSP, COUNT(*) AS SoLuong 
FROM Dim_MatHang 
GROUP BY NhomSP 
ORDER BY SoLuong DESC;

-- Xem mẫu 5 bản ghi đầu tiên
SELECT * FROM Dim_MatHang WHERE ROWNUM <= 5;

-- Kiểm tra tính toàn vẹn: không có MaMH_Nguon trùng
SELECT MaMH_Nguon, COUNT(*) 
FROM Dim_MatHang 
GROUP BY MaMH_Nguon 
HAVING COUNT(*) > 1;
-- Kết quả mong đợi: 0 dòng
--------------------------------------------------------------------------------
SELECT owner, table_name
FROM all_tables
WHERE table_name IN ('FACT_DOANH_SO','DONDATHANG','MATHANGDUOCDAT','DIM_KHACHHANG','DIM_MATHANG');

-- Bước 0: Xóa dữ liệu cũ cho các tháng có trong nguồn (đảm bảo chạy lại không trùng)
DELETE FROM FACT_DOANH_SO 
WHERE ThoiGian_Key IN (
    SELECT DISTINCT TO_NUMBER(TO_CHAR(NgayDatHang, 'YYYYMM')) 
    FROM DonDatHang WHERE NgayDatHang IS NOT NULL
);

CREATE TABLE FACT_DOANH_SO (
    KhachHang_Key INT,
    MatHang_Key   INT,
    ThoiGian_Key  INT,
    TongSoLuong   NUMBER,
    TongDoanhThu  NUMBER
);
-- Bước 1: Tổng hợp & Ánh xạ khóa vào FACT_DOANH_SO
INSERT INTO FACT_DOANH_SO (
    KhachHang_Key, MatHang_Key, ThoiGian_Key, TongSoLuong, TongDoanhThu
)
WITH OrderDetails AS (
    -- Gợp chi tiết đơn & header, lọc ngày hợp lệ
    SELECT 
        dd.MaKH,
        md.MaMH,
        TO_NUMBER(TO_CHAR(dd.NgayDatHang, 'YYYYMM')) AS ThoiGian_Key,
        md.SoLuongDat,
        md.GiaDat
    FROM MatHangDuocDat md
    JOIN DonDatHang dd ON md.MaDon = dd.MaDon
    WHERE dd.NgayDatHang IS NOT NULL
),
AggregatedSales AS (
    -- Tổng hợp theo Grain: Tháng x Khách x Mặt hàng
    SELECT 
        MaKH,
        MaMH,
        ThoiGian_Key,
        SUM(SoLuongDat) AS TongSoLuong,
        SUM(SoLuongDat * GiaDat) AS TongDoanhThu
    FROM OrderDetails
    GROUP BY MaKH, MaMH, ThoiGian_Key
),
MappedKeys AS (
    -- Thay khóa tự nhiên bằng Surrogate Key từ Dimension
    SELECT 
        dk.KhachHang_Key,
        dm.MatHang_Key,
        a.ThoiGian_Key,
        a.TongSoLuong,
        a.TongDoanhThu
    FROM AggregatedSales a
    JOIN Dim_KhachHang dk ON a.MaKH = dk.MaKH_Nguon
    JOIN Dim_MatHang dm ON a.MaMH = dm.MaMH_Nguon
)
SELECT * FROM MappedKeys;

COMMIT;

-- 1. Kiểm tra tổng độ đo
SELECT SUM(TongSoLuong) AS TongSL_Ban, SUM(TongDoanhThu) AS TongDoanhThu 
FROM FACT_DOANH_SO;

-- 2. Kiểm tra phân bố theo tháng
SELECT ThoiGian_Key, COUNT(*) AS SoCapKH_MH 
FROM FACT_DOANH_SO 
GROUP BY ThoiGian_Key 
ORDER BY ThoiGian_Key;

-- 3. Kiểm tra orphan keys (khóa chiều không tồn tại)
SELECT COUNT(*) AS SoBanGhiLoi 
FROM FACT_DOANH_SO f 
WHERE NOT EXISTS (SELECT 1 FROM Dim_KhachHang d WHERE d.KhachHang_Key = f.KhachHang_Key)
   OR NOT EXISTS (SELECT 1 FROM Dim_MatHang d WHERE d.MatHang_Key = f.MatHang_Key)
   OR NOT EXISTS (SELECT 1 FROM Dim_ThoiGian d WHERE d.ThoiGian_Key = f.ThoiGian_Key);
-- Kết quả mong đợi: 0 dòng
--------------------------------------------------------------------------------
-- Bước 0: Xóa dữ liệu cũ cho các tháng có trong nguồn (đảm bảo chạy lại không trùng)
DELETE FROM FACT_TON_KHO 
WHERE ThoiGian_Key IN (
    SELECT DISTINCT TO_NUMBER(TO_CHAR(NgayKiemKho, 'YYYYMM')) 
    FROM MatHangLuuTru WHERE NgayKiemKho IS NOT NULL
);

-- 
CREATE TABLE FACT_TON_KHO (
    CuaHang_Key   INT NOT NULL,
    MatHang_Key   INT NOT NULL,
    ThoiGian_Key  INT NOT NULL,
    SoLuongTon    NUMBER,
    GiaTriTon     NUMBER,
    CONSTRAINT pk_fact_ton_kho PRIMARY KEY (CuaHang_Key, MatHang_Key, ThoiGian_Key),
    CONSTRAINT fk_fact_ton_kho_cuahang FOREIGN KEY (CuaHang_Key) REFERENCES Dim_CuaHang(CuaHang_Key),
    CONSTRAINT fk_fact_ton_kho_mathang FOREIGN KEY (MatHang_Key) REFERENCES Dim_MatHang(MatHang_Key),
    CONSTRAINT fk_fact_ton_kho_thoigian FOREIGN KEY (ThoiGian_Key) REFERENCES Dim_ThoiGian(ThoiGian_Key)
);

-- Bước 1: Tổng hợp tồn kho cuối kỳ & Ánh xạ khóa vào FACT_TON_KHO
-- SỬ DỤNG GROUP BY + MAX() THAY VÌ ROW_NUMBER()
INSERT INTO FACT_TON_KHO (
    CuaHang_Key, MatHang_Key, ThoiGian_Key, SoLuongTon, GiaTriTon
)
SELECT 
    dc.CuaHang_Key,
    dm.MatHang_Key,
    TO_NUMBER(TO_CHAR(ml.NgayKiemKho, 'YYYYMM')) AS ThoiGian_Key,
    -- Lấy số lượng tồn kho tại thời điểm kiểm kho CUỐI CÙNG trong tháng
    -- Dùng MAX với subquery để tìm giá trị tại ngày mới nhất
    (
        SELECT ml2.SoLuongTrongKho 
        FROM MatHangLuuTru ml2 
        WHERE ml2.MaCH = ml.MaCH 
          AND ml2.MaMH = ml.MaMH 
          AND TO_NUMBER(TO_CHAR(ml2.NgayKiemKho, 'YYYYMM')) = TO_NUMBER(TO_CHAR(ml.NgayKiemKho, 'YYYYMM'))
          AND ml2.NgayKiemKho = (
              SELECT MAX(ml3.NgayKiemKho) 
              FROM MatHangLuuTru ml3 
              WHERE ml3.MaCH = ml.MaCH 
                AND ml3.MaMH = ml.MaMH 
                AND TO_NUMBER(TO_CHAR(ml3.NgayKiemKho, 'YYYYMM')) = TO_NUMBER(TO_CHAR(ml.NgayKiemKho, 'YYYYMM'))
          )
    ) AS SoLuongTon,
    -- Tính giá trị tồn kho = SL tồn * đơn giá hiện tại
    (
        SELECT ml2.SoLuongTrongKho 
        FROM MatHangLuuTru ml2 
        WHERE ml2.MaCH = ml.MaCH 
          AND ml2.MaMH = ml.MaMH 
          AND TO_NUMBER(TO_CHAR(ml2.NgayKiemKho, 'YYYYMM')) = TO_NUMBER(TO_CHAR(ml.NgayKiemKho, 'YYYYMM'))
          AND ml2.NgayKiemKho = (
              SELECT MAX(ml3.NgayKiemKho) 
              FROM MatHangLuuTru ml3 
              WHERE ml3.MaCH = ml.MaCH 
                AND ml3.MaMH = ml.MaMH 
                AND TO_NUMBER(TO_CHAR(ml3.NgayKiemKho, 'YYYYMM')) = TO_NUMBER(TO_CHAR(ml.NgayKiemKho, 'YYYYMM'))
          )
    ) * dm.DonGiaHienTai AS GiaTriTon
FROM MatHangLuuTru ml
JOIN Dim_CuaHang dc ON ml.MaCH = dc.MaCH_Nguon
JOIN Dim_MatHang dm ON ml.MaMH = dm.MaMH_Nguon
WHERE ml.NgayKiemKho IS NOT NULL
GROUP BY 
    dc.CuaHang_Key,
    dm.MatHang_Key,
    dm.DonGiaHienTai,
    ml.MaCH,
    ml.MaMH,
    TO_NUMBER(TO_CHAR(ml.NgayKiemKho, 'YYYYMM'));

COMMIT;

-- 1. Kiểm tra tổng độ đo tồn kho
SELECT SUM(SoLuongTon) AS TongSL_Ton, SUM(GiaTriTon) AS TongGiaTriTon 
FROM FACT_TON_KHO;

-- 2. Kiểm tra phân bố theo tháng
SELECT ThoiGian_Key, COUNT(*) AS SoCapCH_MH 
FROM FACT_TON_KHO 
GROUP BY ThoiGian_Key 
ORDER BY ThoiGian_Key;

-- 3. Kiểm tra orphan keys (khóa chiều không tồn tại)
SELECT COUNT(*) AS SoBanGhiLoi 
FROM FACT_TON_KHO f 
WHERE NOT EXISTS (SELECT 1 FROM Dim_CuaHang d WHERE d.CuaHang_Key = f.CuaHang_Key)
   OR NOT EXISTS (SELECT 1 FROM Dim_MatHang d WHERE d.MatHang_Key = f.MatHang_Key)
   OR NOT EXISTS (SELECT 1 FROM Dim_ThoiGian d WHERE d.ThoiGian_Key = f.ThoiGian_Key);
-- Kết quả mong đợi: 0 dòng
--------------------------------------------------------------------------------
SELECT 'DOANH_SO' AS Bang, COUNT(*) AS Loi
FROM FACT_DOANH_SO f
WHERE NOT EXISTS (SELECT 1 FROM Dim_KhachHang d WHERE d.KhachHang_Key = f.KhachHang_Key)
   OR NOT EXISTS (SELECT 1 FROM Dim_MatHang d WHERE d.MatHang_Key = f.MatHang_Key)
   OR NOT EXISTS (SELECT 1 FROM Dim_ThoiGian d WHERE d.ThoiGian_Key = f.ThoiGian_Key);
-- Kết quả mong đợi: 0 dòng
--------------------------------------------------------------------------------

SELECT 'Dim_ThoiGian'   AS TenBang, COUNT(*) AS SoBanGhi FROM Dim_ThoiGian   UNION ALL
SELECT 'Dim_KhachHang', COUNT(*) FROM Dim_KhachHang UNION ALL
SELECT 'Dim_CuaHang',   COUNT(*) FROM Dim_CuaHang   UNION ALL
SELECT 'Dim_MatHang',   COUNT(*) FROM Dim_MatHang   UNION ALL
SELECT 'FACT_DOANH_SO', COUNT(*) FROM FACT_DOANH_SO UNION ALL
SELECT 'FACT_TON_KHO',  COUNT(*) FROM FACT_TON_KHO
ORDER BY TenBang;

-- Thống kê số bản ghi theo bảng DW
SELECT 'Dim_ThoiGian' AS TenBang,COUNT(*) AS SoBanGhi,'Chiều thời gian (YYYYMM)' AS MoTa
FROM Dim_ThoiGian
UNION ALL
SELECT 'Dim_KhachHang',COUNT(*),'Chiều khách hàng (hợp nhất 3 nguồn)'
FROM Dim_KhachHang
UNION ALL
SELECT 'Dim_CuaHang',COUNT(*),'Chiều cửa hàng (gộp VPĐD)'
FROM Dim_CuaHang
UNION ALL
SELECT 'Dim_MatHang',COUNT(*),'Chiều sản phẩm (có NhomSP)'
FROM Dim_MatHang
UNION ALL
SELECT 'FACT_DOANH_SO',COUNT(*),'Fact doanh thu (Grain: KH×MH×Tháng)'
FROM FACT_DOANH_SO
UNION ALL
SELECT 'FACT_TON_KHO',COUNT(*),'Fact tồn kho cuối kỳ (Grain: CH×MH×Tháng)'
FROM FACT_TON_KHO
ORDER BY TenBang;