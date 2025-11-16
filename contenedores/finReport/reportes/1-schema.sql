-- Creacion de schema reporte, usado para todo lo que es proceso de generacion de reportes
DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'reporte'
    ) THEN
        EXECUTE 'DROP SCHEMA reporte CASCADE';
    END IF;

    EXECUTE 'CREATE SCHEMA reporte';
END;
$$;



