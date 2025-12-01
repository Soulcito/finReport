-- TABLA LOG_EVENTOS

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'log'
        AND table_name = 'log_eventos'
    ) THEN
        EXECUTE 'DROP TABLE log.log_eventos';
    END IF;
END;
$$;


CREATE TABLE log.log_eventos (
    id SERIAL PRIMARY KEY,
    fecha TIMESTAMP,
    nivel VARCHAR(10),
	dag varchar(50),
	procedimiento varchar(50),
    mensaje TEXT
);



-- TABLA LOG_EVENTOS HISTORICO

DO
$$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'log'
        AND table_name = 'log_eventos_hist'
    ) THEN
        EXECUTE 'DROP TABLE log.log_eventos_hist';
    END IF;
END;
$$;


CREATE TABLE log.log_eventos_hist (
    id SERIAL PRIMARY KEY,
	fecha_proceso date, 
	fecha_ejecucion date,
    fecha TIMESTAMP,
    nivel VARCHAR(10),
	dag varchar(50),
	procedimiento varchar(50),
    mensaje TEXT
);

