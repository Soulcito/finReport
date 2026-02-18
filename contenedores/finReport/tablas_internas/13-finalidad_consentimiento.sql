-- TABLA FINALIDAD_CONSENTIMIENTO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'finalidad_consentimiento_rel'
    ) THEN
        EXECUTE 'DROP TABLE interno.finalidad_consentimiento_rel';
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
        AND table_name = 'finalidad_consentimiento'
    ) THEN
        EXECUTE 'DROP TABLE interno.finalidad_consentimiento';
    END IF;
END;
$$;

CREATE TABLE interno.finalidad_consentimiento (
	 cod                        varchar(2) PRIMARY KEY 
	,descripcion                varchar(1000) not null
);

CREATE TABLE interno.finalidad_consentimiento_rel (
	 cod_entidad                varchar(50) PRIMARY KEY
	,cod_finalidad         		varchar(2) not null
	,foreign key(cod_finalidad) references interno.finalidad_consentimiento(cod) ON DELETE CASCADE
);


