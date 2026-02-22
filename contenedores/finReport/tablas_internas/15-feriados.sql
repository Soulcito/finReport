
-- TABLA FERIADOS

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'feriados'
    ) THEN
        EXECUTE 'DROP TABLE interno.feriados';
    END IF;
END;
$$;

CREATE TABLE interno.feriados (
	 fecha                        varchar(8) PRIMARY KEY 
);






