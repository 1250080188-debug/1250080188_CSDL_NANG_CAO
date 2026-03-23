CREATE TABLE HangSX (
    MaHangSX VARCHAR2(10) PRIMARY KEY,
    TenHang VARCHAR2(100),
    DiaChi VARCHAR2(200),
    SoDT VARCHAR2(15),
    Email VARCHAR2(100)
);
CREATE TABLE SanPham (
    MaSP VARCHAR2(10) PRIMARY KEY,
    MaHangSX VARCHAR2(10),
    TenSP VARCHAR2(100),
    SoLuong NUMBER DEFAULT 0,
    MauSac VARCHAR2(50),
    GiaBan NUMBER,
    DonViTinh VARCHAR2(20),
    MoTa VARCHAR2(200),

    CONSTRAINT fk_sp_hangsx 
    FOREIGN KEY (MaHangSX) REFERENCES HangSX(MaHangSX)
);
CREATE TABLE NhanVien (
    MaNV VARCHAR2(10) PRIMARY KEY,
    TenNV VARCHAR2(100),
    GioiTinh VARCHAR2(10),
    DiaChi VARCHAR2(200),
    SoDT VARCHAR2(15),
    Email VARCHAR2(100),
    TenPhong VARCHAR2(50)
);
CREATE TABLE PNhap (
    SoHDN VARCHAR2(10) PRIMARY KEY,
    NgayNhap DATE,
    MaNV VARCHAR2(10),

    CONSTRAINT fk_pn_nv 
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
CREATE TABLE Nhap (
    SoHDN VARCHAR2(10),
    MaSP VARCHAR2(10),
    SoLuongN NUMBER,
    DonGiaN NUMBER,

    CONSTRAINT pk_nhap PRIMARY KEY (SoHDN, MaSP),

    CONSTRAINT fk_nhap_pn 
    FOREIGN KEY (SoHDN) REFERENCES PNhap(SoHDN),

    CONSTRAINT fk_nhap_sp 
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
CREATE TABLE PXuat (
    SoHDX VARCHAR2(10) PRIMARY KEY,
    NgayXuat DATE,
    MaNV VARCHAR2(10),

    CONSTRAINT fk_px_nv 
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
CREATE TABLE Xuat (
    SoHDX VARCHAR2(10),
    MaSP VARCHAR2(10),
    SoLuongX NUMBER,

    CONSTRAINT pk_xuat PRIMARY KEY (SoHDX, MaSP),

    CONSTRAINT fk_xuat_px 
    FOREIGN KEY (SoHDX) REFERENCES PXuat(SoHDX),

    CONSTRAINT fk_xuat_sp 
    FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);
CREATE OR REPLACE TRIGGER trg_Nhap
BEFORE INSERT ON Nhap
FOR EACH ROW
DECLARE
    v_dem NUMBER;
BEGIN
    
    SELECT COUNT(*) INTO v_dem
    FROM SanPham
    WHERE MaSP = :NEW.MaSP;

    IF v_dem = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'MaSP khong ton tai');
    END IF;


    IF :NEW.SoLuongN <= 0 OR :NEW.DonGiaN <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'SoLuongN va DonGiaN phai > 0');
    END IF;

 
    UPDATE SanPham
    SET SoLuong = SoLuong + :NEW.SoLuongN
    WHERE MaSP = :NEW.MaSP;

END;
/
CREATE OR REPLACE TRIGGER trg_Xuat
BEFORE INSERT ON Xuat
FOR EACH ROW
DECLARE
    v_dem NUMBER;
    v_soluong NUMBER;
BEGIN

    SELECT COUNT(*), NVL(SUM(SoLuong),0)
    INTO v_dem, v_soluong
    FROM SanPham
    WHERE MaSP = :NEW.MaSP
    GROUP BY MaSP;

    IF v_dem = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'MaSP khong ton tai');
    END IF;


    IF :NEW.SoLuongX > v_soluong THEN
        RAISE_APPLICATION_ERROR(-20002, 'Khong du hang de xuat');
    END IF;


    UPDATE SanPham
    SET SoLuong = SoLuong - :NEW.SoLuongX
    WHERE MaSP = :NEW.MaSP;

