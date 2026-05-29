-- ============================================
-- PHẦN 1: TẠO CÁC BẢNG TRONG IDB
-- Chạy trong connection: DW_Project_IDB (user: idb_schema)
-- ============================================

-- 1. Bảng Văn Phòng Đại Diện
CREATE TABLE VanPhongDaiDien (
    MaThanhPho VARCHAR2(255) PRIMARY KEY,
    TenThanhPho VARCHAR2(255) NOT NULL,
    DiaChiVP VARCHAR2(255),
    Bang VARCHAR2(255),
    NgayThanhLap DATE
);

-- 2. Bảng Cửa Hàng
CREATE TABLE CuaHang (
    MaCuaHang VARCHAR2(255) PRIMARY KEY,
    MaThanhPho VARCHAR2(255) NOT NULL,
    SoDienThoai VARCHAR2(255),
    NgayBatDauBan DATE,
    CONSTRAINT fk_ch_vpdd FOREIGN KEY (MaThanhPho) 
        REFERENCES VanPhongDaiDien(MaThanhPho)
);

-- 3. Bảng Khách Hàng
CREATE TABLE KhachHang (
    MaKH VARCHAR2(255) PRIMARY KEY,
    TenKH VARCHAR2(255) NOT NULL,
    MaThanhPho VARCHAR2(255),
    NgayDatHangDauTien DATE,
    CONSTRAINT fk_kh_vpdd FOREIGN KEY (MaThanhPho) 
        REFERENCES VanPhongDaiDien(MaThanhPho)
);

-- 4. Bảng Khách Hàng Du Lịch
CREATE TABLE KhachHangDuLich (
    MaKH VARCHAR2(255) PRIMARY KEY,
    HuongDanVienDuLich VARCHAR2(255),
    CONSTRAINT fk_khdl_kh FOREIGN KEY (MaKH) 
        REFERENCES KhachHang(MaKH)
);

-- 5. Bảng Khách Hàng Bưu Điện
CREATE TABLE KhachHangBuuDien (
    MaKH VARCHAR2(255) PRIMARY KEY,
    DiaChiBuuDien VARCHAR2(255),
    CONSTRAINT fk_khbd_kh FOREIGN KEY (MaKH) 
        REFERENCES KhachHang(MaKH)
);

-- 6. Bảng Mặt Hàng
CREATE TABLE MatHang (
    MaMH VARCHAR2(255) PRIMARY KEY,
    MoTa VARCHAR2(255),
    KichCo VARCHAR2(255),
    TrongLuong NUMBER(10,2),
    Gia NUMBER(12,2),
    NgayCapNhatGia DATE
);

-- 7. Bảng Mặt Hàng Lưu Trữ (Quan hệ n-m giữa CuaHang và MatHang)
CREATE TABLE MatHangLuuTru (
    MaCH VARCHAR2(255),
    MaMH VARCHAR2(255),
    SoLuongTrongKho INTEGER,
    NgayKiemKho DATE,
    CONSTRAINT pk_mhlt PRIMARY KEY (MaCH, MaMH),
    CONSTRAINT fk_mhlt_ch FOREIGN KEY (MaCH) 
        REFERENCES CuaHang(MaCuaHang),
    CONSTRAINT fk_mhlt_mh FOREIGN KEY (MaMH) 
        REFERENCES MatHang(MaMH)
);

-- 8. Bảng Đơn Đặt Hàng
CREATE TABLE DonDatHang (
    MaDon VARCHAR2(255) PRIMARY KEY,
    MaKH VARCHAR2(255) NOT NULL,
    NgayDatHang DATE,
    CONSTRAINT fk_ddh_kh FOREIGN KEY (MaKH) 
        REFERENCES KhachHang(MaKH)
);

