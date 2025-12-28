CREATE OR REPLACE FUNCTION proceso.val_num_1(cod_inst varchar)
RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
		cod_var varchar;	
BEGIN

		/********************************/

		/*   Valida codigo institucion  */

		/********************************/

		-- 1) Valida NULL

		if cod_inst IS NULL then
			return 'NOOK';
		end if;

		-- 2) Obtencion codigo 
		
		select LPAD(valor,10,'0')
		into cod_var
		from interno.parametros_generales where cod = '1';

		-- 3) Validar existencia del parametro

		if cod_var IS NULL then
			RAISE EXCEPTION 'Codigo institucional COD=1 en interno.parametros_generales no encontrado';
		end if;
		

		-- 4) Validacion

		if cod_var = cod_inst then
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
			'proceso.val_num_1',
			SQLERRM
		);

		RETURN 'ERROR';
END;
$$;