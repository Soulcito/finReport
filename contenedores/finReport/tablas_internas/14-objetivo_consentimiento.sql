-- TABLA OBJETIVO_CONSENTIMIENTO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'objetivo_consentimiento_rel'
    ) THEN
        EXECUTE 'DROP TABLE interno.objetivo_consentimiento_rel';
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
        AND table_name = 'objetivo_consentimiento'
    ) THEN
        EXECUTE 'DROP TABLE interno.objetivo_consentimiento';
    END IF;
END;
$$;

CREATE TABLE interno.objetivo_consentimiento (
	 cod                        varchar(2) PRIMARY KEY 
	,descripcion                varchar(1000) not null
);

CREATE TABLE interno.objetivo_consentimiento_rel (
	 cod_entidad                varchar(50) PRIMARY KEY
	,cod_objetivo         		varchar(2) not null
	,foreign key(cod_objetivo) references interno.objetivo_consentimiento(cod) ON DELETE CASCADE
);


