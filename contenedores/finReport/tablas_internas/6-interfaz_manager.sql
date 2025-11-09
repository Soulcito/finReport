
-- TABLA INTERFAZ

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'interfaz_rel'
    ) THEN
        EXECUTE 'DROP TABLE interno.interfaz_rel';
    END IF;
END;
$$;

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'interfaz'
    ) THEN
        EXECUTE 'DROP TABLE interno.interfaz';
    END IF;
END;
$$;

CREATE TABLE interno.interfaz (
	 cod                        varchar(10) PRIMARY KEY 
	,interfaz                   varchar(50) not null
	,msi                        varchar(250) not null                
);

CREATE TABLE interno.interfaz_rel (
	 id                        integer PRIMARY KEY 
	,cod                       varchar(10) not null
	,campo                     varchar(1000) not null
	,tipo_dato                 varchar(20) not null
	,foreign key(cod) references interno.interfaz(cod) ON DELETE CASCADE
);