-- 9. Bảng Mặt Hàng Được Đặt (Quan hệ n-m giữa MatHang và DonDatHang)
CREATE TABLE MatHangDuocDat (
    MaDon VARCHAR2(255),
    MaMH VARCHAR2(255),
    SoLuongDat INTEGER,
    GiaDat NUMBER(12,2),
    ThoiGianDat DATE,
    CONSTRAINT pk_mhdd PRIMARY KEY (MaDon, MaMH),
    CONSTRAINT fk_mhdd_ddh FOREIGN KEY (MaDon) 
        REFERENCES DonDatHang(MaDon),
    CONSTRAINT fk_mhdd_mh FOREIGN KEY (MaMH) 
        REFERENCES MatHang(MaMH)
);

-- Tạo indexes cho các khóa ngoại (tùy chọn, cải thiện performance)
CREATE INDEX idx_ch_mathanhpho ON CuaHang(MaThanhPho);
CREATE INDEX idx_kh_mathanhpho ON KhachHang(MaThanhPho);
CREATE INDEX idx_mhlt_mach ON MatHangLuuTru(MaCH);
CREATE INDEX idx_mhlt_mamh ON MatHangLuuTru(MaMH);
CREATE INDEX idx_ddh_makh ON DonDatHang(MaKH);
CREATE INDEX idx_mhdd_madon ON MatHangDuocDat(MaDon);
CREATE INDEX idx_mhdd_mamh ON MatHangDuocDat(MaMH);

COMMIT;

-------------------------------------------------------------------------------
-- ============================================
-- PHẦN 2: SINH DỮ LIỆU MẪU CHO CÁC BẢNG
-- ============================================

-- 1. Dữ liệu bảng Văn Phòng Đại Diện
INSERT INTO VanPhongDaiDien VALUES ('VP-HN-01', 'Hà Nội', '123 Đường Láng, Đống Đa', 'Hà Nội', DATE '2020-01-15');
INSERT INTO VanPhongDaiDien VALUES ('VP-HCM-01', 'TP. Hồ Chí Minh', '456 Nguyễn Văn A, Quận 1', 'TP.HCM', DATE '2019-06-20');
INSERT INTO VanPhongDaiDien VALUES ('VP-DN-01', 'Đà Nẵng', '789 Trần Phú, Hải Châu', 'Đà Nẵng', DATE '2021-03-10');
INSERT INTO VanPhongDaiDien VALUES ('VP-HP-01', 'Hải Phòng', '321 Lê Lợi, Ngô Quyền', 'Hải Phòng', DATE '2020-11-05');

-- 2. Dữ liệu bảng Cửa Hàng
INSERT INTO CuaHang VALUES ('CH-001', 'VP-HN-01', '024-1234567', DATE '2020-02-01');
INSERT INTO CuaHang VALUES ('CH-002', 'VP-HN-01', '024-2345678', DATE '2020-03-15');
INSERT INTO CuaHang VALUES ('CH-003', 'VP-HCM-01', '028-3456789', DATE '2019-07-10');
INSERT INTO CuaHang VALUES ('CH-004', 'VP-HCM-01', '028-4567890', DATE '2019-08-20');
INSERT INTO CuaHang VALUES ('CH-005', 'VP-DN-01', '0236-567890', DATE '2021-04-01');
INSERT INTO CuaHang VALUES ('CH-006', 'VP-HP-01', '0225-678901', DATE '2020-12-01');

-- 3. Dữ liệu bảng Khách Hàng
INSERT INTO KhachHang VALUES ('KH-001', 'Nguyễn Văn An', 'VP-HN-01', DATE '2023-01-10');
INSERT INTO KhachHang VALUES ('KH-002', 'Trần Thị Bình', 'VP-HN-01', DATE '2023-02-15');
INSERT INTO KhachHang VALUES ('KH-003', 'Lê Văn Cường', 'VP-HCM-01', DATE '2023-03-20');
INSERT INTO KhachHang VALUES ('KH-004', 'Phạm Thị Dung', 'VP-HCM-01', DATE '2023-04-05');
INSERT INTO KhachHang VALUES ('KH-005', 'Hoàng Minh Em', 'VP-DN-01', DATE '2023-05-12');
INSERT INTO KhachHang VALUES ('KH-006', 'Vũ Thanh F', 'VP-HP-01', DATE '2023-06-18');
INSERT INTO KhachHang VALUES ('KH-007', 'Đỗ Thị G', 'VP-HN-01', DATE '2023-07-22');
INSERT INTO KhachHang VALUES ('KH-008', 'Bùi Văn H', 'VP-HCM-01', DATE '2023-08-30');

