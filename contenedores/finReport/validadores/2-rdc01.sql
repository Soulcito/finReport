-- TABLA RDC01 PARA EL TEXTO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'validador'
        AND table_name = 'rdc01_texto'
    ) THEN
        EXECUTE 'DROP TABLE validador.rdc01_texto';
    END IF;
END;
$$;


CREATE TABLE validador.rdc01_texto (
	 linea					    int primary key	
	,registro                   TEXT null
);

-- TABLA RDC01 PARA VALIDAR LOS CAMPOS

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'validador'
        AND table_name = 'rdc01_detalle'
    ) THEN
        EXECUTE 'DROP TABLE validador.rdc01_detalle';
    END IF;
END;
$$;


CREATE TABLE validador.rdc01_detalle (
	 linea						int primary key
	,rut    					varchar(10) not null
	,tipo_persona				varchar(1) not null
	,codigo_operacion   		varchar(30) not null
	,operacion_titulo			varchar(1) not null
	,tipo_deudor				varchar(1) not null
	,tipo_obligacion			varchar(2) not null
	,fecha_otorgamiento			varchar(8) not null
	,carga_financiera			varchar(15) not null
	,fecha_extincion			varchar(8) not null
	,valor_gtia_inmobiliaria	varchar(15) not null
	,valor_gtia_mobiliaria		varchar(15) not null
	,valor_gtia_financiera		varchar(15) not null
	,valor_gtia_personal		varchar(15) not null
	,monto_original				varchar(15) not null
	,monto_actual				varchar(15) not null
	,monto_al_dia				varchar(15) not null
	,monto_mora_1_tramo			varchar(15) not null
	,monto_mora_2_tramo			varchar(15) not null
	,monto_mora_3_tramo			varchar(15) not null
	,monto_mora_4_tramo			varchar(15) not null
	,monto_mora_5_tramo			varchar(15) not null
	,monto_mora_6_tramo			varchar(15) not null
	,monto_mora_7_tramo			varchar(15) not null
	,monto_mora_8_tramo			varchar(15) not null
	,monto_mora_9_tramo			varchar(15) not null
	,mora_actual				varchar(4) not null
	,deuda_renegociada			varchar(1) not null
	,deuda_acelerada			varchar(1) not null
); 

-- TABLA RDC01 PARA VER RESULTADO VALIDACION

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'validador'
        AND table_name = 'rdc01_resultado'
    ) THEN
        EXECUTE 'DROP TABLE validador.rdc01_resultado';
    END IF;
END;
$$;


CREATE TABLE validador.rdc01_resultado (
	 linea						int not null
	,num_validador				int not null
	,campo                      varchar(50) not null
	,dato_reportado				varchar(2000) not null
	,status						varchar(10) not null
); 
