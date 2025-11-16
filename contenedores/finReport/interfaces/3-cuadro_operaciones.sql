-- TABLA CUADRO_OPERACIONES

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'tmp'
        AND table_name = 'cuadro_operaciones'
    ) THEN
        EXECUTE 'DROP TABLE tmp.cuadro_operaciones';
    END IF;
END;
$$;

-- tmp

CREATE TABLE tmp.cuadro_operaciones (
	 fila                       integer not null 
	,fecha_proceso              varchar(250) null
	,cod_operacion              varchar(250) null
	,fecha_cuota                varchar(250) null
	,capital                    varchar(250) null 
	,capital_pagado             varchar(250) null 
	,interes_devengado          varchar(250) null
	,interes_por_pagar          varchar(250) null
	,interes_moroso             varchar(250) null
	,interes_pagado             varchar(250) null
	,otros                      varchar(250) null 
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'log'
        AND table_name = 'cuadro_operaciones'
    ) THEN
        EXECUTE 'DROP TABLE log.cuadro_operaciones';
    END IF;
END;
$$;

-- log

CREATE TABLE log.cuadro_operaciones (
	 fecha_proceso              date not null
	,cod_operacion              varchar(250) not null
	,fecha_cuota                date not null
	,capital                    numeric(22,4) not null 
	,capital_pagado             numeric(22,4) not null  
	,interes_devengado          numeric(22,4) not null 
	,interes_por_pagar          numeric(22,4) not null 
	,interes_moroso             numeric(22,4) not null 
	,interes_pagado             numeric(22,4) not null 
	,otros                      numeric(22,4) not null 
	,problema 					TEXT null
);


DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'interface'
        AND table_name = 'cuadro_operaciones'
    ) THEN
        EXECUTE 'DROP TABLE interface.cuadro_operaciones';
    END IF;
END;
$$;

-- interface

CREATE TABLE interface.cuadro_operaciones (
	 fecha_proceso              date not null
	,cod_operacion              varchar(250) not null
	,fecha_cuota                date not null
	,capital                    numeric(22,4) not null 
	,capital_pagado             numeric(22,4) not null  
	,interes_devengado          numeric(22,4) not null 
	,interes_por_pagar          numeric(22,4) not null 
	,interes_moroso             numeric(22,4) not null 
	,interes_pagado             numeric(22,4) not null 
	,otros                      numeric(22,4) not null 
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'historico'
        AND table_name = 'cuadro_operaciones'
    ) THEN
        EXECUTE 'DROP TABLE historico.cuadro_operaciones';
    END IF;
END;
$$;

-- historico

CREATE TABLE historico.cuadro_operaciones (
	 fecha_proceso              date not null
	,cod_operacion              varchar(250) not null
	,fecha_cuota                date not null
	,capital                    numeric(22,4) not null 
	,capital_pagado             numeric(22,4) not null  
	,interes_devengado          numeric(22,4) not null 
	,interes_por_pagar          numeric(22,4) not null 
	,interes_moroso             numeric(22,4) not null 
	,interes_pagado             numeric(22,4) not null 
	,otros                      numeric(22,4) not null
);

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'respaldo'
        AND table_name = 'cuadro_operaciones'
    ) THEN
        EXECUTE 'DROP TABLE respaldo.cuadro_operaciones';
    END IF;
END;
$$;

-- respaldo

CREATE TABLE respaldo.cuadro_operaciones (
	 fecha_proceso              date not null
	,cod_operacion              varchar(250) not null
	,fecha_cuota                date not null
	,capital                    numeric(22,4) not null 
	,capital_pagado             numeric(22,4) not null  
	,interes_devengado          numeric(22,4) not null 
	,interes_por_pagar          numeric(22,4) not null 
	,interes_moroso             numeric(22,4) not null 
	,interes_pagado             numeric(22,4) not null 
	,otros                      numeric(22,4) not null
);