END;
/
CREATE OR REPLACE PACKAGE pkg_state AS
    g_row_count NUMBER := 0;
END pkg_state;
/

CREATE OR REPLACE TRIGGER trg_CapNhatXuat
FOR UPDATE ON Xuat
COMPOUND TRIGGER


BEFORE STATEMENT IS
BEGIN
    pkg_state.g_row_count := 0;
END BEFORE STATEMENT;
/


CREATE OR REPLACE TRIGGER trg_CapNhatXuat
FOR UPDATE ON Xuat
COMPOUND TRIGGER


BEFORE STATEMENT IS
BEGIN
    pkg_state.g_row_count := 0;
END BEFORE STATEMENT;


BEFORE EACH ROW IS
    v_soluong NUMBER;
    v_chenhlech NUMBER;
BEGIN
    pkg_state.g_row_count := pkg_state.g_row_count + 1;

    IF pkg_state.g_row_count > 1 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Chi duoc cap nhat 1 dong');
    END IF;

    v_chenhlech := :NEW.SoLuongX - :OLD.SoLuongX;

    IF v_chenhlech != 0 THEN

        SELECT SoLuong INTO v_soluong
        FROM SanPham
        WHERE MaSP = :NEW.MaSP;

        IF v_chenhlech > 0 AND v_chenhlech > v_soluong THEN
            RAISE_APPLICATION_ERROR(-20002, 'Khong du hang');
        END IF;

        UPDATE SanPham
        SET SoLuong = SoLuong - v_chenhlech
        WHERE MaSP = :NEW.MaSP;

    END IF;

END BEFORE EACH ROW;

END trg_CapNhatXuat;
/
CREATE OR REPLACE TRIGGER trg_CapNhatNhap
FOR UPDATE ON Nhap
COMPOUND TRIGGER

BEFORE STATEMENT IS
BEGIN
    pkg_state.g_row_count := 0;
END BEFORE STATEMENT;

BEFORE EACH ROW IS
DECLARE
    v_chenhlech NUMBER;
BEGIN
   
    pkg_state.g_row_count := pkg_state.g_row_count + 1;

    IF pkg_state.g_row_count > 1 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Chi duoc cap nhat 1 dong');
    END IF;

  
    v_chenhlech := :NEW.SoLuongN - :OLD.SoLuongN;


    IF v_chenhlech != 0 THEN
        UPDATE SanPham
        SET SoLuong = SoLuong + v_chenhlech
        WHERE MaSP = :NEW.MaSP;
    END IF;

END BEFORE EACH ROW;

END trg_CapNhatNhap;
/
CREATE OR REPLACE TRIGGER trg_XoaNhap
AFTER DELETE ON Nhap
FOR EACH ROW
BEGIN
    UPDATE SanPham
    SET SoLuong = SoLuong - :OLD.SoLuongN
    WHERE MaSP = :OLD.MaSP;
END;
/
CREATE OR REPLACE TRIGGER trg_DatPhong
BEFORE INSERT ON HoaDon
FOR EACH ROW
DECLARE
    v_dem_kh NUMBER;
    v_dem_phong NUMBER;
    v_trangthai VARCHAR2(20);
    v_songuoi_max NUMBER;
    v_gia NUMBER;
    v_songay NUMBER;
BEGIN

    SELECT COUNT(*) INTO v_dem_kh
    FROM KhachHang
    WHERE MaKH = :NEW.MaKH;

    IF v_dem_kh = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Khach hang khong ton tai');
    END IF;


    SELECT COUNT(*), MAX(TrangThai), MAX(SoNguoiToiDa), MAX(GiaTheoNgay)
    INTO v_dem_phong, v_trangthai, v_songuoi_max, v_gia
    FROM Phong
    WHERE MaPhong = :NEW.MaPhong;

    IF v_dem_phong = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Phong khong ton tai');
    END IF;


    IF v_trangthai != 'TRONG' THEN
        RAISE_APPLICATION_ERROR(-20003, 'Phong khong trong');
    END IF;

  
    IF :NEW.SoNguoi > v_songuoi_max THEN
        RAISE_APPLICATION_ERROR(-20004, 'Vuot so nguoi toi da');
    END IF;


    IF :NEW.NgayNhan >= :NEW.NgayTra OR :NEW.NgayNhan < TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20005, 'Ngay khong hop le');
    END IF;

  
    v_songay := :NEW.NgayTra - :NEW.NgayNhan;
    :NEW.TongTien := v_songay * v_gia;


    UPDATE Phong
    SET TrangThai = 'DA_THUE'
    WHERE MaPhong = :NEW.MaPhong;

