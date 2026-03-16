CREATE TABLE Mathang (
Mahang VARCHAR2(5) CONSTRAINT pk_mathang PRIMARY KEY,
Tenhang VARCHAR2(50) NOT NULL,
Soluong NUMBER(10)
);
CREATE TABLE Nhatkybanhang (
Stt NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
Ngay DATE,
Nguoimua VARCHAR2(50),
Mahang VARCHAR2(5) REFERENCES Mathang(Mahang),
Soluong NUMBER(10),
Giaban NUMBER(15,2)
);
-- D? li?u m?u Mathang
INSERT INTO Mathang VALUES ('1','Hang A', 100);
INSERT INTO Mathang VALUES ('2','Hang B', 200);
INSERT INTO Mathang VALUES ('3','Hang C', 150);
COMMIT;
CREATE OR REPLACE TRIGGER trg_nhatkybanhang_insert
AFTER INSERT ON Nhatkybanhang
FOR EACH ROW
BEGIN
    UPDATE Mathang
    SET Soluong = Soluong - :NEW.Soluong
    WHERE Mahang = :NEW.Mahang;
END;
/
CREATE OR REPLACE TRIGGER trg_nhatkybanhang_update_soluong
AFTER UPDATE OF Soluong ON Nhatkybanhang
FOR EACH ROW
BEGIN
    UPDATE Mathang
    SET Soluong = Soluong - (:NEW.Soluong - :OLD.Soluong)
    WHERE Mahang = :NEW.Mahang;
END;
/
CREATE OR REPLACE TRIGGER trg_check_insert
BEFORE INSERT ON Nhatkybanhang
FOR EACH ROW
DECLARE
    v_soluong NUMBER;
BEGIN
    SELECT Soluong INTO v_soluong
    FROM Mathang
    WHERE Mahang = :NEW.Mahang;

    IF :NEW.Soluong > v_soluong THEN
        RAISE_APPLICATION_ERROR(-20001, 'Khong du hang trong kho');
    ELSE
        UPDATE Mathang
        SET Soluong = Soluong - :NEW.Soluong
        WHERE Mahang = :NEW.Mahang;
    END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_update_limit
FOR UPDATE ON Nhatkybanhang
COMPOUND TRIGGER

    v_count NUMBER := 0;

BEFORE EACH ROW IS
BEGIN
    v_count := v_count + 1;
END BEFORE EACH ROW;

AFTER STATEMENT IS
BEGIN
    IF v_count > 1 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Khong duoc update nhieu dong');
    END IF;
END AFTER STATEMENT;

END;
/
CREATE OR REPLACE TRIGGER trg_delete_limit
FOR DELETE ON Nhatkybanhang
COMPOUND TRIGGER

    v_count NUMBER := 0;

BEFORE EACH ROW IS
BEGIN
    v_count := v_count + 1;

    UPDATE Mathang
    SET Soluong = Soluong + :OLD.Soluong
    WHERE Mahang = :OLD.Mahang;
END BEFORE EACH ROW;

AFTER STATEMENT IS
BEGIN
    IF v_count > 1 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Khong duoc xoa nhieu dong');
    END IF;
END AFTER STATEMENT;

END;
/
CREATE OR REPLACE TRIGGER trg_update_advanced
FOR UPDATE ON Nhatkybanhang
COMPOUND TRIGGER

    v_count NUMBER := 0;

BEFORE EACH ROW IS
    v_soluong NUMBER;
BEGIN
    v_count := v_count + 1;

    SELECT Soluong INTO v_soluong
    FROM Mathang
    WHERE Mahang = :OLD.Mahang;

    IF :NEW.Soluong < v_soluong THEN
        RAISE_APPLICATION_ERROR(-20004, 'So luong cap nhat khong hop le');
    ELSIF :NEW.Soluong = v_soluong THEN
        RAISE_APPLICATION_ERROR(-20005, 'Khong can cap nhat');
    ELSE
        UPDATE Mathang
        SET Soluong = Soluong - (:NEW.Soluong - :OLD.Soluong)
        WHERE Mahang = :OLD.Mahang;
    END IF;

END BEFORE EACH ROW;

AFTER STATEMENT IS
BEGIN
    IF v_count > 1 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Chi duoc update 1 dong');
    END IF;
END AFTER STATEMENT;

END;
/
CREATE OR REPLACE PROCEDURE sp_xoa_mathang(p_mahang VARCHAR2)
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Mathang
    WHERE Mahang = p_mahang;

    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Khong ton tai mahang');
    ELSE
        DELETE FROM Nhatkybanhang
        WHERE Mahang = p_mahang;

        DELETE FROM Mathang
        WHERE Mahang = p_mahang;

        DBMS_OUTPUT.PUT_LINE('Da xoa thanh cong');
    END IF;
END;
/
CREATE OR REPLACE FUNCTION fn_tongtien(p_tenhang VARCHAR2)
RETURN NUMBER
IS
    v_tong NUMBER;
BEGIN
    SELECT SUM(n.Soluong * n.Giaban)
    INTO v_tong
    FROM Nhatkybanhang n
    JOIN Mathang m ON n.Mahang = m.Mahang
    WHERE m.Tenhang = p_tenhang;

    RETURN NVL(v_tong, 0);
END;
/