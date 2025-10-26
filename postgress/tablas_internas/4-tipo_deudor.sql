-- TABLA TIPO_DEUDOR

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'tipo_deudor_rel'
    ) THEN
        EXECUTE 'DROP TABLE interno.tipo_deudor_rel';
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
        AND table_name = 'tipo_deudor'
    ) THEN
        EXECUTE 'DROP TABLE interno.tipo_deudor';
    END IF;
END;
$$;

CREATE TABLE interno.tipo_deudor (
	 cod                        varchar(2) PRIMARY KEY 
	,descripcion                varchar(1000) not null
);

CREATE TABLE interno.tipo_deudor_rel (
	 cod_entidad                varchar(50) PRIMARY KEY
	,cod_deudor                 varchar(2) not null
	,foreign key(cod_deudor) references interno.tipo_deudor(cod) ON DELETE CASCADE
);


