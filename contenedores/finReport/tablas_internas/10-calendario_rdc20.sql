-- TABLA CALENDARIO_RDC20

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'calendario_rdc20'
    ) THEN
        EXECUTE 'DROP TABLE interno.calendario_rdc20';
    END IF;
END;
$$;


CREATE TABLE interno.calendario_rdc20 (
	 fecha				varchar(8) PRIMARY KEY 
);




