-- TABLAS RDC22

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc22_texto'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc22_texto';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc22_texto (
	registro                   TEXT null
);

--PARA EL DETALLE

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc22_detalle'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc22_detalle';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc22_detalle (
     fecha_proceso              date not null
    ,tipo_obligacion			int not null
	,valor_contable				numeric(15) not null
	,tipo_obligacion_interfaz	varchar(50) not null
); 

-- TABLA FINAL

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc22_final'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc22_final';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc22_final (
     tipo_obligacion			int not null
	,valor_contable				numeric(15) not null
); 


-- TABLA HISTORICO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc22_hist'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc22_hist';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc22_hist (
	 fecha_proceso              varchar(8) not null
    ,tipo_obligacion			int not null
	,valor_contable				numeric(15) not null
); 


-- TABLA CARATULA

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc22_caratula'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc22_caratula';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc22_caratula (
	 fecha                   varchar(8) not null
	,item					 varchar(2000) not NULL
	,valor					 numeric(15) not null
);

