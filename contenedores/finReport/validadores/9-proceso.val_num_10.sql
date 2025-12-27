CREATE OR REPLACE FUNCTION proceso.val_num_10(valor varchar)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
BEGIN
    /*****************************************************************************/
    
	/*  Campo reportado debe ser numerico y rellenado con 0 a la izquierda       */
    
	/*****************************************************************************/

	-- 1) Null explicito

	if valor is null then
		return 'NOOK';
	end if;

	-- 2) Validacion

	if valor !~ '^[0-9]+$' then
		return 'NOOK';
	end if;	

	return 'OK';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error durante el proceso: %', SQLERRM;

        INSERT INTO log.log_eventos (
            fecha, nivel, dag, procedimiento, mensaje
        )
        VALUES (
            CURRENT_TIMESTAMP,
            'ERROR',
            '',
            'proceso.val_num_10',
            SQLERRM
        );

        RETURN 'ERROR';
END;
$$;