-- 4. Dữ liệu bảng Khách Hàng Du Lịch (1-1 với KhachHang)
INSERT INTO KhachHangDuLich VALUES ('KH-001', 'HDV-001 - Nguyễn Văn Tour');
INSERT INTO KhachHangDuLich VALUES ('KH-003', 'HDV-002 - Trần Thị Guide');
INSERT INTO KhachHangDuLich VALUES ('KH-005', 'HDV-003 - Lê Văn Travel');
INSERT INTO KhachHangDuLich VALUES ('KH-007', 'HDV-001 - Nguyễn Văn Tour');

-- 5. Dữ liệu bảng Khách Hàng Bưu Điện (1-1 với KhachHang)
INSERT INTO KhachHangBuuDien VALUES ('KH-002', 'Bưu điện Đống Đa, Hà Nội');
INSERT INTO KhachHangBuuDien VALUES ('KH-004', 'Bưu điện Quận 1, TP.HCM');
INSERT INTO KhachHangBuuDien VALUES ('KH-006', 'Bưu điện Ngô Quyền, Hải Phòng');
INSERT INTO KhachHangBuuDien VALUES ('KH-008', 'Bưu điện Tân Bình, TP.HCM');

-- 6. Dữ liệu bảng Mặt Hàng
INSERT INTO MatHang VALUES ('MH-001', 'Áo thun cotton nam', 'M/L/XL', 0.25, 250000, DATE '2024-01-01');
INSERT INTO MatHang VALUES ('MH-002', 'Quần jean nam', '30/32/34', 0.60, 450000, DATE '2024-01-01');
INSERT INTO MatHang VALUES ('MH-003', 'Giày thể thao', '39/40/41/42', 0.80, 850000, DATE '2024-01-15');
INSERT INTO MatHang VALUES ('MH-004', 'Túi xách nữ', 'Medium', 0.40, 650000, DATE '2024-02-01');
INSERT INTO MatHang VALUES ('MH-005', 'Mũ lưỡi trai', 'One size', 0.15, 150000, DATE '2024-02-01');
INSERT INTO MatHang VALUES ('MH-006', 'Thắt lưng da', '95/100/105', 0.30, 350000, DATE '2024-02-15');
INSERT INTO MatHang VALUES ('MH-007', 'Ví da nam', 'Standard', 0.10, 280000, DATE '2024-03-01');
INSERT INTO MatHang VALUES ('MH-008', 'Kính mát', 'One size', 0.05, 420000, DATE '2024-03-01');

