CREATE OR REPLACE PROCEDURE proceso.val_interfaz_b01()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
	
BEGIN
	BEGIN

		/*
			validacion de operaciones que vienen en cuadro_operaciones y que no estan en la cartera_operciones
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
				,'B01-00001; cod_operacion: No se encuentra operacion en interfaz cartera_operaciones'
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