-- TABLA MEDIO_CONSENTIMIENTO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'medio_consentimiento_rel'
    ) THEN
        EXECUTE 'DROP TABLE interno.medio_consentimiento_rel';
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
        AND table_name = 'medio_consentimiento'
    ) THEN
        EXECUTE 'DROP TABLE interno.medio_consentimiento';
    END IF;
END;
$$;

CREATE TABLE interno.medio_consentimiento (
	 cod                        varchar(2) PRIMARY KEY 
	,descripcion                varchar(1000) not null
);

CREATE TABLE interno.medio_consentimiento_rel (
	 cod_entidad                varchar(50) PRIMARY KEY
	,cod_consentimiento         varchar(2) not null
	,foreign key(cod_consentimiento) references interno.medio_consentimiento(cod) ON DELETE CASCADE
);


