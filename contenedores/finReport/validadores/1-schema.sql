-- Creacion de schema validador, usado para todo lo que es proceso de validacion de reportes
DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'validador'
    ) THEN
        EXECUTE 'DROP SCHEMA validador CASCADE';
    END IF;

    EXECUTE 'CREATE SCHEMA validador';
END;
$$;



