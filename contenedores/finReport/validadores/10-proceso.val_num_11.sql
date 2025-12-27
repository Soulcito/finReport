CREATE OR REPLACE FUNCTION proceso.val_num_11(valor varchar)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
	cuerpo varchar;
	signo  varchar;
BEGIN
    /*****************************************************************************/
    
	/*  Campo con signo no corresponde, signo debe ir al final       			 */
    
	/*****************************************************************************/

	-- 1) Null explicito y minimo para validar

	if valor is null or length(valor) < 2 then
		return 'NOOK';
	end if;

	-- 2) Obtencion del cuerpo y signo

	cuerpo := substring(valor, 1, length(valor) - 1);
	signo := substring(valor, length(valor), 1);

	-- 2) Validacion cuerpo

	if cuerpo !~ '^[0-9]+$' then
		return 'NOOK';
	end if;	

	-- 3) Validacion signo

	if signo NOT IN ('+','-') then
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
            'proceso.val_num_11',
            SQLERRM
        );

        RETURN 'ERROR';
END;
$$;
