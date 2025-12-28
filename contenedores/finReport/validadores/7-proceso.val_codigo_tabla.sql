CREATE OR REPLACE FUNCTION proceso.val_codigo_tabla(
    codigo varchar,
    tabla  regclass
)
RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
    dummy int;
	v_sql text;
BEGIN

	/******************************************************/
    
	/*  Validacion generica de codigo en tablas internas  */
    
	/******************************************************/

    -- 1) Validar NULL
    
	IF codigo IS NULL THEN
        RETURN 'NOOK';
    END IF;

    -- 2) Validar existencia del codigo en la tabla indicada

	v_sql := format('SELECT 1 FROM %s WHERE cod = $1', tabla);

	EXECUTE v_sql
    INTO dummy
    USING codigo;

	IF dummy IS NOT NULL THEN
       RETURN 'OK';
    END IF;

    RETURN 'NOOK';

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO log.log_eventos (
            fecha, nivel, dag, procedimiento, mensaje
        )
        VALUES (
            CURRENT_TIMESTAMP,
            'ERROR',
            '',
            'proceso.val_codigo_tabla',
            SQLERRM
        );

        RETURN 'ERROR';
END;
$$;
