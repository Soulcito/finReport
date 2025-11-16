-- TABLA RDC01 PARA EL TEXTO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc01_texto'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc01_texto';
    END IF;
END;
$$;

-- Tabla reporte.rdc01_texto

CREATE TABLE reporte.rdc01_texto (
	registro                   TEXT null
);