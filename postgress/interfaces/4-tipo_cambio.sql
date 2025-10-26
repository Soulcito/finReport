-- TABLA TIPO_CAMBIO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'tmp'
        AND table_name = 'tipo_cambio'
    ) THEN
        EXECUTE 'DROP TABLE tmp.tipo_cambio';
    END IF;
END;
$$;

-- tmp

CREATE TABLE tmp.tipo_cambio (
	 fila                       integer not null 
	,fecha_proceso              varchar(250) null
	,cod_moneda                 varchar(250) null
	,valor                      varchar(250) null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'log'
        AND table_name = 'tipo_cambio'
    ) THEN
        EXECUTE 'DROP TABLE log.tipo_cambio';
    END IF;
END;
$$;

-- log

CREATE TABLE log.tipo_cambio (
	 fila                       integer not null 
	,fecha_proceso              varchar(250) null
	,cod_moneda                 varchar(250) null
	,valor                      varchar(250) null
	,problema                   varchar(2000) null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interface'
        AND table_name = 'tipo_cambio'
    ) THEN
        EXECUTE 'DROP TABLE interface.tipo_cambio';
    END IF;
END;
$$;

-- interface

CREATE TABLE interface.tipo_cambio (
	 fecha_proceso              date not null
	,cod_moneda                 varchar(50) not null
	,valor                      numeric(22,6) not null
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'historico'
        AND table_name = 'tipo_cambio'
    ) THEN
        EXECUTE 'DROP TABLE historico.tipo_cambio';
    END IF;
END;
$$;

-- historico

CREATE TABLE historico.tipo_cambio (
	 fecha_proceso              date not null
	,cod_moneda                 varchar(50) not null
	,valor                      numeric(22,6) not null
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'respaldo'
        AND table_name = 'tipo_cambio'
    ) THEN
        EXECUTE 'DROP TABLE respaldo.tipo_cambio';
    END IF;
END;
$$;

-- respaldo

CREATE TABLE respaldo.tipo_cambio (
	 fecha_proceso              date not null
	,cod_moneda                 varchar(50) not null
	,valor                      numeric(22,6) not null
);
