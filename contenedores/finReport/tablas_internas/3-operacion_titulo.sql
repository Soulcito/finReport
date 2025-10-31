-- TABLA OPERACION_TITULO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'operacion_titulo_rel'
    ) THEN
        EXECUTE 'DROP TABLE interno.operacion_titulo_rel';
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
        AND table_name = 'operacion_titulo'
    ) THEN
        EXECUTE 'DROP TABLE interno.operacion_titulo';
    END IF;
END;
$$;

CREATE TABLE interno.operacion_titulo (
	 cod                        varchar(2) PRIMARY KEY 
	,descripcion                varchar(1000) not null
);

CREATE TABLE interno.operacion_titulo_rel (
	 cod_entidad                varchar(50) PRIMARY KEY
	,cod_operacional            varchar(2) not null
	,foreign key(cod_operacional) references interno.operacion_titulo(cod) ON DELETE CASCADE
);


