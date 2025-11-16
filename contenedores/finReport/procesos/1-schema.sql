
-- Creacion de schema proceso, usado para todo lo que es proceso como funciones o procedimientos almacenados
DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'proceso'
    ) THEN
        EXECUTE 'DROP SCHEMA proceso CASCADE';
    END IF;

    EXECUTE 'CREATE SCHEMA proceso';
END;
$$;

-- Creacion de schema validaciones, usado para todo lo que tenga que ver con validaciones de interfaces y reportes
DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'valida'
    ) THEN
        EXECUTE 'DROP SCHEMA valida CASCADE';
    END IF;

    EXECUTE 'CREATE SCHEMA valida';
END;
$$;

