-- TABLA TIPO_PERSONA

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'tipo_persona_rel'
    ) THEN
        EXECUTE 'DROP TABLE interno.tipo_persona_rel';
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
        AND table_name = 'tipo_persona'
    ) THEN
        EXECUTE 'DROP TABLE interno.tipo_persona';
    END IF;
END;
$$;

CREATE TABLE interno.tipo_persona (
	 cod                        varchar(2) PRIMARY KEY 
	,descripcion                varchar(1000) not null
);

CREATE TABLE interno.tipo_persona_rel (
	 cod_entidad                varchar(50) PRIMARY KEY
	,cod_persona                varchar(2) not null
	,foreign key(cod_persona) references interno.tipo_persona(cod) ON DELETE CASCADE
);