END;
/
CREATE OR REPLACE TRIGGER trg_CapNhatTrangThaiHD
BEFORE UPDATE OF TrangThai ON HoaDon
FOR EACH ROW
BEGIN
    -- 1. Ki?m tra chuy?n tr?ng thái h?p l?
    IF :OLD.TrangThai = 'CHO_NHAN' THEN
        IF :NEW.TrangThai NOT IN ('DANG_O', 'HUY') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Chuyen trang thai khong hop le');
        END IF;

    ELSIF :OLD.TrangThai = 'DANG_O' THEN
        IF :NEW.TrangThai != 'DA_TRA' THEN
            RAISE_APPLICATION_ERROR(-20002, 'Chi duoc chuyen sang DA_TRA');
        END IF;

    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Khong duoc thay doi');
    END IF;

    -- 2. X? lý theo tr?ng thái m?i
    IF :NEW.TrangThai = 'DA_TRA' THEN

        UPDATE Phong
        SET TrangThai = 'TRONG'
        WHERE MaPhong = :OLD.MaPhong;

        INSERT INTO LichSuPhong(MaLS, MaPhong, MaHD, NgayNhan, NgayTra, GhiChu)
        VALUES (SEQ_LS.NEXTVAL, :OLD.MaPhong, :OLD.MaHD,
                :OLD.NgayNhan, :OLD.NgayTra, 'Da tra phong');

    ELSIF :NEW.TrangThai = 'HUY' THEN

        UPDATE Phong
        SET TrangThai = 'TRONG'
        WHERE MaPhong = :OLD.MaPhong;

    END IF;

END;
/
CREATE OR REPLACE TRIGGER trg_SuaChiPhi
FOR INSERT OR UPDATE ON ChiPhiPhuThu
COMPOUND TRIGGER

BEFORE STATEMENT IS
BEGIN
    pkg_state.g_row_count := 0;
END BEFORE STATEMENT;

BEFORE EACH ROW IS
BEGIN
    pkg_state.g_row_count := pkg_state.g_row_count + 1;

    IF pkg_state.g_row_count > 5 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Toi da 5 chi phi');
    END IF;

    IF :NEW.SoTien <= 0 OR :NEW.SoTien > 50000000 THEN
        RAISE_APPLICATION_ERROR(-20002, 'So tien khong hop le');
    END IF;

END BEFORE EACH ROW;

AFTER STATEMENT IS
BEGIN
    UPDATE HoaDon hd
    SET TongTien = (
        SELECT NVL(SUM(cp.SoTien),0)
        FROM ChiPhiPhuThu cp
        WHERE cp.MaHD = hd.MaHD
    ) + NVL(hd.TongTien,0);
END AFTER STATEMENT;

END trg_SuaChiPhi;
/
CREATE SEQUENCE SEQ_HD START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE VIEW vw_PhongTrong AS
SELECT *
FROM Phong
WHERE TrangThai = 'TRONG';
CREATE OR REPLACE TRIGGER trg_vwPhongTrong_ins
INSTEAD OF INSERT ON vw_PhongTrong
FOR EACH ROW
DECLARE
    v_mahd VARCHAR2(20);
BEGIN
    v_mahd := 'HD' || TO_CHAR(SEQ_HD.NEXTVAL, 'FM0000');

    
    INSERT INTO HoaDon(MaHD, MaKH, MaPhong, NgayNhan, NgayTra, SoNguoi, TrangThai)
    VALUES (v_mahd, :NEW.MaKH, :NEW.MaPhong, :NEW.NgayNhan,
            :NEW.NgayTra, :NEW.SoNguoi, 'CHO_NHAN');

END;
/