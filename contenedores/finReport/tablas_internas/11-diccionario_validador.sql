-- TABLA DICCIONARIO VALIDADOR

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interno'
        AND table_name = 'diccionario_validador'
    ) THEN
        EXECUTE 'DROP TABLE interno.diccionario_validador';
    END IF;
END;
$$;


CREATE TABLE interno.diccionario_validador (
	  num_validador				 int PRIMARY KEY
	 ,descripcion                varchar(2000) NOT NULL
	 ,tipo						 varchar(20) NOT NULL
	 ,archivo					 varchar(50) NOT NULL
);




