
-- Creacion de schema interno, usado para las tablas internas
DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'interno'
    ) THEN
        EXECUTE 'DROP SCHEMA interno CASCADE';
    END IF;

    EXECUTE 'CREATE SCHEMA interno';
END;
$$;
