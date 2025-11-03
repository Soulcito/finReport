
-- TABLA INTERFAZ_MANAGER

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'interfaz_manager'
    ) THEN
        EXECUTE 'DROP TABLE interno.interfaz_manager';
    END IF;
END;
$$;


CREATE TABLE interno.interfaz_manager (
	 id                        integer PRIMARY KEY 
	,interfaz                  varchar(1000) not null
	,campo                     varchar(1000) not null
	,tipo_dato                 varchar(20) not null
);



