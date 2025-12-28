CREATE OR REPLACE FUNCTION proceso.val_num_16(valor varchar, largo int)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
BEGIN
    /*****************************************************************************/
    
	/*  Filler debe ser completado con espacios						   			 */
    
	/*****************************************************************************/

	-- 1) Null explicito

	if valor is null then
		return 'NOOK';
	end if;

	if length(valor) <> largo then
		return 'NOOK';
	end if;

	-- 2) Validacion 

	if trim(valor) <> '' then
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
            'proceso.val_num_16',
            SQLERRM
        );

        RETURN 'ERROR';
END;
$$;
