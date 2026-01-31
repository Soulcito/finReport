-- TABLA RDC22 PARA EL TEXTO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'validador'
        AND table_name = 'rdc22_texto'
    ) THEN
        EXECUTE 'DROP TABLE validador.rdc22_texto';
    END IF;
END;
$$;


CREATE TABLE validador.rdc22_texto (
	 linea					    int primary key	
	,registro                   TEXT null
);

-- TABLA RDC22 PARA VALIDAR LOS CAMPOS

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'validador'
        AND table_name = 'rdc22_detalle'
    ) THEN
        EXECUTE 'DROP TABLE validador.rdc22_detalle';
    END IF;
END;
$$;


CREATE TABLE validador.rdc22_detalle (
	 linea						int primary key
	,tipo_obligacion			varchar(2) not null
	,valor_contable				varchar(15) not null
	,filler						varchar(7)	not null
); 

-- TABLA RDC22 PARA VER RESULTADO VALIDACION

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'validador'
        AND table_name = 'rdc22_resultado'
    ) THEN
        EXECUTE 'DROP TABLE validador.rdc22_resultado';
    END IF;
END;
$$;


CREATE TABLE validador.rdc22_resultado (
	 linea						int not null
	,num_validador				int not null
	,descripcion				varchar(2000) not null
	,campo                      varchar(50) not null
	,dato_reportado				varchar(2000) not null
	,status						varchar(10) not null
); 