-- 7. Dữ liệu bảng Mặt Hàng Lưu Trữ (n-m giữa CuaHang và MatHang)
-- Cửa hàng CH-001
INSERT INTO MatHangLuuTru VALUES ('CH-001', 'MH-001', 50, DATE '2024-04-01');
INSERT INTO MatHangLuuTru VALUES ('CH-001', 'MH-002', 30, DATE '2024-04-01');
INSERT INTO MatHangLuuTru VALUES ('CH-001', 'MH-003', 20, DATE '2024-04-01');
INSERT INTO MatHangLuuTru VALUES ('CH-001', 'MH-005', 40, DATE '2024-04-01');
-- Cửa hàng CH-002
INSERT INTO MatHangLuuTru VALUES ('CH-002', 'MH-001', 45, DATE '2024-04-01');
INSERT INTO MatHangLuuTru VALUES ('CH-002', 'MH-004', 25, DATE '2024-04-01');
INSERT INTO MatHangLuuTru VALUES ('CH-002', 'MH-006', 35, DATE '2024-04-01');
-- Cửa hàng CH-003
INSERT INTO MatHangLuuTru VALUES ('CH-003', 'MH-002', 40, DATE '2024-04-01');
INSERT INTO MatHangLuuTru VALUES ('CH-003', 'MH-003', 30, DATE '2024-04-01');
INSERT INTO MatHangLuuTru VALUES ('CH-003', 'MH-007', 50, DATE '2024-04-01');
INSERT INTO MatHangLuuTru VALUES ('CH-003', 'MH-008', 20, DATE '2024-04-01');
-- Cửa hàng CH-004
INSERT INTO MatHangLuuTru VALUES ('CH-004', 'MH-001', 35, DATE '2024-04-01');
INSERT INTO MatHangLuuTru VALUES ('CH-004', 'MH-004', 28, DATE '2024-04-01');
INSERT INTO MatHangLuuTru VALUES ('CH-004', 'MH-005', 45, DATE '2024-04-01');
-- Cửa hàng CH-005
INSERT INTO MatHangLuuTru VALUES ('CH-005', 'MH-002', 25, DATE '2024-04-01');
INSERT INTO MatHangLuuTru VALUES ('CH-005', 'MH-003', 18, DATE '2024-04-01');
INSERT INTO MatHangLuuTru VALUES ('CH-005', 'MH-006', 30, DATE '2024-04-01');
-- Cửa hàng CH-006
INSERT INTO MatHangLuuTru VALUES ('CH-006', 'MH-001', 40, DATE '2024-04-01');
INSERT INTO MatHangLuuTru VALUES ('CH-006', 'MH-007', 35, DATE '2024-04-01');
INSERT INTO MatHangLuuTru VALUES ('CH-006', 'MH-008', 22, DATE '2024-04-01');

-- 8. Dữ liệu bảng Đơn Đặt Hàng
INSERT INTO DonDatHang VALUES ('DON-001', 'KH-001', DATE '2024-03-15');
INSERT INTO DonDatHang VALUES ('DON-002', 'KH-002', DATE '2024-03-16');
INSERT INTO DonDatHang VALUES ('DON-003', 'KH-003', DATE '2024-03-17');
INSERT INTO DonDatHang VALUES ('DON-004', 'KH-004', DATE '2024-03-18');
INSERT INTO DonDatHang VALUES ('DON-005', 'KH-005', DATE '2024-03-19');
INSERT INTO DonDatHang VALUES ('DON-006', 'KH-006', DATE '2024-03-20');
INSERT INTO DonDatHang VALUES ('DON-007', 'KH-001', DATE '2024-03-22');
INSERT INTO DonDatHang VALUES ('DON-008', 'KH-007', DATE '2024-03-23');
INSERT INTO DonDatHang VALUES ('DON-009', 'KH-008', DATE '2024-03-24');
INSERT INTO DonDatHang VALUES ('DON-010', 'KH-003', DATE '2024-03-25');

