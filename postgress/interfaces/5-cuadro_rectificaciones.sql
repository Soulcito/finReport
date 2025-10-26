-- TABLA CUADRO_RECTIFICACIONES

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
		
        FROM information_schema.tables
        WHERE table_schema = 'tmp'
        AND table_name = 'cuadro_rectificaciones'
    ) THEN
        EXECUTE 'DROP TABLE tmp.cuadro_rectificaciones';
    END IF;
END;
$$;

-- tmp

CREATE TABLE tmp.cuadro_rectificaciones (
	 fila                       integer not null
	,fecha_proceso              varchar(250) null 
	,fecha_a_rectificar         varchar(250) null
	,cod_operacion              varchar(250) null
	,causal_eliminacion         varchar(250) null
	,campo_rdc01                varchar(250) null
	,valor                      varchar(250) null
	,fecha_rectificacion        varchar(250) null
	,causal_rectificacion       varchar(250) null
	,numero_solicitud           varchar(250) null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'log'
        AND table_name = 'cuadro_rectificaciones'
    ) THEN
        EXECUTE 'DROP TABLE log.cuadro_rectificaciones';
    END IF;
END;
$$;

-- log

CREATE TABLE log.cuadro_rectificaciones (
	 fila                       integer not null 
	,fecha_proceso              varchar(250) null 
	,fecha_a_rectificar         varchar(250) null
	,cod_operacion              varchar(250) null
	,causal_eliminacion         varchar(250) null
	,campo_rdc01                varchar(250) null
	,valor                      varchar(250) null
	,fecha_rectificacion        varchar(250) null
	,causal_rectificacion       varchar(250) null
	,numero_solicitud           varchar(250) null
	,problema                   varchar(2000) null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interface'
        AND table_name = 'cuadro_rectificaciones'
    ) THEN
        EXECUTE 'DROP TABLE interface.cuadro_rectificaciones';
    END IF;
END;
$$;

-- interface

CREATE TABLE interface.cuadro_rectificaciones (
	 fecha_proceso              date not null 
	,fecha_a_rectificar         date not null
	,cod_operacion              varchar(50) not null
	,causal_eliminacion         integer not null
	,campo_rdc01                integer not null
	,valor                      varchar(250) not null
	,fecha_rectificacion        date not null
	,causal_rectificacion       integer not null
	,numero_solicitud           varchar(1000) not null
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'historico'
        AND table_name = 'cuadro_rectificaciones'
    ) THEN
        EXECUTE 'DROP TABLE historico.cuadro_rectificaciones';
    END IF;
END;
$$;

-- historico

CREATE TABLE historico.cuadro_rectificaciones (
	 fecha_proceso              date not null 
	,fecha_a_rectificar         date not null
	,cod_operacion              varchar(50) not null
	,causal_eliminacion         integer not null
	,campo_rdc01                integer not null
	,valor                      varchar(250) not null
	,fecha_rectificacion        date not null
	,causal_rectificacion       integer not null
	,numero_solicitud           varchar(1000) not null
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'respaldo'
        AND table_name = 'cuadro_rectificaciones'
    ) THEN
        EXECUTE 'DROP TABLE respaldo.cuadro_rectificaciones';
    END IF;
END;
$$;

-- respaldo

CREATE TABLE respaldo.cuadro_rectificaciones (
	 fecha_proceso              date not null 
	,fecha_a_rectificar         date not null
	,cod_operacion              varchar(50) not null
	,causal_eliminacion         integer not null
	,campo_rdc01                integer not null
	,valor                      varchar(250) not null
	,fecha_rectificacion        date not null
	,causal_rectificacion       integer not null
	,numero_solicitud           varchar(1000) not null
);
