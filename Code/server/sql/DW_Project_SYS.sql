SELECT sys_context('USERENV', 'CON_NAME') AS current_container,
       user AS current_user,
       version AS oracle_version 
FROM v$instance;

-- Trong worksheet, chạy:
SHOW PARAMETER db_create_file_dest;

-- 2.1. Tìm path của PDB$SEED trước
SELECT name FROM v$datafile WHERE con_id = 2 AND name LIKE '%system%';

-- Giả sử kết quả là: C:\app\oracle\oradata\ORCLCDB\pdbseed\system01.dbf
-- Thì seed path là: C:\app\oracle\oradata\ORCLCDB\pdbseed\

-- 2.2. Tạo PDB (THAY PATH CHO KHỚP VỚI MÁY BẠN)
CREATE PLUGGABLE DATABASE PDB_IDB
  ADMIN USER pdb_admin IDENTIFIED BY "PdbAdmin#2026!"
  FILE_NAME_CONVERT = (
    'C:\app\ADMIN\product\21c\oradata\XE\',
    'C:\app\ADMIN\product\21c\oradata\PDB_IDB\'
  );

ALTER PLUGGABLE DATABASE PDB_IDB OPEN;
ALTER PLUGGABLE DATABASE PDB_IDB SAVE STATE;

-- Xác nhận PDB đã tạo thành công
SELECT name AS pdb_name,
       open_mode,
       restricted,
       TO_CHAR(creation_time, 'DD-MM-YYYY HH24:MI') AS created
FROM v$pdbs
WHERE name = 'PDB_IDB';

-- 3. Tạo User idb_schema Trong PDB_IDB
ALTER SESSION SET CONTAINER = PDB_IDB;

-- Xác nhận đã chuyển thành công:
SELECT sys_context('USERENV', 'CON_NAME') AS current_container FROM dual;
-- Phải hiện: PDB_IDB

-- Tạo user IDB
CREATE USER idb_schema 
  IDENTIFIED BY "IDB#2026Secure!" 
  DEFAULT TABLESPACE users 
  QUOTA UNLIMITED ON users;
-- fix
SELECT tablespace_name 
FROM dba_tablespaces;

CREATE USER idb_schema 
  IDENTIFIED BY "IDB#2026Secure!"
  DEFAULT TABLESPACE system
  QUOTA UNLIMITED ON system;

CREATE TABLESPACE users
  DATAFILE 'C:\app\ADMIN\product\21c\oradata\PDB_IDB\users01.dbf'
  SIZE 100M AUTOEXTEND ON;

-- Cấp quyền cơ bản
GRANT CREATE SESSION, CREATE TABLE, UNLIMITED TABLESPACE TO idb_schema;

-- (Tùy chọn) Cấp thêm quyền cho phát triển
GRANT CREATE VIEW, CREATE SEQUENCE, CREATE PROCEDURE TO idb_schema;

SHOW PDBS;
ALTER PLUGGABLE DATABASE PDB_IDB OPEN;
SELECT name, open_mode 
FROM v$pdbs;
ALTER SYSTEM REGISTER;
SHOW PARAMETER local_listener;
SELECT name, open_mode, restricted FROM v$pdbs;
ALTER PLUGGABLE DATABASE PDB_IDB CLOSE IMMEDIATE;
ALTER PLUGGABLE DATABASE PDB_IDB OPEN;

-------------------------------------------------------------------------------
-- Tạo user mới
CREATE USER hongquang IDENTIFIED BY 123456
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp;

-- Cấp quyền cơ bản
GRANT CONNECT, RESOURCE TO hongquang;

-- Nếu muốn cho phép tạo session và thao tác dữ liệu
GRANT CREATE SESSION TO hongquang;
GRANT CREATE TABLE TO hongquang;
GRANT CREATE VIEW TO hongquang;

-- Cho phép đọc dữ liệu
GRANT SELECT ON IDB_SCHEMA.FACT_DOANH_SO TO hongquang;
GRANT SELECT ON IDB_SCHEMA.FACT_TON_KHO TO hongquang;
GRANT SELECT ON IDB_SCHEMA.DIM_KHACHHANG TO hongquang;
GRANT SELECT ON IDB_SCHEMA.DIM_MATHANG TO hongquang;
GRANT SELECT ON IDB_SCHEMA.DIM_CUAHANG TO hongquang;
GRANT SELECT ON IDB_SCHEMA.DIM_THOIGIAN TO hongquang;

-- Nếu muốn cho phép đồng đội thêm/sửa dữ liệu
GRANT INSERT, UPDATE, DELETE ON IDB_SCHEMA.FACT_DOANH_SO TO hongquang;
GRANT INSERT, UPDATE, DELETE ON IDB_SCHEMA.FACT_TON_KHO TO hongquang;


