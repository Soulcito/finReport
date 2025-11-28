-- TABLA RDC01 PARA EL TEXTO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc01_texto'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc01_texto';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc01_texto (
	registro                   TEXT null
);

-- TABLA RDC01 PARA EL DETALLE

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc01_detalle'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc01_detalle';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc01_detalle (
     fecha_proceso              date not null
	,rut    					varchar(10) not null
	,tipo_persona				int not null
	,codigo_operacion   		varchar(30) not null
	,operacion_titulo			int not null
	,tipo_deudor				int not null
	,tipo_obligacion			int not null
	,fecha_otorgamiento			varchar(8) not null
	,carga_financiera			numeric(15) not null
	,fecha_extincion			varchar(8) not null
	,valor_gtia_inmobiliaria	numeric(15) not null
	,valor_gtia_mobiliaria		numeric(15) not null
	,valor_gtia_financiera		numeric(15) not null
	,valor_gtia_personal		numeric(15) not null
	,monto_original				numeric(15) not null
	,monto_actual				numeric(15) not null
	,monto_al_dia				numeric(15) not null
	,monto_mora_1_tramo			numeric(15) not null
	,monto_mora_2_tramo			numeric(15) not null
	,monto_mora_3_tramo			numeric(15) not null
	,monto_mora_4_tramo			numeric(15) not null
	,monto_mora_5_tramo			numeric(15) not null
	,monto_mora_6_tramo			numeric(15) not null
	,monto_mora_7_tramo			numeric(15) not null
	,monto_mora_8_tramo			numeric(15) not null
	,monto_mora_9_tramo			numeric(15) not null
	,mora_actual				int not null
	,deuda_renegociada			int not null
	,deuda_acelerada			int not null
	,tipo_persona_interfaz		varchar(50) not null
	,operacion_titulo_interfaz	varchar(50) not null
	,tipo_obligacion_interfaz	varchar(50) not null
	,fecha_primera_cuota_inpaga varchar(8)  not null
	,cod_moneda                 varchar(50) not null
	,tipo_cambio				numeric(22,6) not null
); 


-- TABLA RDC01 FINAL

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc01_final'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc01_final';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc01_final (
	 rut    					varchar(10) not null
	,tipo_persona				int not null
	,codigo_operacion   		varchar(30) not null
	,operacion_titulo			int not null
	,tipo_deudor				int not null
	,tipo_obligacion			int not null
	,fecha_otorgamiento			varchar(8) not null
	,carga_financiera			numeric(15) not null
	,fecha_extincion			varchar(8) not null
	,valor_gtia_inmobiliaria	numeric(15) not null
	,valor_gtia_mobiliaria		numeric(15) not null
	,valor_gtia_financiera		numeric(15) not null
	,valor_gtia_personal		numeric(15) not null
	,monto_original				numeric(15) not null
	,monto_actual				numeric(15) not null
	,monto_al_dia				numeric(15) not null
	,monto_mora_1_tramo			numeric(15) not null
	,monto_mora_2_tramo			numeric(15) not null
	,monto_mora_3_tramo			numeric(15) not null
	,monto_mora_4_tramo			numeric(15) not null
	,monto_mora_5_tramo			numeric(15) not null
	,monto_mora_6_tramo			numeric(15) not null
	,monto_mora_7_tramo			numeric(15) not null
	,monto_mora_8_tramo			numeric(15) not null
	,monto_mora_9_tramo			numeric(15) not null
	,mora_actual				int not null
	,deuda_renegociada			int not null
	,deuda_acelerada			int not null
); 




-- TABLA RDC01 HISTORICO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'reporte'
        AND table_name = 'rdc01_hist'
    ) THEN
        EXECUTE 'DROP TABLE reporte.rdc01_hist';
    END IF;
END;
$$;


CREATE TABLE reporte.rdc01_hist (
	 fecha_proceso              varchar(8) not null
	,rut    					varchar(10) not null
	,tipo_persona				int not null
	,codigo_operacion   		varchar(30) not null
	,operacion_titulo			int not null
	,tipo_deudor				int not null
	,tipo_obligacion			int not null
	,fecha_otorgamiento			varchar(8) not null
	,carga_financiera			numeric(15) not null
	,fecha_extincion			varchar(8) not null
	,valor_gtia_inmobiliaria	numeric(15) not null
	,valor_gtia_mobiliaria		numeric(15) not null
	,valor_gtia_financiera		numeric(15) not null
	,valor_gtia_personal		numeric(15) not null
	,monto_original				numeric(15) not null
	,monto_actual				numeric(15) not null
	,monto_al_dia				numeric(15) not null
	,monto_mora_1_tramo			numeric(15) not null
	,monto_mora_2_tramo			numeric(15) not null
	,monto_mora_3_tramo			numeric(15) not null
	,monto_mora_4_tramo			numeric(15) not null
	,monto_mora_5_tramo			numeric(15) not null
	,monto_mora_6_tramo			numeric(15) not null
	,monto_mora_7_tramo			numeric(15) not null
	,monto_mora_8_tramo			numeric(15) not null
	,monto_mora_9_tramo			numeric(15) not null
	,mora_actual				int not null
	,deuda_renegociada			int not null
	,deuda_acelerada			int not null
); 


