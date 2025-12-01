-- TABLA CARTERA_OPERACIONES

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'tmp'
        AND table_name = 'cartera_operaciones'
    ) THEN
        EXECUTE 'DROP TABLE tmp.cartera_operaciones';
    END IF;
END;
$$;

-- Tabla tmp.cartera_operaciones

CREATE TABLE tmp.cartera_operaciones (
	 fila                       integer not null 
	,fecha_proceso              varchar(250) null
	,rut                        varchar(250) null
	,cod_persona                varchar(250) null
	,cod_operacion              varchar(250) null
	,cod_titulo_3               varchar(250) null
	--,cod_deudor                 varchar(250) null
	,cod_tipo_obligacion        varchar(250) null
	,fecha_otorgamiento         varchar(250) null
	,carga_financiera           varchar(250) null
	,fecha_extincion            varchar(250) null
	--,gar_real_inmobiliaria      varchar(250) null
	--,gar_real_mobiliaria        varchar(250) null
	--,gar_financiera             varchar(250) null
	--,gar_personal               varchar(250) null
	,monto_original             varchar(250) null
	,capital                    varchar(250) null
	,interes                    varchar(250) null
	,otros                      varchar(250) null  
	,cod_moneda                 varchar(250) null 
	,fecha_aceleracion          varchar(250) null
	,deuda_renegociada          varchar(250) null
	,operacion_desfasada        varchar(250) null
	,fecha_a_rectificar         varchar(250) null
	,fecha_rectificacion        varchar(250) null
	,causal_rectificacion       varchar(250) null
	,numero_solicitud           varchar(250) null
	,valor_contable             varchar(250) null
);

--log para cartera_operaciones

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'log'
        AND table_name = 'cartera_operaciones'
    ) THEN
        EXECUTE 'DROP TABLE log.cartera_operaciones';
    END IF;
END;
$$;

-- Tabla log.cartera_operaciones

CREATE TABLE log.cartera_operaciones (
	 fecha_proceso              date not null
	,rut                        varchar(20) not null
	,cod_persona                varchar(50) not null
	,cod_operacion              varchar(50) not null
	,cod_titulo_3               varchar(50) not null
	--,cod_deudor                 varchar(50) not null
	,cod_tipo_obligacion        varchar(50) not null
	,fecha_otorgamiento         date not null
	,carga_financiera           numeric(22,4) not null
	,fecha_extincion            date not null
	--,gar_real_inmobiliaria      numeric(22,4) not null
	--,gar_real_mobiliaria        numeric(22,4) not null
	--,gar_financiera             numeric(22,4) not null
	--,gar_personal               numeric(22,4) not null
	,monto_original             numeric(22,4) not null
	,capital                    numeric(22,4) not null
	,interes                    numeric(22,4) not null
	,otros                      numeric(22,4) not null  
	,cod_moneda                 varchar(50) not null 
	,fecha_aceleracion          date not null
	,deuda_renegociada          varchar(2) not null
	,operacion_desfasada        varchar(2) not null
	,fecha_a_rectificar         date not null
	,fecha_rectificacion        date not null
	,causal_rectificacion       varchar(2) not null
	,numero_solicitud           varchar(50) not null
	,valor_contable             numeric(22,4) not null	
	,problema                   TEXT null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interface'
        AND table_name = 'cartera_operaciones'
    ) THEN
        EXECUTE 'DROP TABLE interface.cartera_operaciones';
    END IF;
END;
$$;

-- Tabla interface.cartera_operaciones

