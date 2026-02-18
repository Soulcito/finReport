-- TABLA REGISTRO_CONSENTIMIENTOS

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'tmp'
        AND table_name = 'registro_consentimientos'
    ) THEN
        EXECUTE 'DROP TABLE tmp.registro_consentimientos';
    END IF;
END;
$$;

-- tmp

CREATE TABLE tmp.registro_consentimientos (
	 fila                       	integer not null 
	,fecha_proceso			    	varchar(250) null
	,cod_consentimiento				varchar(250) null
	,fecha_otorgamiento		    	varchar(250) null
	,hora_otorgamiento				varchar(250) null
	,fecha_fin_consentimiento		varchar(250) null
	,hora_fin_consentimiento		varchar(250) null
	,rut_consultado					varchar(250) null
	,cod_medio_consentimiento		varchar(250) null
	,cod_finalidad_consentimiento	varchar(250) null
	,rut_ejecutivo					varchar(250) null
	,cod_objetivo_consentimiento	varchar(250) null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'log'
        AND table_name = 'registro_consentimientos'
    ) THEN
        EXECUTE 'DROP TABLE log.registro_consentimientos';
    END IF;
END;
$$;

-- log

CREATE TABLE log.registro_consentimientos (
	 fecha_proceso			    	date not null
	,cod_consentimiento				varchar(50) not null
	,fecha_otorgamiento		    	date not null
	,hora_otorgamiento				varchar(10) not null
	,fecha_fin_consentimiento		date not null
	,hora_fin_consentimiento		varchar(10) not null
	,rut_consultado					varchar(20) not null
	,cod_medio_consentimiento		varchar(50) not null
	,cod_finalidad_consentimiento	varchar(50) not null
	,rut_ejecutivo					varchar(20) not null
	,cod_objetivo_consentimiento	varchar(50) not null
	,problema                   	TEXT null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interface'
        AND table_name = 'registro_consentimientos'
    ) THEN
        EXECUTE 'DROP TABLE interface.registro_consentimientos';
    END IF;
END;
$$;

-- interface

CREATE TABLE interface.registro_consentimientos (
	 fecha_proceso			    	date not null
	,cod_consentimiento				varchar(50) not null
	,fecha_otorgamiento		    	date not null
	,hora_otorgamiento				varchar(10) not null
	,fecha_fin_consentimiento		date not null
	,hora_fin_consentimiento		varchar(10) not null
	,rut_consultado					varchar(20) not null
	,cod_medio_consentimiento		varchar(50) not null
	,cod_finalidad_consentimiento	varchar(50) not null
	,rut_ejecutivo					varchar(20) not null
	,cod_objetivo_consentimiento	varchar(50) not null
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'historico'
        AND table_name = 'registro_consentimientos'
    ) THEN
        EXECUTE 'DROP TABLE historico.registro_consentimientos';
    END IF;
END;
$$;

-- historico

CREATE TABLE historico.registro_consentimientos (
	 fecha_proceso			    	date not null
	,cod_consentimiento				varchar(50) not null
	,fecha_otorgamiento		    	date not null
	,hora_otorgamiento				varchar(10) not null
	,fecha_fin_consentimiento		date not null
	,hora_fin_consentimiento		varchar(10) not null
	,rut_consultado					varchar(20) not null
	,cod_medio_consentimiento		varchar(50) not null
	,cod_finalidad_consentimiento	varchar(50) not null
	,rut_ejecutivo					varchar(20) not null
	,cod_objetivo_consentimiento	varchar(50) not null
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'respaldo'
        AND table_name = 'registro_consentimientos'
    ) THEN
        EXECUTE 'DROP TABLE respaldo.registro_consentimientos';
    END IF;
END;
$$;

-- respaldo

CREATE TABLE respaldo.registro_consentimientos (
	 fecha_proceso			    	date not null
	,cod_consentimiento				varchar(50) not null
	,fecha_otorgamiento		    	date not null
	,hora_otorgamiento				varchar(10) not null
	,fecha_fin_consentimiento		date not null
	,hora_fin_consentimiento		varchar(10) not null
	,rut_consultado					varchar(20) not null
	,cod_medio_consentimiento		varchar(50) not null
	,cod_finalidad_consentimiento	varchar(50) not null
	,rut_ejecutivo					varchar(20) not null
	,cod_objetivo_consentimiento	varchar(50) not null
);


-- LOG historico

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'log'
        AND table_name = 'registro_consentimientos_hist'
    ) THEN
        EXECUTE 'DROP TABLE log.registro_consentimientos_hist';
    END IF;
END;
$$;

-- log historico

CREATE TABLE log.registro_consentimientos_hist (
	 fecha_proceso			    	date not null
	,cod_consentimiento				varchar(50) not null
	,fecha_otorgamiento		    	date not null
	,hora_otorgamiento				varchar(10) not null
	,fecha_fin_consentimiento		date not null
	,hora_fin_consentimiento		varchar(10) not null
	,rut_consultado					varchar(20) not null
	,cod_medio_consentimiento		varchar(50) not null
	,cod_finalidad_consentimiento	varchar(50) not null
	,rut_ejecutivo					varchar(20) not null
	,cod_objetivo_consentimiento	varchar(50) not null
	,problema                   	TEXT null
);

