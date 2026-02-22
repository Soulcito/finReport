-- TABLA RDC31 PARA EL TEXTO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc31_texto'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc31_texto';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc31_texto (
	registro                   TEXT null
);

-- TABLA RDC31 PARA EL DETALLE

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc31_detalle'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc31_detalle';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc31_detalle (
	 fecha_proceso					date not null	
	,cod_consentimiento				varchar(20) not null
	,fecha_acceso					date not null
	,hora_acceso					varchar(6) not null
	,rut_mandatario					varchar(10) not null
); 


-- TABLA RDC31 FINAL

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc31_final'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc31_final';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc31_final (
	 cod_consentimiento				varchar(20) not null
	,fecha_acceso					varchar(8) not null
	,hora_acceso					varchar(6) not null
	,rut_mandatario					varchar(10) not null	
); 




-- TABLA RDC31 HISTORICO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc31_hist'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc31_hist';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc31_hist (
	 fecha_proceso              	varchar(8) not null
	,cod_consentimiento				varchar(20) not null
	,fecha_acceso					varchar(8) not null
	,hora_acceso					varchar(6) not null
	,rut_mandatario					varchar(10) not null
); 



-- TABLA RDC31 PARA LA CARATULA

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc31_caratula'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc31_caratula';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc31_caratula (
	 fecha                   varchar(8) not null
	,item					 varchar(2000) not NULL
	,valor					 numeric(15) not null
);

