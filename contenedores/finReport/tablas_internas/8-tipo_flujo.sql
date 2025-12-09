-- TABLA TIPO_FLUJO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'tipo_flujo_rel'
    ) THEN
        EXECUTE 'DROP TABLE interno.tipo_flujo_rel';
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
        AND table_name = 'tipo_flujo'
    ) THEN
        EXECUTE 'DROP TABLE interno.tipo_flujo';
    END IF;
END;
$$;

CREATE TABLE interno.tipo_flujo (
	 cod                        varchar(2) PRIMARY KEY 
	,descripcion                varchar(1000) not null
);

CREATE TABLE interno.tipo_flujo_rel (
	 cod_entidad                varchar(50) PRIMARY KEY
	,cod_flujo                  varchar(2) not null
	,foreign key(cod_flujo) references interno.tipo_flujo(cod) ON DELETE CASCADE
);


