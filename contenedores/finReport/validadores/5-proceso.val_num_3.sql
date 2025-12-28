CREATE OR REPLACE FUNCTION proceso.val_num_3(registro text, largo int)
RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
		cod_var int;	
BEGIN

		/***********************************************/

		/*  Largo del registro no corresponde          */

		/***********************************************/

		-- 1) Valida NULL y largo minimo

		if registro IS NULL 
			or largo IS NULL 
			or largo < 1 then
			
			return 'NOOK';
			
		end if;

		-- 2) Validacion
		
		cod_var := length(registro);

		if cod_var = largo then
			return 'OK';
		else
			return 'NOOK';
		end if;

	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.val_num_3',
			SQLERRM
		);

		RETURN 'ERROR';
END;
$$;