-- 9. Dữ liệu bảng Mặt Hàng Được Đặt (n-m giữa MatHang và DonDatHang)
-- Đơn DON-001
INSERT INTO MatHangDuocDat VALUES ('DON-001', 'MH-001', 2, 250000, TIMESTAMP '2024-03-15 10:30:00');
INSERT INTO MatHangDuocDat VALUES ('DON-001', 'MH-003', 1, 850000, TIMESTAMP '2024-03-15 10:30:00');
-- Đơn DON-002
INSERT INTO MatHangDuocDat VALUES ('DON-002', 'MH-002', 1, 450000, TIMESTAMP '2024-03-16 14:15:00');
INSERT INTO MatHangDuocDat VALUES ('DON-002', 'MH-004', 1, 650000, TIMESTAMP '2024-03-16 14:15:00');
-- Đơn DON-003
INSERT INTO MatHangDuocDat VALUES ('DON-003', 'MH-003', 2, 850000, TIMESTAMP '2024-03-17 09:45:00');
INSERT INTO MatHangDuocDat VALUES ('DON-003', 'MH-005', 3, 150000, TIMESTAMP '2024-03-17 09:45:00');
-- Đơn DON-004
INSERT INTO MatHangDuocDat VALUES ('DON-004', 'MH-001', 1, 250000, TIMESTAMP '2024-03-18 16:20:00');
INSERT INTO MatHangDuocDat VALUES ('DON-004', 'MH-006', 1, 350000, TIMESTAMP '2024-03-18 16:20:00');
INSERT INTO MatHangDuocDat VALUES ('DON-004', 'MH-007', 2, 280000, TIMESTAMP '2024-03-18 16:20:00');
-- Đơn DON-005
INSERT INTO MatHangDuocDat VALUES ('DON-005', 'MH-002', 2, 450000, TIMESTAMP '2024-03-19 11:00:00');
INSERT INTO MatHangDuocDat VALUES ('DON-005', 'MH-008', 1, 420000, TIMESTAMP '2024-03-19 11:00:00');
-- Đơn DON-006
INSERT INTO MatHangDuocDat VALUES ('DON-006', 'MH-004', 1, 650000, TIMESTAMP '2024-03-20 13:30:00');
INSERT INTO MatHangDuocDat VALUES ('DON-006', 'MH-005', 2, 150000, TIMESTAMP '2024-03-20 13:30:00');
-- Đơn DON-007
INSERT INTO MatHangDuocDat VALUES ('DON-007', 'MH-001', 3, 250000, TIMESTAMP '2024-03-22 15:45:00');
INSERT INTO MatHangDuocDat VALUES ('DON-007', 'MH-002', 1, 450000, TIMESTAMP '2024-03-22 15:45:00');
INSERT INTO MatHangDuocDat VALUES ('DON-007', 'MH-006', 1, 350000, TIMESTAMP '2024-03-22 15:45:00');
-- Đơn DON-008
INSERT INTO MatHangDuocDat VALUES ('DON-008', 'MH-003', 1, 850000, TIMESTAMP '2024-03-23 10:10:00');
INSERT INTO MatHangDuocDat VALUES ('DON-008', 'MH-007', 1, 280000, TIMESTAMP '2024-03-23 10:10:00');
-- Đơn DON-009
INSERT INTO MatHangDuocDat VALUES ('DON-009', 'MH-001', 2, 250000, TIMESTAMP '2024-03-24 14:00:00');
INSERT INTO MatHangDuocDat VALUES ('DON-009', 'MH-004', 2, 650000, TIMESTAMP '2024-03-24 14:00:00');
INSERT INTO MatHangDuocDat VALUES ('DON-009', 'MH-008', 1, 420000, TIMESTAMP '2024-03-24 14:00:00');
-- Đơn DON-010
INSERT INTO MatHangDuocDat VALUES ('DON-010', 'MH-002', 3, 450000, TIMESTAMP '2024-03-25 09:30:00');
INSERT INTO MatHangDuocDat VALUES ('DON-010', 'MH-005', 2, 150000, TIMESTAMP '2024-03-25 09:30:00');
INSERT INTO MatHangDuocDat VALUES ('DON-010', 'MH-006', 2, 350000, TIMESTAMP '2024-03-25 09:30:00');

COMMIT;
-------------------------------------------------------------------------------
-- ============================================
-- PHẦN 3: KIỂM TRA SỐ LƯỢNG DỮ LIỆU
-- ============================================

