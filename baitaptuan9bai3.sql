CREATE TABLE Lophoc (
    Malop VARCHAR2(10) PRIMARY KEY,
    Tenlop NVARCHAR2(100),
    Sisotoida NUMBER,
    Sisohientai NUMBER DEFAULT 0
);

CREATE TABLE Dangky (
    Madk NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Masv VARCHAR2(10),
    Malop VARCHAR2(10),
    Ngaydangky DATE
);
CREATE OR REPLACE TRIGGER trg_Insert_Dangky
BEFORE INSERT ON Dangky
FOR EACH ROW
DECLARE
    v_count NUMBER;
    v_siso NUMBER;
    v_max NUMBER;
BEGIN
    
    SELECT COUNT(*) INTO v_count
    FROM Lophoc
    WHERE Malop = :NEW.Malop;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'L?p không t?n t?i!');
    END IF;

    
    SELECT COUNT(*) INTO v_count
    FROM Dangky
    WHERE Masv = :NEW.Masv AND Malop = :NEW.Malop;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Sinh viên ?ã ??ng ký l?p này!');
    END IF;

  
    SELECT Sisohientai, Sisotoida INTO v_siso, v_max
    FROM Lophoc
    WHERE Malop = :NEW.Malop;
    
    IF v_siso >= v_max THEN
        RAISE_APPLICATION_ERROR(-20003, 'L?p ?ã ??y!');
    END IF;

   
    UPDATE Lophoc
    SET Sisohientai = Sisohientai + 1
    WHERE Malop = :NEW.Malop;
END;
INSERT INTO Lophoc VALUES ('L01', 'Lop 1', 2, 0);

INSERT INTO Dangky(Masv, Malop, Ngaydangky)
VALUES ('SV01', 'L01', SYSDATE);
CREATE OR REPLACE TRIGGER trg_Delete_Dangky
AFTER DELETE ON Dangky
FOR EACH ROW
BEGIN
    UPDATE Lophoc
    SET Sisohientai = Sisohientai - 1
    WHERE Malop = :OLD.Malop;
END;
DELETE FROM Dangky WHERE Masv = 'SV01';
CREATE OR REPLACE TRIGGER trg_Update_Dangky
BEFORE UPDATE OF Malop ON Dangky
FOR EACH ROW
DECLARE
    v_count NUMBER;
    v_siso NUMBER;
    v_max NUMBER;
BEGIN
   
    SELECT COUNT(*) INTO v_count
    FROM Lophoc
    WHERE Malop = :NEW.Malop;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'L?p m?i không t?n t?i!');
    END IF;


    SELECT COUNT(*) INTO v_count
    FROM Dangky
    WHERE Masv = :NEW.Masv AND Malop = :NEW.Malop;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Sinh viên ?ã ? l?p m?i!');
    END IF;


    SELECT Sisohientai, Sisotoida INTO v_siso, v_max
    FROM Lophoc
    WHERE Malop = :NEW.Malop;

    IF v_siso >= v_max THEN
        RAISE_APPLICATION_ERROR(-20006, 'L?p m?i ?ã ??y!');
    END IF;

   
    UPDATE Lophoc
    SET Sisohientai = Sisohientai - 1
    WHERE Malop = :OLD.Malop;

  
    UPDATE Lophoc
    SET Sisohientai = Sisohientai + 1
    WHERE Malop = :NEW.Malop;
END;