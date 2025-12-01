-- TABLA CARTERA_GARANTIAS

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'tmp'
        AND table_name = 'cartera_garantias'
    ) THEN
        EXECUTE 'DROP TABLE tmp.cartera_garantias';
    END IF;
END;
$$;

-- tmp

CREATE TABLE tmp.cartera_garantias (
	 fila                        integer not null 
	,fecha_proceso			    varchar(250) null
	,id_garantia				varchar(250) null
	,rut_garante				varchar(250) null
	,cod_persona				varchar(250) null
	,cod_operacion				varchar(250) null
	,fecha_otorgamiento			varchar(250) null
	,gar_real_inmobiliaria		varchar(250) null			
	,porc_real_inmobiliaria		varchar(250) null
	,gar_real_mobiliaria		varchar(250) null
	,porc_real_mobiliaria		varchar(250) null
	,gar_financiera				varchar(250) null
	,porc_financiera			varchar(250) null
	,gar_personal				varchar(250) null
	,porc_personal				varchar(250) null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'log'
        AND table_name = 'cartera_garantias'
    ) THEN
        EXECUTE 'DROP TABLE log.cartera_garantias';
    END IF;
END;
$$;

-- log

CREATE TABLE log.cartera_garantias (
	 fecha_proceso			    date not null
	,id_garantia				varchar(50) not null
	,rut_garante				varchar(20) not null
	,cod_persona				varchar(50) not null
	,cod_operacion				varchar(50) not null
	,fecha_otorgamiento			date not null
	,gar_real_inmobiliaria		numeric(22,6) not null			
	,porc_real_inmobiliaria		numeric(22,6) not null
	,gar_real_mobiliaria		numeric(22,6) not null
	,porc_real_mobiliaria		numeric(22,6) not null
	,gar_financiera				numeric(22,6) not null
	,porc_financiera			numeric(22,6) not null
	,gar_personal				numeric(22,6) not null
	,porc_personal				numeric(22,6) not null
	,problema                   TEXT null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interface'
        AND table_name = 'cartera_garantias'
    ) THEN
        EXECUTE 'DROP TABLE interface.cartera_garantias';
    END IF;
END;
$$;

-- interface

CREATE TABLE interface.cartera_garantias (
	 fecha_proceso			    date not null
	,id_garantia				varchar(50) not null
	,rut_garante				varchar(20) not null
	,cod_persona				varchar(50) not null
	,cod_operacion				varchar(50) not null
	,fecha_otorgamiento			date not null
	,gar_real_inmobiliaria		numeric(22,6) not null			
	,porc_real_inmobiliaria		numeric(22,6) not null
	,gar_real_mobiliaria		numeric(22,6) not null
	,porc_real_mobiliaria		numeric(22,6) not null
	,gar_financiera				numeric(22,6) not null
	,porc_financiera			numeric(22,6) not null
	,gar_personal				numeric(22,6) not null
	,porc_personal				numeric(22,6) not null
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'historico'
        AND table_name = 'cartera_garantias'
    ) THEN
        EXECUTE 'DROP TABLE historico.cartera_garantias';
    END IF;
END;
$$;

-- historico

CREATE TABLE historico.cartera_garantias (
	 fecha_proceso			    date not null
	,id_garantia				varchar(50) not null
	,rut_garante				varchar(20) not null
	,cod_persona				varchar(50) not null
	,cod_operacion				varchar(50) not null
	,fecha_otorgamiento			date not null
	,gar_real_inmobiliaria		numeric(22,6) not null			
	,porc_real_inmobiliaria		numeric(22,6) not null
	,gar_real_mobiliaria		numeric(22,6) not null
	,porc_real_mobiliaria		numeric(22,6) not null
	,gar_financiera				numeric(22,6) not null
	,porc_financiera			numeric(22,6) not null
	,gar_personal				numeric(22,6) not null
	,porc_personal				numeric(22,6) not null
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'respaldo'
        AND table_name = 'cartera_garantias'
    ) THEN
        EXECUTE 'DROP TABLE respaldo.cartera_garantias';
    END IF;
END;
$$;

-- respaldo

CREATE TABLE respaldo.cartera_garantias (
	 fecha_proceso			    date not null
	,id_garantia				varchar(50) not null
	,rut_garante				varchar(20) not null
	,cod_persona				varchar(50) not null
	,cod_operacion				varchar(50) not null
	,fecha_otorgamiento			date not null
	,gar_real_inmobiliaria		numeric(22,6) not null			
	,porc_real_inmobiliaria		numeric(22,6) not null
	,gar_real_mobiliaria		numeric(22,6) not null
	,porc_real_mobiliaria		numeric(22,6) not null
	,gar_financiera				numeric(22,6) not null
	,porc_financiera			numeric(22,6) not null
	,gar_personal				numeric(22,6) not null
	,porc_personal				numeric(22,6) not null
);


-- LOG historico para cartera_garantias

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'log'
        AND table_name = 'cartera_garantias_hist'
    ) THEN
        EXECUTE 'DROP TABLE log.cartera_garantias_hist';
    END IF;
END;
$$;

-- log historico

CREATE TABLE log.cartera_garantias_hist (
	 fecha_proceso			    date not null
	,id_garantia				varchar(50) not null
	,rut_garante				varchar(20) not null
	,cod_persona				varchar(50) not null
	,cod_operacion				varchar(50) not null
	,fecha_otorgamiento			date not null
	,gar_real_inmobiliaria		numeric(22,6) not null			
	,porc_real_inmobiliaria		numeric(22,6) not null
	,gar_real_mobiliaria		numeric(22,6) not null
	,porc_real_mobiliaria		numeric(22,6) not null
	,gar_financiera				numeric(22,6) not null
	,porc_financiera			numeric(22,6) not null
	,gar_personal				numeric(22,6) not null
	,porc_personal				numeric(22,6) not null
	,problema                   TEXT null
);


