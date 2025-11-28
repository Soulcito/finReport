
-- TABLA PARAMETROS GENERALES

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'parametros_generales'
    ) THEN
        EXECUTE 'DROP TABLE interno.parametros_generales';
    END IF;
END;
$$;

CREATE TABLE interno.parametros_generales (
	 cod                        varchar(10) PRIMARY KEY 
	,descripcion                varchar(2000) not null
	,valor                      varchar(250) not null                
);






