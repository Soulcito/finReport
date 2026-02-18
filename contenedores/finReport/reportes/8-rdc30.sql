-- TABLA RDC30 PARA EL TEXTO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc30_texto'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc30_texto';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc30_texto (
	registro                   TEXT null
);

-- TABLA RDC30 PARA EL DETALLE

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc30_detalle'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc30_detalle';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc30_detalle (
	 fecha_proceso					date not null	
	,cod_consentimiento				varchar(20) not null
	,fecha_otorgamiento				date not null
	,hora_otorgamiento				varchar(6) not null
	,fecha_fin_consentimiento		date not null
	,hora_fin_consentimiento		varchar(6) not null
	,rut_consultado					varchar(10) not null
	,cod_medio_consentimiento		varchar(1) not null
	,cod_finalidad_consentimiento	varchar(1) not null
	,rut_ejecutivo					varchar(10) not null
	,cod_objetivo_consentimiento	varchar(2) not null
); 


-- TABLA RDC30 FINAL

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc30_final'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc30_final';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc30_final (
	 cod_consentimiento				varchar(20) not null
	,fecha_otorgamiento				varchar(8) not null
	,hora_otorgamiento				varchar(6) not null
	,fecha_fin_consentimiento		varchar(8) not null
	,hora_fin_consentimiento		varchar(6) not null
	,rut_consultado					varchar(10) not null
	,cod_medio_consentimiento		varchar(1) not null
	,cod_finalidad_consentimiento	varchar(1) not null
	,rut_ejecutivo					varchar(10) not null
	,cod_objetivo_consentimiento	varchar(2) not null
); 




-- TABLA RDC30 HISTORICO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc30_hist'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc30_hist';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc30_hist (
	 fecha_proceso              	varchar(8) not null
	,cod_consentimiento				varchar(20) not null
	,fecha_otorgamiento				varchar(8) not null
	,hora_otorgamiento				varchar(6) not null
	,fecha_fin_consentimiento		varchar(8) not null
	,hora_fin_consentimiento		varchar(6) not null
	,rut_consultado					varchar(10) not null
	,cod_medio_consentimiento		varchar(1) not null
	,cod_finalidad_consentimiento	varchar(1) not null
	,rut_ejecutivo					varchar(10) not null
	,cod_objetivo_consentimiento	varchar(2) not null
); 



-- TABLA RDC30 PARA LA CARATULA

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc30_caratula'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc30_caratula';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc30_caratula (
	 fecha                   varchar(8) not null
	,item					 varchar(2000) not NULL
	,valor					 numeric(15) not null
);