SELECT logins FROM v$instance;
ALTER SYSTEM DISABLE RESTRICTED SESSION;
COMMIT;

SELECT logins FROM v$instance;
SELECT * FROM dba_sys_privs;
SELECT status FROM v$instance;
ALTER SYSTEM DISABLE RESTRICTED SESSION;
SHOW PARAMETER spfile;

SELECT trigger_name, status 
FROM dba_triggers 
WHERE triggering_event LIKE '%STARTUP%';

SELECT trigger_name, status 
FROM dba_triggers 
WHERE triggering_event LIKE '%STARTUP%';
ALTER TRIGGER ten_trigger DISABLE;
DROP TRIGGER STARTUP_RESTRICT;

-- Hiển thị user hiện tại
SHOW USER;

-- Hoặc dùng câu SELECT
SELECT USER FROM dual;

GRANT CREATE MATERIALIZED VIEW TO SYS;
GRANT QUERY REWRITE TO SYS;
GRANT SELECT ON DW_Project_IDB.DIM_CUAHANG TO SYS;
GRANT SELECT ON DW_Project_IDB.FACT_TON_KHO TO SYS;
GRANT SELECT ON DW_Project_IDB.DIM_KHACHHANG TO SYS;
GRANT SELECT ON DW_Project_IDB.DIM_MATHANG TO SYS;
GRANT SELECT ON DW_Project_IDB.DIM_THOIGIAN TO SYS;
GRANT SELECT ON DW_Project_IDB.DIM_CUAHANG TO SYS;

CREATE USER DW_PROJECT IDENTIFIED BY 123456;
GRANT CONNECT, RESOURCE TO DW_PROJECT;
GRANT CREATE MATERIALIZED VIEW TO DW_PROJECT;
GRANT QUERY REWRITE TO DW_PROJECT;

ALTER SESSION SET CONTAINER = PDB_IDB;
Show CON_NAME
CREATE USER nkc IDENTIFIED BY 123;
GRANT CREATE SESSION, CONNECT, RESOURCE TO nkc;
ALTER USER nkc QUOTA UNLIMITED ON USERS;
GRANT DBA TO nkc;

GRANT CREATE MATERIALIZED VIEW TO nkc;
GRANT QUERY REWRITE TO nkc;
SELECT * FROM all_tables WHERE table_name LIKE '%DOANH%';

GRANT SELECT ON DW_Project_IDB.FACT_DOANH_SO TO nkc;
GRANT SELECT ON DW_Project_IDB.DIM_KHACHHANG TO nkc;
GRANT SELECT ON DW_Project_IDB.DIM_MATHANG TO nkc;
GRANT SELECT ON DW_Project_IDB.DIM_THOIGIAN TO nkc;

SELECT owner, table_name 
FROM all_tables 
WHERE owner = 'DW_PROJECT_IDB';


GRANT CREATE MATERIALIZED VIEW TO idb_schema;
GRANT SELECT ON FACT_DOANH_SO TO idb_schema;
GRANT SELECT ON DIM_KHACHHANG TO idb_schema;
GRANT SELECT ON DIM_MATHANG TO idb_schema;
GRANT SELECT ON DIM_THOIGIAN TO idb_schema;
-- Nếu cần không giới hạn tablespace:
GRANT UNLIMITED TABLESPACE TO <tên_user>;

GRANT UNLIMITED TABLESPACE TO idb_schema;
-- Hoặc cấp quota cụ thể (ví dụ 100M trên tablespace USERS):
ALTER USER idb_schema QUOTA 100M ON USERS;


GRANT CREATE VIEW TO idb_schema;

-- Cho phép tạo sequence
GRANT CREATE SEQUENCE TO idb_schema;

-- Cho phép tạo procedure/function/package
GRANT CREATE PROCEDURE TO idb_schema;

-- Cho phép tạo synonym
GRANT CREATE SYNONYM TO idb_schema;

-- Cho phép sử dụng tablespace USERS (hoặc tablespace bạn muốn)
ALTER USER idb_schema QUOTA UNLIMITED ON users;

SHOW USER;
SELECT * FROM session_roles;
SELECT * FROM user_sys_privs;
GRANT CONNECT, RESOURCE TO idb_schema;
GRANT CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE PROCEDURE, CREATE SYNONYM TO idb_schema;
ALTER USER idb_schema QUOTA UNLIMITED ON users;

GRANT CREATE SESSION TO idb_schema;

-- Cấp quyền tạo đối tượng
GRANT CREATE TABLE TO idb_schema;
GRANT CREATE VIEW TO idb_schema;
GRANT CREATE SEQUENCE TO idb_schema;
GRANT CREATE PROCEDURE TO idb_schema;
GRANT CREATE SYNONYM TO idb_schema;