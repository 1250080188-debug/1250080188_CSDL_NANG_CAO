CREATE TABLE hang (
    mahang VARCHAR2(10) PRIMARY KEY,
    tenhang VARCHAR2(50),
    soluong NUMBER,
    giaban NUMBER
);

CREATE TABLE hoadon (
    mahd NUMBER PRIMARY KEY,
    mahang VARCHAR2(10),
    soluongban NUMBER,
    ngayban DATE,
    CONSTRAINT fk_hoadon_hang FOREIGN KEY (mahang)
    REFERENCES hang(mahang)
);
CREATE OR REPLACE TRIGGER trg_insert_hoadon
BEFORE INSERT ON hoadon
FOR EACH ROW
DECLARE
    v_soluong hang.soluong%TYPE;
BEGIN
    
    SELECT soluong INTO v_soluong
    FROM hang
    WHERE mahang = :NEW.mahang;

  
    IF v_soluong < :NEW.soluongban THEN
        RAISE_APPLICATION_ERROR(-20001, 'Khong du so luong ton');
    END IF;

    
    UPDATE hang
    SET soluong = soluong - :NEW.soluongban
    WHERE mahang = :NEW.mahang;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Ma hang khong ton tai');
END;
/
CREATE OR REPLACE TRIGGER trg_delete_hoadon
AFTER DELETE ON hoadon
FOR EACH ROW
BEGIN
    UPDATE hang
    SET soluong = soluong + :OLD.soluongban
    WHERE mahang = :OLD.mahang;
END;
/
CREATE OR REPLACE TRIGGER trg_update_hoadon
BEFORE UPDATE ON hoadon
FOR EACH ROW
BEGIN
    UPDATE hang
    SET soluong = soluong - (:NEW.soluongban - :OLD.soluongban)
    WHERE mahang = :NEW.mahang;
END;
/