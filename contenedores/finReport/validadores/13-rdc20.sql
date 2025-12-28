-- TABLA RDC20 PARA EL TEXTO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'validador'
        AND table_name = 'rdc20_texto'
    ) THEN
        EXECUTE 'DROP TABLE validador.rdc20_texto';
    END IF;
END;
$$;


CREATE TABLE validador.rdc20_texto (
	 linea					    int primary key	
	,registro                   TEXT null
);

-- TABLA RDC20 PARA VALIDAR LOS CAMPOS

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'validador'
        AND table_name = 'rdc20_detalle_1'
    ) THEN
        EXECUTE 'DROP TABLE validador.rdc20_detalle_1';
    END IF;
END;
$$;


CREATE TABLE validador.rdc20_detalle_1 (
	 linea						int primary key
	,tipo_registro				varchar(2) not null
	,tipo_obligacion			varchar(2) not null
	,tipo_flujo					varchar(2) not null
	,monto						varchar(21) not null
	,filler						varchar(55)	not null
); 


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'validador'
        AND table_name = 'rdc20_detalle_2'
    ) THEN
        EXECUTE 'DROP TABLE validador.rdc20_detalle_2';
    END IF;
END;
$$;


CREATE TABLE validador.rdc20_detalle_2 (
	 linea						int primary key
	,tipo_registro				varchar(2) not null
	,rut_deudor					varchar(10) not null
	,codigo_operacion			varchar(30) not null
	,fecha_informacion			varchar(8) not null
	,tipo_obligacion			varchar(2) not null
	,ident_tribunal				varchar(7) not null
	,monto						varchar(20) not null
	,filler						varchar(3)	not null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'validador'
        AND table_name = 'rdc20_detalle_3'
    ) THEN
        EXECUTE 'DROP TABLE validador.rdc20_detalle_3';
    END IF;
END;
$$;


CREATE TABLE validador.rdc20_detalle_3 (
	 linea						int primary key
	,tipo_registro				varchar(2) not null
	,rut_comprador				varchar(10) not null
	,rut_deudor					varchar(10) not null
	,codigo_operacion			varchar(30) not null
	,fecha_informacion			varchar(8) not null
	,tipo_obligacion			varchar(2) not null
	,monto						varchar(20) not null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'validador'
        AND table_name = 'rdc20_detalle_4'
    ) THEN
        EXECUTE 'DROP TABLE validador.rdc20_detalle_4';
    END IF;
END;
$$;


CREATE TABLE validador.rdc20_detalle_4 (
	 linea						int primary key
	,tipo_registro				varchar(2) not null
	,rut_vendedor				varchar(10) not null
	,rut_deudor					varchar(10) not null
	,codigo_operacion			varchar(30) not null
	,fecha_informacion			varchar(8) not null
	,tipo_obligacion			varchar(2) not null
	,monto						varchar(20) not null
);

-- TABLA RDC20 PARA VER RESULTADO VALIDACION

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'validador'
        AND table_name = 'rdc20_resultado'
    ) THEN
        EXECUTE 'DROP TABLE validador.rdc20_resultado';
    END IF;
END;
$$;


CREATE TABLE validador.rdc20_resultado (
	 linea						int not null
	,num_validador				int not null
	,tipo_registro				varchar(10)	 not null
	,campo                      varchar(50) not null
	,dato_reportado				varchar(2000) not null
	,status						varchar(10) not null
); 