SELECT 'VanPhongDaiDien' AS TenBang, COUNT(*) AS SoDong FROM VanPhongDaiDien
UNION ALL
SELECT 'CuaHang', COUNT(*) FROM CuaHang
UNION ALL
SELECT 'KhachHang', COUNT(*) FROM KhachHang
UNION ALL
SELECT 'KhachHangDuLich', COUNT(*) FROM KhachHangDuLich
UNION ALL
SELECT 'KhachHangBuuDien', COUNT(*) FROM KhachHangBuuDien
UNION ALL
SELECT 'MatHang', COUNT(*) FROM MatHang
UNION ALL
SELECT 'MatHangLuuTru', COUNT(*) FROM MatHangLuuTru
UNION ALL
SELECT 'DonDatHang', COUNT(*) FROM DonDatHang
UNION ALL
SELECT 'MatHangDuocDat', COUNT(*) FROM MatHangDuocDat
ORDER BY TenBang;

-- ============================================
-- KIỂM TRA QUAN HỆ GIỮA CÁC BẢNG
-- ============================================
-- 1. Xem thông tin khách hàng kèm loại khách hàng
SELECT 
    kh.MaKH,
    kh.TenKH,
    vp.TenThanhPho,
    CASE 
        WHEN khdl.MaKH IS NOT NULL THEN 'Khách du lịch'
        WHEN khbd.MaKH IS NOT NULL THEN 'Khách bưu điện'
        ELSE 'Khách thường'
    END AS LoaiKhachHang
FROM KhachHang kh
LEFT JOIN VanPhongDaiDien vp ON kh.MaThanhPho = vp.MaThanhPho
LEFT JOIN KhachHangDuLich khdl ON kh.MaKH = khdl.MaKH
LEFT JOIN KhachHangBuuDien khbd ON kh.MaKH = khbd.MaKH
ORDER BY kh.MaKH;

-- 2. Xem đơn hàng kèm thông tin khách
SELECT 
    ddh.MaDon,
    ddh.NgayDatHang,
    kh.TenKH,
    vp.TenThanhPho,
    COUNT(mhdd.MaMH) AS SoMatHang
FROM DonDatHang ddh
JOIN KhachHang kh ON ddh.MaKH = kh.MaKH
LEFT JOIN VanPhongDaiDien vp ON kh.MaThanhPho = vp.MaThanhPho
LEFT JOIN MatHangDuocDat mhdd ON ddh.MaDon = mhdd.MaDon
GROUP BY ddh.MaDon, ddh.NgayDatHang, kh.TenKH, vp.TenThanhPho
ORDER BY ddh.NgayDatHang;

-- 3. Xem tồn kho theo cửa hàng
SELECT 
    ch.MaCuaHang,
    vp.TenThanhPho,
    mh.MoTa,
    mhlt.SoLuongTrongKho,
    mhlt.NgayKiemKho
FROM MatHangLuuTru mhlt
JOIN CuaHang ch ON mhlt.MaCH = ch.MaCuaHang
JOIN VanPhongDaiDien vp ON ch.MaThanhPho = vp.MaThanhPho
JOIN MatHang mh ON mhlt.MaMH = mh.MaMH
ORDER BY ch.MaCuaHang, mh.MoTa;

-- 4. Tổng doanh thu theo đơn hàng
SELECT 
    ddh.MaDon,
    kh.TenKH,
    ddh.NgayDatHang,
    SUM(mhdd.SoLuongDat * mhdd.GiaDat) AS TongTien
FROM DonDatHang ddh
JOIN KhachHang kh ON ddh.MaKH = kh.MaKH
JOIN MatHangDuocDat mhdd ON ddh.MaDon = mhdd.MaDon
GROUP BY ddh.MaDon, kh.TenKH, ddh.NgayDatHang
ORDER BY TongTien DESC;

-- ============================================
-- SCRIPT XEM DỮ LIỆU 9 BẢNG IDB
-- Chạy trong SQL Developer (Connection: idb_schema)
-- ============================================

-- 1. Bảng VAN_PHONG
SELECT * FROM VanPhongDaiDien
ORDER BY MaThanhPho;

