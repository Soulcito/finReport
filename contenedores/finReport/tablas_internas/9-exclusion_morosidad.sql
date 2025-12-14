-- TABLA EXCLUSION_MOROSIDAD

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'exclusion_morosidad'
    ) THEN
        EXECUTE 'DROP TABLE interno.exclusion_morosidad';
    END IF;
END;
$$;


CREATE TABLE interno.exclusion_morosidad (
	 cod_operacion				varchar(30) PRIMARY KEY 
	,fecha_exclusion			date	not null
	,dias_morosos				int		not null
);




