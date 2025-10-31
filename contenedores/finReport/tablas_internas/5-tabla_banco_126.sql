
-- TABLA TABLA_BANCO_126

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'tabla_banco_126_rel'
    ) THEN
        EXECUTE 'DROP TABLE interno.tabla_banco_126_rel';
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
        AND table_name = 'tabla_banco_126'
    ) THEN
        EXECUTE 'DROP TABLE interno.tabla_banco_126';
    END IF;
END;
$$;

CREATE TABLE interno.tabla_banco_126 (
	 cod                        varchar(10) PRIMARY KEY 
	,tipo_operacion             varchar(1000) not null
);

CREATE TABLE interno.tabla_banco_126_rel (
	 cod_entidad                varchar(50) PRIMARY KEY
	,cod_obligacion             varchar(10) not null
	,foreign key(cod_obligacion) references interno.tabla_banco_126(cod) ON DELETE CASCADE
);


