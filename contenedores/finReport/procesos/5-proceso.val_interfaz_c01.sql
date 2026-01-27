CREATE OR REPLACE PROCEDURE proceso.val_interfaz_c01()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
	v_fecha date;
	
BEGIN
	BEGIN

		/* Obtencion de fecha de proceso */

		select to_date(valor,'YYYYMMDD')
		into v_fecha
		from interno.parametros_generales where cod = '3';

		/*
			C01-00001: Verifica que el codigo de moneda no venga duplicado en la interfaz tipo_cambio
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
				,'C01-00001; cod_moneda: Verifica que el codigo de moneda no venga duplicado en la interfaz tipo_cambio'
			);

		END LOOP;


		/*
			C01-00002: Valida que las fecha de proceso que se informa en la interfaz, correspondan a la que estan parametrizadas en parametros generales
		*/

		FOR rec IN 

			SELECT a.*
		    FROM interface.tipo_cambio a 
			WHERE a.fecha_proceso <> v_fecha	
		
		LOOP

			INSERT INTO log.tipo_cambio (fecha_proceso, cod_moneda, valor, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.cod_moneda
				,rec.valor
				,'C01-00002; fecha_proceso: Valida que las fecha de proceso que se informa en la interfaz, correspondan a la que estan parametrizadas en parametros generales'
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