-- 2. Bảng KhachHang
SELECT * FROM KhachHang 
ORDER BY MaKH;

-- 3. Bảng KhachHangBuuDien
SELECT * FROM KhachHangBuuDien 
ORDER BY MaKH;

-- 4. Bảng KhachHangDuLich
SELECT * FROM KhachHangDuLich 
ORDER BY MaKH;

-- 5. Bảng CuaHang
SELECT * FROM CuaHang 
ORDER BY MaCuaHang;

-- 6. Bảng MatHang
SELECT * FROM MatHang 
ORDER BY MaMH;

-- 7. Bảng MatHangLuuTru
SELECT * FROM MatHangLuuTru 
ORDER BY MaCH, MaMH;

-- 8. Bảng DonDatHang
SELECT * FROM DonDatHang 
ORDER BY MaDon;

-- 9. Bảng MatHangDuocDat
SELECT * FROM MatHangDuocDat 
ORDER BY MaDon, MaMH;

---------------------------------------------------------------------------------------------------
-- ============================================
-- KIỂM TRA & HIỂN THỊ DỮ LIỆU IDB (9 BẢNG)
-- Chạy trong schema: idb_schema | PDB: PDB_IDB
-- ============================================

-- 🔹 1. THỐNG KÊ NHANH SỐ LƯỢNG BẢN GHI
SELECT 'VanPhongDaiDien'   AS TenBang, COUNT(*) AS SoDong FROM VanPhongDaiDien
UNION ALL SELECT 'CuaHang',         COUNT(*) FROM CuaHang
UNION ALL SELECT 'KhachHang',       COUNT(*) FROM KhachHang
UNION ALL SELECT 'KhachHangDuLich', COUNT(*) FROM KhachHangDuLich
UNION ALL SELECT 'KhachHangBuuDien',COUNT(*) FROM KhachHangBuuDien
UNION ALL SELECT 'MatHang',         COUNT(*) FROM MatHang
UNION ALL SELECT 'MatHangLuuTru',   COUNT(*) FROM MatHangLuuTru
UNION ALL SELECT 'DonDatHang',      COUNT(*) FROM DonDatHang
UNION ALL SELECT 'MatHangDuocDat',  COUNT(*) FROM MatHangDuocDat
ORDER BY TenBang;

--  2. XEM DỮ LIỆU TỪNG BẢNG (GIỚI HẠN 10 DÒNG ĐẦU)
-- Lưu ý: Oracle 12c+ hỗ trợ FETCH FIRST. Nếu dùng phiên bản cũ hơn, thay bằng WHERE ROWNUM <= 10

SELECT * FROM VanPhongDaiDien   ORDER BY MaThanhPho   FETCH FIRST 10 ROWS ONLY;
SELECT * FROM CuaHang           ORDER BY MaCuaHang    FETCH FIRST 10 ROWS ONLY;
SELECT * FROM KhachHang         ORDER BY MaKH         FETCH FIRST 10 ROWS ONLY;
SELECT * FROM KhachHangDuLich   ORDER BY MaKH         FETCH FIRST 10 ROWS ONLY;
SELECT * FROM KhachHangBuuDien  ORDER BY MaKH         FETCH FIRST 10 ROWS ONLY;
SELECT * FROM MatHang           ORDER BY MaMH         FETCH FIRST 10 ROWS ONLY;
SELECT * FROM MatHangLuuTru     ORDER BY MaCH, MaMH   FETCH FIRST 10 ROWS ONLY;
SELECT * FROM DonDatHang        ORDER BY MaDon        FETCH FIRST 10 ROWS ONLY;
SELECT * FROM MatHangDuocDat    ORDER BY MaDon, MaMH  FETCH FIRST 10 ROWS ONLY;

