-- TABLA VARIACION_STOCK

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'tmp'
        AND table_name = 'variacion_stock'
    ) THEN
        EXECUTE 'DROP TABLE tmp.variacion_stock';
    END IF;
END;
$$;

-- tmp

CREATE TABLE tmp.variacion_stock (
	 fila                       integer not null 
	,fecha_proceso			    varchar(250) null
	,cod_operacion				varchar(250) null
	,tipo_flujo				    varchar(250) null
	,fecha_efectivo_flujo		varchar(250) null
	,ident_tribunal				varchar(250) null
	--,monto						varchar(250) null
	,rut_tercera_parte			varchar(250) null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'log'
        AND table_name = 'variacion_stock'
    ) THEN
        EXECUTE 'DROP TABLE log.variacion_stock';
    END IF;
END;
$$;

-- log

CREATE TABLE log.variacion_stock (
	 fecha_proceso			    date not null
	,cod_operacion				varchar(50) not null
	,tipo_flujo				    varchar(50) not null
	,fecha_efectivo_flujo		date not null
	,ident_tribunal				varchar(50) not null
	--,monto						numeric(22,6) not null
	,rut_tercera_parte			varchar(20) not null
	,problema                   TEXT null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interface'
        AND table_name = 'variacion_stock'
    ) THEN
        EXECUTE 'DROP TABLE interface.variacion_stock';
    END IF;
END;
$$;

-- interface

CREATE TABLE interface.variacion_stock (
	 fecha_proceso			    date not null
	,cod_operacion				varchar(50) not null
	,tipo_flujo				    varchar(50) not null
	,fecha_efectivo_flujo		date not null
	,ident_tribunal				varchar(50) not null
	--,monto						numeric(22,6) not null
	,rut_tercera_parte			varchar(20) not null
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'historico'
        AND table_name = 'variacion_stock'
    ) THEN
        EXECUTE 'DROP TABLE historico.variacion_stock';
    END IF;
END;
$$;

-- historico

CREATE TABLE historico.variacion_stock (
	 fecha_proceso			    date not null
	,cod_operacion				varchar(50) not null
	,tipo_flujo				    varchar(50) not null
	,fecha_efectivo_flujo		date not null
	,ident_tribunal				varchar(50) not null
	--,monto						numeric(22,6) not null
	,rut_tercera_parte			varchar(20) not null
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'respaldo'
        AND table_name = 'variacion_stock'
    ) THEN
        EXECUTE 'DROP TABLE respaldo.variacion_stock';
    END IF;
END;
$$;

-- respaldo

CREATE TABLE respaldo.variacion_stock (
	 fecha_proceso			    date not null
	,cod_operacion				varchar(50) not null
	,tipo_flujo				    varchar(50) not null
	,fecha_efectivo_flujo		date not null
	,ident_tribunal				varchar(50) not null
	--,monto						numeric(22,6) not null
	,rut_tercera_parte			varchar(20) not null
);


-- LOG historico

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'log'
        AND table_name = 'variacion_stock_hist'
    ) THEN
        EXECUTE 'DROP TABLE log.variacion_stock_hist';
    END IF;
END;
$$;

-- log historico

CREATE TABLE log.variacion_stock_hist (
	 fecha_proceso			    date not null
	,cod_operacion				varchar(50) not null
	,tipo_flujo				    varchar(50) not null
	,fecha_efectivo_flujo		date not null
	,ident_tribunal				varchar(50) not null
	--,monto						numeric(22,6) not null
	,rut_tercera_parte			varchar(20) not null
	,problema                   TEXT null
);


