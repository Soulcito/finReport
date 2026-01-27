CREATE OR REPLACE PROCEDURE proceso.val_interfaz_b01()
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
			B01-00001: Verifica que las operaciones que se envian en la interfaz cuadro_operaciones, existan en la interfaz cartera_operaciones
		*/

		FOR rec IN 

			SELECT a.*
		    FROM interface.cuadro_operaciones a
		    LEFT JOIN interface.cartera_operaciones b 
		        ON a.cod_operacion = b.cod_operacion
		    WHERE b.cod_operacion IS NULL
		
		LOOP

			INSERT INTO log.cuadro_operaciones (fecha_proceso, cod_operacion, fecha_cuota, capital, capital_pagado, interes_devengado, interes_por_pagar, interes_moroso, interes_pagado, otros, otros_pagado, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.cod_operacion
				,rec.fecha_cuota
				,rec.capital
				,rec.capital_pagado
				,rec.interes_devengado
				,rec.interes_por_pagar
				,rec.interes_moroso
				,rec.interes_pagado
				,rec.otros
				,rec.otros_pagado
				,'B01-00001; cod_operacion: Verifica que las operaciones que se envian en la interfaz cuadro_operaciones, existan en la interfaz cartera_operaciones'
			);

		END LOOP;


		/*
			B01-00002: Valida que las fecha de proceso que se informa en la interfaz, correspondan a la que estan parametrizadas en parametros generales
		*/

		FOR rec IN 

			SELECT a.*
		    FROM interface.cuadro_operaciones a
		    WHERE a.fecha_proceso <> v_fecha
		
		LOOP

			INSERT INTO log.cuadro_operaciones (fecha_proceso, cod_operacion, fecha_cuota, capital, capital_pagado, interes_devengado, interes_por_pagar, interes_moroso, interes_pagado, otros, otros_pagado, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.cod_operacion
				,rec.fecha_cuota
				,rec.capital
				,rec.capital_pagado
				,rec.interes_devengado
				,rec.interes_por_pagar
				,rec.interes_moroso
				,rec.interes_pagado
				,rec.otros
				,rec.otros_pagado
				,'B01-00002; fecha_proceso: Valida que las fecha de proceso que se informa en la interfaz, correspondan a la que estan parametrizadas en parametros generales'
			);

		END LOOP;		
	
		
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.val_interfaz_b01',
			SQLERRM
		);
	END;
END;
$$