-- ✅ 1. Đơn hàng kèm tên khách & tổng tiền
SELECT 
    d.MaDon, 
    d.NgayDatHang, 
    k.TenKH,
    COUNT(m.MaMH) AS SoMatHang,
    SUM(m.SoLuongDat * m.GiaDat) AS TongTien
FROM DonDatHang d
JOIN KhachHang k ON d.MaKH = k.MaKH
JOIN MatHangDuocDat m ON d.MaDon = m.MaDon
GROUP BY d.MaDon, d.NgayDatHang, k.TenKH
ORDER BY TongTien DESC
FETCH FIRST 10 ROWS ONLY;

-- ✅ 2. Tồn kho theo cửa hàng & vùng miền
SELECT 
    c.MaCuaHang,
    v.Bang,
    m.MoTa,
    l.SoLuongTrongKho,
    l.NgayKiemKho
FROM MatHangLuuTru l
JOIN CuaHang c ON l.MaCH = c.MaCuaHang
JOIN VanPhongDaiDien v ON c.MaThanhPho = v.MaThanhPho
JOIN MatHang m ON l.MaMH = m.MaMH
ORDER BY v.Bang, c.MaCuaHang
FETCH FIRST 15 ROWS ONLY;

SELECT MaDon, MaKH FROM DonDatHang WHERE MaKH LIKE 'ERR-%';

-- Kiểm tra tồn kho theo cửa hàng
SELECT ch.MaCuaHang, vp.TenThanhPho, mh.MoTa, mlt.SoLuongTrongKho
FROM MatHangLuuTru mlt
JOIN CuaHang ch ON mlt.MaCH = ch.MaCuaHang
JOIN VanPhongDaiDien vp ON ch.MaThanhPho = vp.MaThanhPho
JOIN MatHang mh ON mlt.MaMH = mh.MaMH
ORDER BY ch.MaCuaHang;

-- Thống kê doanh thu theo đơn hàng
SELECT ddh.MaDon, kh.TenKH, ddh.NgayDatHang,
       SUM(mdd.SoLuongDat * mdd.GiaDat) AS TongTien
FROM DonDatHang ddh
JOIN KhachHang kh ON ddh.MaKH = kh.MaKH
JOIN MatHangDuocDat mdd ON ddh.MaDon = mdd.MaDon
GROUP BY ddh.MaDon, kh.TenKH, ddh.NgayDatHang
ORDER BY TongTien DESC;

--  Xem thông tin khách hàng kèm loại hình
SELECT kh.MaKH, kh.TenKH, 
       CASE WHEN khdul.MaKH IS NOT NULL THEN 'Du lich' 
            WHEN khbuu.MaKH IS NOT NULL THEN 'Buu dien' 
            ELSE 'Thuong' END AS LoaiKH
FROM KhachHang kh
LEFT JOIN KhachHangDuLich khdul ON kh.MaKH = khdul.MaKH
LEFT JOIN KhachHangBuuDien khbuu ON kh.MaKH = khbuu.MaKH;

SELECT * FROM DW_Project_IDB.DIM_CUAHANG;

SELECT * FROM MV_DOANH_SO_LOAI_KH_NAM WHERE ROWNUM <=5;
SELECT * FROM MV_DOANH_SO_LOAIKH_NAM WHERE ROWNUM <= 5;

    
DROP MATERIALIZED VIEW MV_DOANH_SO_LOAIKH_NAM;
DROP MATERIALIZED VIEW MV_DOANH_SO_LOAIKH_QUY;
DROP MATERIALIZED VIEW MV_DOANH_SO_LOAIKH_THANG;

SELECT
    makh_nguon,
    tenkh,
    loaikh,
    tong_so_luong,
    tong_doanh_thu
FROM
    mv_doanh_so_khach_hang;
    
    
ALTER INDEX IDX_FACT_DOANH_SO_KHACHHANG_KEY UNUSABLE;
-- Chạy query → chậm
-- Bật lại
ALTER INDEX IDX_FACT_DOANH_SO_KHACHHANG_KEY REBUILD;