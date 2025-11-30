CREATE OR REPLACE PROCEDURE proceso.val_interfaz_c01()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
	
BEGIN
	BEGIN

		/*
			validacion de codigo de moneda no vengan duplicadas en la interfaz tipo de cambio
		*/

		FOR rec IN 

			SELECT a.*
		    FROM interface.tipo_cambio a 
		    INNER JOIN 
			   (
				 select cod_moneda, count(cod_moneda) as "cantidad" from interface.tipo_cambio
				 group by cod_moneda
				 having count(cod_moneda) > 1
			   ) as b on a.cod_moneda = b.cod_moneda
		
		LOOP

			INSERT INTO log.tipo_cambio (fecha_proceso, cod_moneda, valor, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.cod_moneda
				,rec.valor
				,'C01-00001; cod_moneda: Codigo de moneda viene mas de una ves en la interfaz'
			);

		END LOOP;
	
		
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.val_interfaz_c01',
			SQLERRM
		);
	END;
END;
$$