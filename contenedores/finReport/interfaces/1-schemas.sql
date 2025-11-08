
-- Creacion de schema interface, usado para las interfaces
DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'interface'
    ) THEN
        EXECUTE 'DROP SCHEMA interface CASCADE';
    END IF;

    EXECUTE 'CREATE SCHEMA interface';
END;
$$;

-- Creacion de schema temporal, usado para la carga de interfaces
DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'tmp'
    ) THEN
        EXECUTE 'DROP SCHEMA tmp CASCADE';
    END IF;

    EXECUTE 'CREATE SCHEMA tmp';
END;
$$;

-- Creacion de schema log, usado para los logs
DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'log'
    ) THEN
        EXECUTE 'DROP SCHEMA log CASCADE';
    END IF;

    EXECUTE 'CREATE SCHEMA log';
END;
$$;

-- Creacion de schema historico, usado para almacenar la historia de los datos
DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'historico'
    ) THEN
        EXECUTE 'DROP SCHEMA historico CASCADE';
    END IF;

    EXECUTE 'CREATE SCHEMA historico';
END;
$$;

-- Creacion de schema respaldo, usado para almacenar el respaldo de los datos
DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'respaldo'
    ) THEN
        EXECUTE 'DROP SCHEMA respaldo CASCADE';
    END IF;

    EXECUTE 'CREATE SCHEMA respaldo';
END;
$$;

