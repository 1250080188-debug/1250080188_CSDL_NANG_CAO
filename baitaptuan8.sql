CREATE TABLE HangSX (
MaHangSX VARCHAR2(10) CONSTRAINT pk_hangsx PRIMARY KEY,
TenHang VARCHAR2(30) NOT NULL,
DiaChi VARCHAR2(50),
SoDT VARCHAR2(15),
Email VARCHAR2(50)
);
CREATE TABLE SanPham (
MaSP VARCHAR2(10) CONSTRAINT pk_sanpham PRIMARY KEY,
MaHangSX VARCHAR2(10) REFERENCES HangSX(MaHangSX),
TenSP VARCHAR2(50) NOT NULL,
SoLuong NUMBER(10),
MauSac VARCHAR2(20),
GiaBan NUMBER(15,2),
DonViTinh VARCHAR2(15),
MoTa CLOB
);
CREATE TABLE NhanVien (
MaNV VARCHAR2(10) CONSTRAINT pk_nhanvien PRIMARY KEY,
TenNV VARCHAR2(50) NOT NULL,
GioiTinh VARCHAR2(10),
DiaChi VARCHAR2(100),
SoDT VARCHAR2(15),
Email VARCHAR2(50),
TenPhong VARCHAR2(30)
);
CREATE TABLE PNhap (
SoHDN VARCHAR2(10) CONSTRAINT pk_pnhap PRIMARY KEY,
NgayNhap DATE,
MaNV VARCHAR2(10) REFERENCES NhanVien(MaNV)
);
CREATE TABLE Nhap (
SoHDN VARCHAR2(10) REFERENCES PNhap(SoHDN),
MaSP VARCHAR2(10) REFERENCES SanPham(MaSP),
SoLuongN NUMBER(10),
DonGiaN NUMBER(15,2),
CONSTRAINT pk_nhap PRIMARY KEY (SoHDN, MaSP)
);
CREATE TABLE PXuat (
SoHDX VARCHAR2(10) CONSTRAINT pk_pxuat PRIMARY KEY,
NgayXuat DATE,
MaNV VARCHAR2(10) REFERENCES NhanVien(MaNV)
);
CREATE TABLE Xuat (
SoHDX VARCHAR2(10) REFERENCES PXuat(SoHDX),
MaSP VARCHAR2(10) REFERENCES SanPham(MaSP),
SoLuongX NUMBER(10),
CREATE OR REPLACE PROCEDURE sp_NhapHangSX (
    p_MaHangSX IN VARCHAR2,
    p_TenHang  IN VARCHAR2,
    p_DiaChi   IN VARCHAR2,
    p_SoDT     IN VARCHAR2,
    p_Email    IN VARCHAR2,
    p_kq       OUT NUMBER
) AS
    v_ma VARCHAR2(10);
BEGIN
    p_kq := 0;

    BEGIN
        SELECT MaHangSX
        INTO v_ma
        FROM HangSX
        WHERE TenHang = p_TenHang;

        p_kq := 1;
        RETURN;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        INSERT INTO HangSX
        VALUES (p_MaHangSX, p_TenHang, p_DiaChi, p_SoDT, p_Email);

        COMMIT;

        p_kq := 0;
    END;

END sp_NhapHangSX;
/
SET SERVEROUTPUT ON;

DECLARE
    v_kq NUMBER;
BEGIN
    sp_NhapHangSX('HSX01','Samsung','Korea','0123456789','sam@samsung.com',v_kq);
    DBMS_OUTPUT.PUT_LINE('Ma ket qua: ' || v_kq);
END;
/
CREATE OR REPLACE PROCEDURE sp_NhapSP (
    p_MaSP IN VARCHAR2,
    p_TenHang IN VARCHAR2,
    p_TenSP IN VARCHAR2,
    p_SoLuong IN NUMBER,
    p_MauSac IN VARCHAR2,
    p_GiaBan IN NUMBER,
    p_DonViTinh IN VARCHAR2,
    p_MoTa IN CLOB,
    p_kq OUT NUMBER
) AS
    v_MaHangSX VARCHAR2(10);
    v_MaSP VARCHAR2(10);
BEGIN
    p_kq := 0;

   
    BEGIN
        SELECT MaHangSX
        INTO v_MaHangSX
        FROM HangSX
        WHERE TenHang = p_TenHang;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_kq := 1;
            RETURN;
    END;

    
    BEGIN
        SELECT MaSP
        INTO v_MaSP
        FROM SanPham
        WHERE MaSP = p_MaSP;

      
        UPDATE SanPham
        SET MaHangSX = v_MaHangSX,
            TenSP = p_TenSP,
            SoLuong = p_SoLuong,
            MauSac = p_MauSac,
            GiaBan = p_GiaBan,
            DonViTinh = p_DonViTinh,
            MoTa = p_MoTa
        WHERE MaSP = p_MaSP;

        COMMIT;

        p_kq := 2; 

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

   
        INSERT INTO SanPham
        VALUES (p_MaSP, v_MaHangSX, p_TenSP, p_SoLuong,
                p_MauSac, p_GiaBan, p_DonViTinh, p_MoTa);

        COMMIT;

        p_kq := 0; 
    END;

END sp_NhapSP;
/
SET SERVEROUTPUT ON;

DECLARE
    v_kq NUMBER;
BEGIN
    sp_NhapSP('SP01','Samsung','Tivi',10,'Den',15000000,'Cai','Smart TV',v_kq);

    DBMS_OUTPUT.PUT_LINE('Ma ket qua: ' || v_kq);
END;
/
CREATE OR REPLACE PROCEDURE sp_XoaHangSX (
    p_TenHang IN VARCHAR2,
    p_kq OUT NUMBER
) AS
    v_MaHangSX VARCHAR2(10);
BEGIN
    p_kq := 0;

    
    BEGIN
        SELECT MaHangSX
        INTO v_MaHangSX
        FROM HangSX
        WHERE TenHang = p_TenHang;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_kq := 1;
            RETURN;
    END;


    DELETE FROM SanPham
    WHERE MaHangSX = v_MaHangSX;


    DELETE FROM HangSX
    WHERE MaHangSX = v_MaHangSX;

    COMMIT;

    p_kq := 0;

END sp_XoaHangSX;
/
CREATE OR REPLACE PROCEDURE sp_NhapNhanVien (
    p_MaNV IN VARCHAR2,
    p_TenNV IN VARCHAR2,
    p_GioiTinh IN VARCHAR2,
    p_DiaChi IN VARCHAR2,
    p_SoDT IN VARCHAR2,
    p_Email IN VARCHAR2,
    p_TenPhong IN VARCHAR2,
    p_Flag IN NUMBER,
    p_kq OUT NUMBER
) AS
BEGIN
    p_kq := 0;

    
    IF p_GioiTinh <> 'Nam' AND p_GioiTinh <> 'Nu' THEN
        p_kq := 1;
        RETURN;
    END IF;


    IF p_Flag = 0 THEN

        UPDATE NhanVien
        SET TenNV = p_TenNV,
            GioiTinh = p_GioiTinh,
            DiaChi = p_DiaChi,
            SoDT = p_SoDT,
            Email = p_Email,
            TenPhong = p_TenPhong
        WHERE MaNV = p_MaNV;

    ELSE

        
        INSERT INTO NhanVien
        VALUES (p_MaNV, p_TenNV, p_GioiTinh, p_DiaChi,
                p_SoDT, p_Email, p_TenPhong);

    END IF;

    COMMIT;

END sp_NhapNhanVien;
/
CREATE OR REPLACE PROCEDURE sp_Nhap (
    p_SoHDN IN VARCHAR2,
    p_MaSP IN VARCHAR2,
    p_MaNV IN VARCHAR2,
    p_NgayNhap IN DATE,
    p_SoLuongN IN NUMBER,
    p_DonGiaN IN NUMBER,
    p_kq OUT NUMBER
) AS
    v_temp VARCHAR2(10);
BEGIN
    p_kq := 0;

  
    BEGIN
        SELECT MaSP INTO v_temp
        FROM SanPham
        WHERE MaSP = p_MaSP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_kq := 1; 
            RETURN;
    END;

   
    BEGIN
        SELECT MaNV INTO v_temp
        FROM NhanVien
        WHERE MaNV = p_MaNV;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_kq := 2; 
            RETURN;
    END;


    BEGIN
        SELECT SoHDN INTO v_temp
        FROM PNhap
        WHERE SoHDN = p_SoHDN;

    
        UPDATE Nhap
        SET SoLuongN = p_SoLuongN,
            DonGiaN = p_DonGiaN
        WHERE SoHDN = p_SoHDN
        AND MaSP = p_MaSP;

        COMMIT;

        p_kq := 3;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

       
        INSERT INTO PNhap
        VALUES (p_SoHDN, p_NgayNhap, p_MaNV);

        INSERT INTO Nhap
        VALUES (p_SoHDN, p_MaSP, p_SoLuongN, p_DonGiaN);

        COMMIT;

        p_kq := 0;
    END;

END sp_Nhap;
/
CREATE OR REPLACE PROCEDURE sp_Xuat (
    p_SoHDX IN VARCHAR2,
    p_MaSP IN VARCHAR2,
    p_MaNV IN VARCHAR2,
    p_NgayXuat IN DATE,
    p_SoLuongX IN NUMBER,
    p_kq OUT NUMBER
) AS
    v_temp VARCHAR2(10);
    v_soluong NUMBER;
BEGIN
    p_kq := 0;

    
    BEGIN
        SELECT SoLuong INTO v_soluong
        FROM SanPham
        WHERE MaSP = p_MaSP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_kq := 1; 
            RETURN;
    END;

   
    BEGIN
        SELECT MaNV INTO v_temp
        FROM NhanVien
        WHERE MaNV = p_MaNV;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_kq := 2; 
            RETURN;
    END;

    
    IF p_SoLuongX > v_soluong THEN
        p_kq := 3; 
        RETURN;
    END IF;

    
    BEGIN
        SELECT SoHDX INTO v_temp
        FROM PXuat
        WHERE SoHDX = p_SoHDX;

       
        UPDATE Xuat
        SET SoLuongX = p_SoLuongX
        WHERE SoHDX = p_SoHDX
        AND MaSP = p_MaSP;

        COMMIT;

        p_kq := 4;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

        
        INSERT INTO PXuat
        VALUES (p_SoHDX, p_NgayXuat, p_MaNV);

        INSERT INTO Xuat
        VALUES (p_SoHDX, p_MaSP, p_SoLuongX);

        
        UPDATE SanPham
        SET SoLuong = SoLuong - p_SoLuongX
        WHERE MaSP = p_MaSP;

        COMMIT;

        p_kq := 0;
    END;

END sp_Xuat;
/
CREATE OR REPLACE PROCEDURE sp_XoaNhanVien (
    p_MaNV IN VARCHAR2,
    p_kq OUT NUMBER
) AS
    v_temp VARCHAR2(10);
BEGIN
    p_kq := 0;


    BEGIN
        SELECT MaNV INTO v_temp
        FROM NhanVien
        WHERE MaNV = p_MaNV;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_kq := 1; 
            RETURN;
    END;

    
    DELETE FROM Nhap
    WHERE SoHDN IN (
        SELECT SoHDN FROM PNhap WHERE MaNV = p_MaNV
    );

   
    DELETE FROM PNhap
    WHERE MaNV = p_MaNV;


    DELETE FROM Xuat
    WHERE SoHDX IN (
        SELECT SoHDX FROM PXuat WHERE MaNV = p_MaNV
    );


    DELETE FROM PXuat
    WHERE MaNV = p_MaNV;

   
    DELETE FROM NhanVien
    WHERE MaNV = p_MaNV;

    COMMIT;

    p_kq := 0;

END sp_XoaNhanVien;
/
CREATE OR REPLACE PROCEDURE sp_XoaSanPham (
    p_MaSP IN VARCHAR2,
    p_kq OUT NUMBER
) AS
    v_temp VARCHAR2(10);
BEGIN
    p_kq := 0;

   
    BEGIN
        SELECT MaSP INTO v_temp
        FROM SanPham
        WHERE MaSP = p_MaSP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_kq := 1; 
            RETURN;
    END;

  
    DELETE FROM Nhap
    WHERE MaSP = p_MaSP;

    DELETE FROM Xuat
    WHERE MaSP = p_MaSP;

   
    DELETE FROM SanPham
    WHERE MaSP = p_MaSP;

    COMMIT;

    p_kq := 0;

END sp_XoaSanPham;
/
CREATE OR REPLACE PROCEDURE sp_ThemNhanVien (
    p_MaNV IN VARCHAR2,
    p_TenNV IN VARCHAR2,
    p_GioiTinh IN VARCHAR2,
    p_DiaChi IN VARCHAR2,
    p_SoDT IN VARCHAR2,
    p_Email IN VARCHAR2,
    p_TenPhong IN VARCHAR2,
    p_Flag IN NUMBER,
    p_KQ OUT NUMBER
) AS
BEGIN
    p_KQ := 0;

   
    IF p_GioiTinh <> 'Nam' AND p_GioiTinh <> 'N?' THEN
        p_KQ := 1;
        RETURN;
    END IF;

    
    IF p_Flag = 0 THEN

        INSERT INTO NhanVien
        VALUES (p_MaNV, p_TenNV, p_GioiTinh, p_DiaChi,
                p_SoDT, p_Email, p_TenPhong);

    ELSE

       
        UPDATE NhanVien
        SET TenNV = p_TenNV,
            GioiTinh = p_GioiTinh,
            DiaChi = p_DiaChi,
            SoDT = p_SoDT,
            Email = p_Email,
            TenPhong = p_TenPhong
        WHERE MaNV = p_MaNV;

    END IF;

    COMMIT;

END sp_ThemNhanVien;
/
CREATE OR REPLACE PROCEDURE sp_ThemMoiSP (
    p_MaSP IN VARCHAR2,
    p_TenHang IN VARCHAR2,
    p_TenSP IN VARCHAR2,
    p_SoLuong IN NUMBER,
    p_MauSac IN VARCHAR2,
    p_GiaBan IN NUMBER,
    p_DonViTinh IN VARCHAR2,
    p_MoTa IN CLOB,
    p_Flag IN NUMBER,
    p_KQ OUT NUMBER
) AS
    v_MaHangSX VARCHAR2(10);
BEGIN
    p_KQ := 0;

    
    BEGIN
        SELECT MaHangSX INTO v_MaHangSX
        FROM HangSX
        WHERE TenHang = p_TenHang;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_KQ := 1; 
            RETURN;
    END;

    
    IF p_SoLuong < 0 THEN
        p_KQ := 2;
        RETURN;
    END IF;

    
    IF p_Flag = 0 THEN

        INSERT INTO SanPham
        VALUES (p_MaSP, v_MaHangSX, p_TenSP, p_SoLuong,
                p_MauSac, p_GiaBan, p_DonViTinh, p_MoTa);

    ELSE

        
        UPDATE SanPham
        SET MaHangSX = v_MaHangSX,
            TenSP = p_TenSP,
            SoLuong = p_SoLuong,
            MauSac = p_MauSac,
            GiaBan = p_GiaBan,
            DonViTinh = p_DonViTinh,
            MoTa = p_MoTa
        WHERE MaSP = p_MaSP;

    END IF;

    COMMIT;

END sp_ThemMoiSP;
/
CREATE OR REPLACE PROCEDURE sp_XoaNhanVien (
    p_MaNV IN VARCHAR2,
    p_KQ OUT NUMBER
) AS
    v_temp VARCHAR2(10);
BEGIN
    p_KQ := 0;

    
    BEGIN
        SELECT MaNV INTO v_temp
        FROM NhanVien
        WHERE MaNV = p_MaNV;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_KQ := 1;
            RETURN;
    END;

   
    DELETE FROM Nhap
    WHERE SoHDN IN (
        SELECT SoHDN FROM PNhap WHERE MaNV = p_MaNV
    );

    
    DELETE FROM PNhap
    WHERE MaNV = p_MaNV;

   
    DELETE FROM Xuat
    WHERE SoHDX IN (
        SELECT SoHDX FROM PXuat WHERE MaNV = p_MaNV
    );

  
    DELETE FROM PXuat
    WHERE MaNV = p_MaNV;

  
    DELETE FROM NhanVien
    WHERE MaNV = p_MaNV;

    COMMIT;

    p_KQ := 0;

END sp_XoaNhanVien;
/
CREATE OR REPLACE PROCEDURE sp_XoaSanPham (
    p_MaSP IN VARCHAR2,
    p_KQ OUT NUMBER
) AS
    v_temp VARCHAR2(10);
BEGIN

    p_KQ := 0;

   
    BEGIN
        SELECT MaSP INTO v_temp
        FROM SanPham
        WHERE MaSP = p_MaSP;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_KQ := 1; 
            RETURN;
    END;

   
    DELETE FROM Nhap
    WHERE MaSP = p_MaSP;

    DELETE FROM Xuat
    WHERE MaSP = p_MaSP;

    
    DELETE FROM SanPham
    WHERE MaSP = p_MaSP;

    COMMIT;

    p_KQ := 0;

END sp_XoaSanPham;
/
CREATE OR REPLACE PROCEDURE sp_NhapHangSX (
    p_MaHangSX IN VARCHAR2,
    p_TenHang IN VARCHAR2,
    p_DiaChi IN VARCHAR2,
    p_SoDT IN VARCHAR2,
    p_Email IN VARCHAR2,
    p_KQ OUT NUMBER
) AS
    v_temp VARCHAR2(10);
BEGIN

    p_KQ := 0;

 
    BEGIN
        SELECT MaHangSX INTO v_temp
        FROM HangSX
        WHERE TenHang = p_TenHang;


        p_KQ := 1;
        RETURN;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

       
        INSERT INTO HangSX
        VALUES (p_MaHangSX, p_TenHang, p_DiaChi, p_SoDT, p_Email);

        COMMIT;

        p_KQ := 0;
    END;

END sp_NhapHangSX;
/
CREATE OR REPLACE PROCEDURE sp_Nhap (
    p_SoHDN IN VARCHAR2,
    p_MaSP IN VARCHAR2,
    p_MaNV IN VARCHAR2,
    p_NgayNhap IN DATE,
    p_SoLuongN IN NUMBER,
    p_DonGiaN IN NUMBER,
    p_KQ OUT NUMBER
) AS
    v_temp VARCHAR2(10);
BEGIN

    p_KQ := 0;

   
    BEGIN
        SELECT MaSP INTO v_temp
        FROM SanPham
        WHERE MaSP = p_MaSP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_KQ := 1;
            RETURN;
    END;

 
    BEGIN
        SELECT MaNV INTO v_temp
        FROM NhanVien
        WHERE MaNV = p_MaNV;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_KQ := 2;
            RETURN;
    END;

    
    BEGIN
        SELECT SoHDN INTO v_temp
        FROM PNhap
        WHERE SoHDN = p_SoHDN;

       
        UPDATE Nhap
        SET SoLuongN = p_SoLuongN,
            DonGiaN = p_DonGiaN
        WHERE SoHDN = p_SoHDN
        AND MaSP = p_MaSP;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

     
        INSERT INTO PNhap
        VALUES (p_SoHDN, p_NgayNhap, p_MaNV);

        INSERT INTO Nhap
        VALUES (p_SoHDN, p_MaSP, p_SoLuongN, p_DonGiaN);
    END;

    COMMIT;
    p_KQ := 0;

END sp_Nhap;
/
CREATE OR REPLACE PROCEDURE sp_Xuat (
    p_SoHDX IN VARCHAR2,
    p_MaSP IN VARCHAR2,
    p_MaNV IN VARCHAR2,
    p_NgayXuat IN DATE,
    p_SoLuongX IN NUMBER,
    p_KQ OUT NUMBER
) AS
    v_temp VARCHAR2(10);
    v_soluong NUMBER;
BEGIN

    p_KQ := 0;

  
    BEGIN
        SELECT SoLuong INTO v_soluong
        FROM SanPham
        WHERE MaSP = p_MaSP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_KQ := 1;
            RETURN;
    END;

   
    BEGIN
        SELECT MaNV INTO v_temp
        FROM NhanVien
        WHERE MaNV = p_MaNV;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_KQ := 2;
            RETURN;
    END;

 
    IF p_SoLuongX > v_soluong THEN
        p_KQ := 3;
        RETURN;
    END IF;

    
    BEGIN
        SELECT SoHDX INTO v_temp
        FROM PXuat
        WHERE SoHDX = p_SoHDX;

       
        UPDATE Xuat
        SET SoLuongX = p_SoLuongX
        WHERE SoHDX = p_SoHDX
        AND MaSP = p_MaSP;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

        
        INSERT INTO PXuat
        VALUES (p_SoHDX, p_NgayXuat, p_MaNV);

        INSERT INTO Xuat
        VALUES (p_SoHDX, p_MaSP, p_SoLuongX);
    END;

    COMMIT;
    p_KQ := 0;

END sp_Xuat;
/