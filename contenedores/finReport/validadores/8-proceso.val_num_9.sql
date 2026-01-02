CREATE OR REPLACE FUNCTION proceso.val_num_9(fecha varchar)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
	cod_var		date;
BEGIN
    /*************************************************************/
    
	/*  Fecha reportada no corresponde al formato YYYYMMDD       */
    
	/*************************************************************/

	-- 1) Null explicito

	if fecha is null then
		return 'NOOK';
	end if;

	-- 2) Largo y formato basico

	if length(fecha) <> 8 or fecha !~ '^[0-9]{8}$' then
		return 'NOOK';
	end if;	

	-- 3) Conversion y validacion
	
	BEGIN
		cod_var := to_date(fecha, 'YYYYMMDD');
	EXCEPTION
		WHEN OTHERS THEN
		-- Fecha invalida
		RETURN 'NOOK';
	END;

	if to_char(cod_var, 'YYYYMMDD') = fecha then
		return 'OK';
	else
		return 'NOOK';
	end if;

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
            'proceso.val_num_9',
            SQLERRM
        );

        RETURN 'ERROR';
END;
$$;
