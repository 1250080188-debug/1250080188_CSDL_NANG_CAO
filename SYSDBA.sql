CREATE TABLE NganHang (
    MaNH   VARCHAR2(10) PRIMARY KEY,
    TenNH  VARCHAR2(100) NOT NULL
);
CREATE TABLE ChiNhanh (
    MaCN        VARCHAR2(10) PRIMARY KEY,
    MaNH        VARCHAR2(10) NOT NULL,
    ThanhPhoCN  VARCHAR2(50),
    TaiSan      NUMBER(18,2),

    CONSTRAINT fk_cn_nh 
        FOREIGN KEY (MaNH) 
        REFERENCES NganHang(MaNH)
);
CREATE TABLE KhachHang (
    MaKH   VARCHAR2(10) PRIMARY KEY,
    TenKH  VARCHAR2(100) NOT NULL,
    DiaChi VARCHAR2(200)
);
CREATE TABLE TaiKhoanVay (
    SoTKV      VARCHAR2(15) PRIMARY KEY,
    MaKH       VARCHAR2(10) NOT NULL,
    MaCN       VARCHAR2(10) NOT NULL,
    SoTienVay  NUMBER(18,2),

    CONSTRAINT fk_vay_kh 
        FOREIGN KEY (MaKH) 
        REFERENCES KhachHang(MaKH),

    CONSTRAINT fk_vay_cn 
        FOREIGN KEY (MaCN) 
        REFERENCES ChiNhanh(MaCN)
);
CREATE TABLE TaiKhoanGoi (
    SoTKG      VARCHAR2(15) PRIMARY KEY,
    MaKH       VARCHAR2(10) NOT NULL,
    MaCN       VARCHAR2(10) NOT NULL,
    SoTienGoi  NUMBER(18,2),

    CONSTRAINT fk_goi_kh 
        FOREIGN KEY (MaKH) 
        REFERENCES KhachHang(MaKH),

    CONSTRAINT fk_goi_cn 
        FOREIGN KEY (MaCN) 
        REFERENCES ChiNhanh(MaCN)
);
INSERT INTO ChiNhanh VALUES ('CN01', 1, 'Da Lat', 2000000000);
INSERT INTO ChiNhanh VALUES ('CN02', 2, 'Nha Trang', 2700000000);
INSERT INTO ChiNhanh VALUES ('CN03', 3, 'Thanh Hoa', 4500000000);
INSERT INTO ChiNhanh VALUES ('CN04', 4, 'TP HCM', 6000000000);
INSERT INTO ChiNhanh VALUES ('CN05', 5, 'Da Nang', 7000000000);

INSERT INTO ChiNhanh VALUES ('CN11', 1, 'TP HCM', 5000000000);
INSERT INTO ChiNhanh VALUES ('CN12', 2, 'Hue', 1400000000);
INSERT INTO ChiNhanh VALUES ('CN13', 3, 'Da Nang', 3600000000);
INSERT INTO ChiNhanh VALUES ('CN14', 4, 'Ha Noi', 5700000000);

INSERT INTO ChiNhanh VALUES ('CN21', 1, 'Ha Noi', 3500000000);
INSERT INTO ChiNhanh VALUES ('CN22', 2, 'Ha Noi', 4500000000);
INSERT INTO ChiNhanh VALUES ('CN23', 3, 'Da Lat', 2400000000);

INSERT INTO ChiNhanh VALUES ('CN31', 1, 'Da Nang', 4000000000);
INSERT INTO ChiNhanh VALUES ('CN32', 2, 'TP HCM', 5600000000);
INSERT INTO ChiNhanh VALUES ('CN33', 3, 'Can Tho', 5400000000);
INSERT INTO ChiNhanh VALUES ('CN43', 3, 'Nam Dinh', 3600000000);

INSERT INTO NganHang VALUES (1, 'Ngan Hang Cong Thuong');
INSERT INTO NganHang VALUES (2, 'Ngan Hang Ngoai Thuong');
INSERT INTO NganHang VALUES (3, 'Ngan Hang Nong Nghiep');
INSERT INTO NganHang VALUES (4, 'Ngan Hang A Chau');
INSERT INTO NganHang VALUES (5, 'Ngan Hang Thuong Tin');