CREATE TABLE interface.cartera_operaciones (
	 fecha_proceso              date not null
	,rut                        varchar(20) not null
	,cod_persona                varchar(50) not null
	,cod_operacion              varchar(50) not null
	,cod_titulo_3               varchar(50) not null
	--,cod_deudor                 varchar(50) not null
	,cod_tipo_obligacion        varchar(50) not null
	,fecha_otorgamiento         date not null
	,carga_financiera           numeric(22,4) not null
	,fecha_extincion            date not null
	--,gar_real_inmobiliaria      numeric(22,4) not null
	--,gar_real_mobiliaria        numeric(22,4) not null
	--,gar_financiera             numeric(22,4) not null
	--,gar_personal               numeric(22,4) not null
	,monto_original             numeric(22,4) not null
	,capital                    numeric(22,4) not null
	,interes                    numeric(22,4) not null
	,otros                      numeric(22,4) not null  
	,cod_moneda                 varchar(50) not null 
	,fecha_aceleracion          date not null
	,deuda_renegociada          varchar(2) not null
	,operacion_desfasada        varchar(2) not null
	,fecha_a_rectificar         date not null
	,fecha_rectificacion        date not null
	,causal_rectificacion       varchar(2) not null
	,numero_solicitud           varchar(50) not null
	,valor_contable             numeric(22,4) not null	
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'historico'
        AND table_name = 'cartera_operaciones'
    ) THEN
        EXECUTE 'DROP TABLE historico.cartera_operaciones';
    END IF;
END;
$$;

-- Tabla historico.cartera_operaciones

CREATE TABLE historico.cartera_operaciones (
	 fecha_proceso              date not null
	,rut                        varchar(20) not null
	,cod_persona                varchar(50) not null
	,cod_operacion              varchar(50) not null
	,cod_titulo_3               varchar(50) not null
	--,cod_deudor                 varchar(50) not null
	,cod_tipo_obligacion        varchar(50) not null
	,fecha_otorgamiento         date not null
	,carga_financiera           numeric(22,4) not null
	,fecha_extincion            date not null
	--,gar_real_inmobiliaria      numeric(22,4) not null
	--,gar_real_mobiliaria        numeric(22,4) not null
	--,gar_financiera             numeric(22,4) not null
	--,gar_personal               numeric(22,4) not null
	,monto_original             numeric(22,4) not null
	,capital                    numeric(22,4) not null
	,interes                    numeric(22,4) not null
	,otros                      numeric(22,4) not null  
	,cod_moneda                 varchar(50) not null 
	,fecha_aceleracion          date not null
	,deuda_renegociada          varchar(2) not null
	,operacion_desfasada        varchar(2) not null
	,fecha_a_rectificar         date not null
	,fecha_rectificacion        date not null
	,causal_rectificacion       varchar(2) not null
	,numero_solicitud           varchar(50) not null
	,valor_contable             numeric(22,4) not null	
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'respaldo'
        AND table_name = 'cartera_operaciones'
    ) THEN
        EXECUTE 'DROP TABLE respaldo.cartera_operaciones';
    END IF;
END;
$$;

-- Tabla respaldo.cartera_operaciones

CREATE TABLE respaldo.cartera_operaciones (
	 fecha_proceso              date not null
	,rut                        varchar(20) not null
	,cod_persona                varchar(50) not null
	,cod_operacion              varchar(50) not null
	,cod_titulo_3               varchar(50) not null
	--,cod_deudor                 varchar(50) not null
	,cod_tipo_obligacion        varchar(50) not null
	,fecha_otorgamiento         date not null
	,carga_financiera           numeric(22,4) not null
	,fecha_extincion            date not null
	--,gar_real_inmobiliaria      numeric(22,4) not null
	--,gar_real_mobiliaria        numeric(22,4) not null
	--,gar_financiera             numeric(22,4) not null
	--,gar_personal               numeric(22,4) not null
	,monto_original             numeric(22,4) not null
	,capital                    numeric(22,4) not null
	,interes                    numeric(22,4) not null
	,otros                      numeric(22,4) not null  
	,cod_moneda                 varchar(50) not null 
	,fecha_aceleracion          date not null
	,deuda_renegociada          varchar(2) not null
	,operacion_desfasada        varchar(2) not null
	,fecha_a_rectificar         date not null
	,fecha_rectificacion        date not null
	,causal_rectificacion       varchar(2) not null
	,numero_solicitud           varchar(50) not null
	,valor_contable             numeric(22,4) not null	
);
