-- TABLAS RDC20

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc20_texto'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc20_texto';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc20_texto (
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
        AND table_name = 'rdc20_detalle_1'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc20_detalle_1';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc20_detalle_1 (
     fecha_proceso              date not null
	,tipo_registro				int not null
    ,tipo_obligacion			int not null
	,tipo_flujo					int not null
	,monto						numeric(20) not null
	,cod_operacion              varchar(30) not null
	,rut						varchar(10) not null	
	,cod_tipo_obligacion		varchar(50) not null
); 


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc20_detalle_2'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc20_detalle_2';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc20_detalle_2 (
     fecha_proceso              date not null
	,tipo_registro				int not null
	,rut_deudor					varchar(10)	not null
	,codigo_operacion			varchar(30) not null
	,fecha_informacion			varchar(8) not null
    ,tipo_obligacion			int not null
	,ident_tribunal				int not null
	,monto						numeric(20) not null
	,cod_tipo_obligacion		varchar(50) not null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc20_detalle_3'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc20_detalle_3';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc20_detalle_3 (
     fecha_proceso              date not null
	,tipo_registro				int not null
	,rut_comprador				varchar(10)	not null
	,rut_deudor					varchar(10)	not null
	,codigo_operacion			varchar(30) not null
	,fecha_informacion			varchar(8) not null
    ,tipo_obligacion			int not null
	,monto						numeric(20) not null
	,cod_tipo_obligacion		varchar(50) not null
);



DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc20_detalle_4'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc20_detalle_4';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc20_detalle_4 (
     fecha_proceso              date not null
	,tipo_registro				int not null
	,rut_vendedor				varchar(10)	not null
	,rut_deudor					varchar(10)	not null
	,codigo_operacion			varchar(30) not null
	,fecha_informacion			varchar(8) not null
    ,tipo_obligacion			int not null
	,monto						numeric(20) not null
	,cod_tipo_obligacion		varchar(50) not null
);






-- TABLA FINAL

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc20_final_1'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc20_final_1';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc20_final_1 (
	 tipo_registro				int not null
    ,tipo_obligacion			int not null
	,tipo_flujo					int not null
	,monto						numeric(20) not null
); 


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc20_final_2'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc20_final_2';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc20_final_2 (
	 tipo_registro				int not null
	,rut_deudor					varchar(10)	not null
	,codigo_operacion			varchar(30) not null
	,fecha_informacion			varchar(8) not null
    ,tipo_obligacion			int not null
	,ident_tribunal				int not null
	,monto						numeric(20) not null
); 


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc20_final_3'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc20_final_3';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc20_final_3 (
	 tipo_registro				int not null
	,rut_comprador				varchar(10)	not null
	,rut_deudor					varchar(10)	not null
	,codigo_operacion			varchar(30) not null
	,fecha_informacion			varchar(8) not null
    ,tipo_obligacion			int not null
	,monto						numeric(20) not null
);



DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc20_final_4'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc20_final_4';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc20_final_4 (
	 tipo_registro				int not null
	,rut_vendedor				varchar(10)	not null
	,rut_deudor					varchar(10)	not null
	,codigo_operacion			varchar(30) not null
	,fecha_informacion			varchar(8) not null
    ,tipo_obligacion			int not null
	,monto						numeric(20) not null
);



-- TABLA HISTORICO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc20_hist_1'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc20_hist_1';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc20_hist_1 (
	 fecha_proceso              varchar(8) not null
	,tipo_registro				int not null
    ,tipo_obligacion			int not null
	,tipo_flujo					int not null
	,monto						numeric(20) not null
); 


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc20_hist_2'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc20_hist_2';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc20_hist_2 (
	 fecha_proceso              varchar(8) not null
	,tipo_registro				int not null
	,rut_deudor					varchar(10)	not null
	,codigo_operacion			varchar(30) not null
	,fecha_informacion			varchar(8) not null
    ,tipo_obligacion			int not null
	,ident_tribunal				int not null
	,monto						numeric(20) not null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc20_hist_3'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc20_hist_3';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc20_hist_3 (
	 fecha_proceso              varchar(8) not null
	,tipo_registro				int not null
	,rut_comprador				varchar(10)	not null
	,rut_deudor					varchar(10)	not null
	,codigo_operacion			varchar(30) not null
	,fecha_informacion			varchar(8) not null
    ,tipo_obligacion			int not null
	,monto						numeric(20) not null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc20_hist_4'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc20_hist_4';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc20_hist_4 (
	 fecha_proceso				varchar(8) not null	
	,tipo_registro				int not null
	,rut_vendedor				varchar(10)	not null
	,rut_deudor					varchar(10)	not null
	,codigo_operacion			varchar(30) not null
	,fecha_informacion			varchar(8) not null
    ,tipo_obligacion			int not null
	,monto						numeric(20) not null
);


-- TABLA CARATULA

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc20_caratula'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc20_caratula';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc20_caratula (
	 fecha                   varchar(8) not null
	,item					 varchar(2000) not NULL
	,valor					 numeric(15) not null
);