INSERT INTO TaiKhoanVay VALUES ('10001A','111222333','CN01',10000000);
INSERT INTO TaiKhoanVay VALUES ('10002A','333111222','CN02',6000000);
INSERT INTO TaiKhoanVay VALUES ('10004A','551122334','CN04',20000000);
INSERT INTO TaiKhoanVay VALUES ('10005G','221133445','CN05',15000000);
INSERT INTO TaiKhoanVay VALUES ('10001D','987654321','CN11',45000000);
INSERT INTO TaiKhoanVay VALUES ('10002D','112233445','CN12',12000000);
INSERT INTO TaiKhoanVay VALUES ('10003F','441122335','CN13',5500000);
INSERT INTO TaiKhoanVay VALUES ('10005A','123123123','CN14',12500000);

COMMIT;

INSERT INTO KhachHang VALUES ('111222333','Ho Thi Thanh Thao','456 Le Duan, Ha Noi');
INSERT INTO KhachHang VALUES ('112233445','Tran Van Tien','12 Dien Bien Phu, Q1, TP HCM');
INSERT INTO KhachHang VALUES ('123123123','Phan Thi Quynh Nhu','54 Hai Ba Trung, Ha Noi');
INSERT INTO KhachHang VALUES ('123412341','Nguyen Van Thao','34 Tran Phu, TP Nha Trang');
INSERT INTO KhachHang VALUES ('123456789','Nguyen Thi Hoa','1/4 Hoang Van Thu, Da Lat');
INSERT INTO KhachHang VALUES ('221133445','Nguyen Thi Kim Mai','4 Tran Binh Trong, Da Lat');
INSERT INTO KhachHang VALUES ('222111333','Do Tien Dong','123 Tran Phu, Nam Dinh');
INSERT INTO KhachHang VALUES ('331122445','Bui Thi Dong','345 Tran Hung Dao, Thanh Hoa');
INSERT INTO KhachHang VALUES ('333111222','Tran Dinh Hung','783 Ly Thuong Kiet, Can Tho');
INSERT INTO KhachHang VALUES ('441122335','Nguyen Dinh Cuong','P12 Thanh Xuan Nam, Q Thanh Xuan');
INSERT INTO KhachHang VALUES ('456456456','Tran Nam Son','5 Le Duan, TP Da Nang');
INSERT INTO KhachHang VALUES ('551122334','Tran Thi Khanh Van','1A Ho Tung Mau, Da Lat');
INSERT INTO KhachHang VALUES ('987654321','Ho Thanh Son','209 Tran Hung Dao, Q5, TP HCM');

COMMIT;
SELECT DISTINCT n.TenNH
FROM NganHang n
JOIN ChiNhanh c ON n.MaNH = c.MaNH
WHERE c.ThanhPhoCN = 'Da Lat';

SELECT c.*
FROM ChiNhanh c
JOIN NganHang n ON c.MaNH = n.MaNH
WHERE n.TenNH = 'Ngan Hang Cong Thuong'
  AND c.ThanhPhoCN = 'TP HCM';


SELECT n.MaNH, n.TenNH,
       c.MaCN, c.ThanhPhoCN, c.TaiSan
FROM NganHang n
JOIN ChiNhanh c ON n.MaNH = c.MaNH
ORDER BY n.MaNH;

SELECT *
FROM KhachHang
WHERE DiaChi LIKE '%Tran Hung Dao%';

SELECT *
FROM KhachHang
WHERE TenKH LIKE '%Thao%';

SELECT *
FROM KhachHang
WHERE MaKH LIKE '11%'
  AND DiaChi LIKE '%TP HCM%';

SELECT n.TenNH,
       c.ThanhPhoCN,
       c.TaiSan
FROM NganHang n
JOIN ChiNhanh c ON n.MaNH = c.MaNH
ORDER BY c.TaiSan ASC,
         c.ThanhPhoCN ASC;
