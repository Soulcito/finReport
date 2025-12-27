CREATE OR REPLACE FUNCTION proceso.val_num_2(archivo varchar, pos_inicial int, largo int, registro text)
RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
		cod_var varchar;	
BEGIN

		/***********************************************/

		/*  Identificacion del archivo no corresponde  */

		/***********************************************/

		-- 1) Validacion de NULL

		if archivo IS NULL or pos_inicial IS NULL or largo IS NULL or registro IS NULL then
			return 'NOOK';
		end if;

		-- 2) Valida rangos basicos

		if pos_inicial < 1 
			or largo < 1 
			or pos_inicial > length(registro) 
			or (pos_inicial + largo - 1) > length(registro) then
			
			return 'NOOK';
			
		end if;

		-- 3) Validacion
		
		cod_var := substring(registro, pos_inicial, largo);

		if cod_var = archivo then
			RETURN 'OK';
		else
			RETURN 'NOOK';
		end if;

	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.val_num_2',
			SQLERRM
		);

		RETURN 'ERROR';
END;
$$;