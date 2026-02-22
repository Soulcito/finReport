-- TABLA ACCESO_CONSENTIMIENTOS

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'tmp'
        AND table_name = 'acceso_consentimientos'
    ) THEN
        EXECUTE 'DROP TABLE tmp.acceso_consentimientos';
    END IF;
END;
$$;

-- tmp

CREATE TABLE tmp.acceso_consentimientos (
	 fila                       	integer not null 
	,fecha_proceso			    	varchar(250) null
	,cod_consentimiento				varchar(250) null
	,fecha_acceso			    	varchar(250) null
	,hora_acceso					varchar(250) null
	,rut_mandatario					varchar(250) null

);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'log'
        AND table_name = 'acceso_consentimientos'
    ) THEN
        EXECUTE 'DROP TABLE log.acceso_consentimientos';
    END IF;
END;
$$;

-- log

CREATE TABLE log.acceso_consentimientos (
	 fecha_proceso			    	date not null
	,cod_consentimiento				varchar(50) not null
	,fecha_acceso			    	date not null
	,hora_acceso					varchar(10) not null
	,rut_mandatario					varchar(20) not null
	,problema                   	TEXT null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interface'
        AND table_name = 'acceso_consentimientos'
    ) THEN
        EXECUTE 'DROP TABLE interface.acceso_consentimientos';
    END IF;
END;
$$;

-- interface

CREATE TABLE interface.acceso_consentimientos (
	 fecha_proceso			    	date not null
	,cod_consentimiento				varchar(50) not null
	,fecha_acceso			    	date not null
	,hora_acceso					varchar(10) not null
	,rut_mandatario					varchar(20) not null
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'historico'
        AND table_name = 'acceso_consentimientos'
    ) THEN
        EXECUTE 'DROP TABLE historico.acceso_consentimientos';
    END IF;
END;
$$;

-- historico

CREATE TABLE historico.acceso_consentimientos (
	 fecha_proceso			    	date not null
	,cod_consentimiento				varchar(50) not null
	,fecha_acceso			    	date not null
	,hora_acceso					varchar(10) not null
	,rut_mandatario					varchar(20) not null
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'respaldo'
        AND table_name = 'acceso_consentimientos'
    ) THEN
        EXECUTE 'DROP TABLE respaldo.acceso_consentimientos';
    END IF;
END;
$$;

-- respaldo

CREATE TABLE respaldo.acceso_consentimientos (
	 fecha_proceso			    	date not null
	,cod_consentimiento				varchar(50) not null
	,fecha_acceso			    	date not null
	,hora_acceso					varchar(10) not null
	,rut_mandatario					varchar(20) not null
);


-- LOG historico

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'log'
        AND table_name = 'acceso_consentimientos_hist'
    ) THEN
        EXECUTE 'DROP TABLE log.acceso_consentimientos_hist';
    END IF;
END;
$$;

-- log historico

CREATE TABLE log.acceso_consentimientos_hist (
	 fecha_proceso			    	date not null
	,cod_consentimiento				varchar(50) not null
	,fecha_acceso			    	date not null
	,hora_acceso					varchar(10) not null
	,rut_mandatario					varchar(20) not null
	,problema                   	TEXT null
);

