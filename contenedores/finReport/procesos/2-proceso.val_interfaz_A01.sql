CREATE OR REPLACE PROCEDURE proceso.val_interfaz_a01()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
	
BEGIN
	BEGIN

		/*
			A01-00001: Validacion de campo cod_persona si existe en la tabla relacion interno.tipo_persona_rel
		*/

		FOR rec IN 

			SELECT a.*
		    FROM interface.cartera_operaciones a
		    LEFT JOIN interno.tipo_persona_rel b 
		        ON a.cod_persona = b.cod_entidad
		    WHERE b.cod_entidad IS NULL
		
		LOOP

			INSERT INTO log.cartera_operaciones (fecha_proceso, rut, cod_persona, cod_operacion, cod_titulo_3, cod_tipo_obligacion, fecha_otorgamiento, carga_financiera, fecha_extincion, monto_original, capital, interes, otros, cod_moneda, fecha_aceleracion, deuda_renegociada, operacion_desfasada, fecha_a_rectificar, fecha_rectificacion, causal_rectificacion, numero_solicitud, valor_contable, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.rut
				,rec.cod_persona
				,rec.cod_operacion
				,rec.cod_titulo_3
				,rec.cod_tipo_obligacion
				,rec.fecha_otorgamiento
				,rec.carga_financiera
				,rec.fecha_extincion
				,rec.monto_original
				,rec.capital
				,rec.interes
				,rec.otros
				,rec.cod_moneda
				,rec.fecha_aceleracion
				,rec.deuda_renegociada
				,rec.operacion_desfasada
				,rec.fecha_a_rectificar
				,rec.fecha_rectificacion
				,rec.causal_rectificacion
				,rec.numero_solicitud
				,rec.valor_contable
				,'A01-00001; cod_persona: No se encuentra el codigo del campo cod_persona en la tabla interno.tipo_persona_rel'
			);

		END LOOP;

		/*
			A01-00002: Validacion de campo cod_titulo_3 si existe en la tabla relacion interno.operacion_titulo_rel
		*/

		FOR rec IN 

			SELECT a.*
		    FROM interface.cartera_operaciones a
		    LEFT JOIN interno.operacion_titulo_rel b 
		        ON a.cod_titulo_3 = b.cod_entidad
		    WHERE b.cod_entidad IS NULL
		
		LOOP

			INSERT INTO log.cartera_operaciones (fecha_proceso, rut, cod_persona, cod_operacion, cod_titulo_3, cod_tipo_obligacion, fecha_otorgamiento, carga_financiera, fecha_extincion, monto_original, capital, interes, otros, cod_moneda, fecha_aceleracion, deuda_renegociada, operacion_desfasada, fecha_a_rectificar, fecha_rectificacion, causal_rectificacion, numero_solicitud, valor_contable, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.rut
				,rec.cod_persona
				,rec.cod_operacion
				,rec.cod_titulo_3
				,rec.cod_tipo_obligacion
				,rec.fecha_otorgamiento
				,rec.carga_financiera
				,rec.fecha_extincion
				,rec.monto_original
				,rec.capital
				,rec.interes
				,rec.otros
				,rec.cod_moneda
				,rec.fecha_aceleracion
				,rec.deuda_renegociada
				,rec.operacion_desfasada
				,rec.fecha_a_rectificar
				,rec.fecha_rectificacion
				,rec.causal_rectificacion
				,rec.numero_solicitud
				,rec.valor_contable
				,'A01-00002; cod_titulo_3: No se encuentra el codigo del campo cod_titulo_3 en la tabla interno.operacion_titulo_rel'
			);	

		END LOOP;


		/*
			A01-00004: validacion de campo cod_tipo_obligacion si existe en la tabla relacion interno.tabla_banco_126_rel
		*/

		FOR rec IN 

			SELECT a.*
		    FROM interface.cartera_operaciones a
		    LEFT JOIN interno.tabla_banco_126_rel b 
		        ON a.cod_tipo_obligacion = b.cod_entidad
		    WHERE b.cod_entidad IS NULL
		
		LOOP

			INSERT INTO log.cartera_operaciones (fecha_proceso, rut, cod_persona, cod_operacion, cod_titulo_3, cod_tipo_obligacion, fecha_otorgamiento, carga_financiera, fecha_extincion, monto_original, capital, interes, otros, cod_moneda, fecha_aceleracion, deuda_renegociada, operacion_desfasada, fecha_a_rectificar, fecha_rectificacion, causal_rectificacion, numero_solicitud, valor_contable, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.rut
				,rec.cod_persona
				,rec.cod_operacion
				,rec.cod_titulo_3
				,rec.cod_tipo_obligacion
				,rec.fecha_otorgamiento
				,rec.carga_financiera
				,rec.fecha_extincion
				,rec.monto_original
				,rec.capital
				,rec.interes
				,rec.otros
				,rec.cod_moneda
				,rec.fecha_aceleracion
				,rec.deuda_renegociada
				,rec.operacion_desfasada
				,rec.fecha_a_rectificar
				,rec.fecha_rectificacion
				,rec.causal_rectificacion
				,rec.numero_solicitud
				,rec.valor_contable
				,'A01-00004; cod_tipo_obligacion: No se encuentra el codigo del campo cod_tipo_obligacion en la tabla interno.tabla_banco_126_rel'
			);			
		    
		END LOOP;		

		/*
			A01-00005: Verifica que el campo cod_operacion exista en la interfaz cuadro_operaciones
		*/

		FOR rec IN 

			SELECT a.*
		    FROM interface.cartera_operaciones a
		    LEFT JOIN interface.cuadro_operaciones b 
		        ON a.cod_operacion = b.cod_operacion
		    WHERE b.cod_operacion IS NULL
		
		LOOP

			INSERT INTO log.cartera_operaciones (fecha_proceso, rut, cod_persona, cod_operacion, cod_titulo_3, cod_tipo_obligacion, fecha_otorgamiento, carga_financiera, fecha_extincion, monto_original, capital, interes, otros, cod_moneda, fecha_aceleracion, deuda_renegociada, operacion_desfasada, fecha_a_rectificar, fecha_rectificacion, causal_rectificacion, numero_solicitud, valor_contable, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.rut
				,rec.cod_persona
				,rec.cod_operacion
				,rec.cod_titulo_3
				,rec.cod_tipo_obligacion
				,rec.fecha_otorgamiento
				,rec.carga_financiera
				,rec.fecha_extincion
				,rec.monto_original
				,rec.capital
				,rec.interes
				,rec.otros
				,rec.cod_moneda
				,rec.fecha_aceleracion
				,rec.deuda_renegociada
				,rec.operacion_desfasada
				,rec.fecha_a_rectificar
				,rec.fecha_rectificacion
				,rec.causal_rectificacion
				,rec.numero_solicitud
				,rec.valor_contable
				,'A01-00005; Operacion no existe en la interfaz interface.cuadro_operaciones'
			);			
		    
		END LOOP;		


		/*
			A01-00006: Valida que la operacion este informada una ves en la interfaz
		*/		


		FOR rec IN 

			SELECT a.*
		    FROM interface.cartera_operaciones a
		    INNER JOIN 
			   (
              	  select cod_operacion, count(cod_operacion) as "cantidad" from interface.cartera_operaciones 	
				  group by cod_operacion
				  having count(cod_operacion) > 1
			   ) AS b on a.cod_operacion = b.cod_operacion
			   
		
		LOOP

			INSERT INTO log.cartera_operaciones (fecha_proceso, rut, cod_persona, cod_operacion, cod_titulo_3, cod_tipo_obligacion, fecha_otorgamiento, carga_financiera, fecha_extincion, monto_original, capital, interes, otros, cod_moneda, fecha_aceleracion, deuda_renegociada, operacion_desfasada, fecha_a_rectificar, fecha_rectificacion, causal_rectificacion, numero_solicitud, valor_contable, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.rut
				,rec.cod_persona
				,rec.cod_operacion
				,rec.cod_titulo_3
				,rec.cod_tipo_obligacion
				,rec.fecha_otorgamiento
				,rec.carga_financiera
				,rec.fecha_extincion
				,rec.monto_original
				,rec.capital
				,rec.interes
				,rec.otros
				,rec.cod_moneda
				,rec.fecha_aceleracion
				,rec.deuda_renegociada
				,rec.operacion_desfasada
				,rec.fecha_a_rectificar
				,rec.fecha_rectificacion
				,rec.causal_rectificacion
				,rec.numero_solicitud
				,rec.valor_contable
				,'A01-00006; Operacion se encuentra informada en la interfaz mas de una ves'
			);		

		END LOOP;					

		/*
			A01-00007: Valida que la fecha de otorgamiento sea menor o igual a la fecha de proceso
		*/		


		FOR rec IN 

			SELECT a.*
		    FROM interface.cartera_operaciones a
		    WHERE a.fecha_otorgamiento > a.fecha_proceso
			   
		
		LOOP

			INSERT INTO log.cartera_operaciones (fecha_proceso, rut, cod_persona, cod_operacion, cod_titulo_3, cod_tipo_obligacion, fecha_otorgamiento, carga_financiera, fecha_extincion, monto_original, capital, interes, otros, cod_moneda, fecha_aceleracion, deuda_renegociada, operacion_desfasada, fecha_a_rectificar, fecha_rectificacion, causal_rectificacion, numero_solicitud, valor_contable, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.rut
				,rec.cod_persona
				,rec.cod_operacion
				,rec.cod_titulo_3
				,rec.cod_tipo_obligacion
				,rec.fecha_otorgamiento
				,rec.carga_financiera
				,rec.fecha_extincion
				,rec.monto_original
				,rec.capital
				,rec.interes
				,rec.otros
				,rec.cod_moneda
				,rec.fecha_aceleracion
				,rec.deuda_renegociada
				,rec.operacion_desfasada
				,rec.fecha_a_rectificar
				,rec.fecha_rectificacion
				,rec.causal_rectificacion
				,rec.numero_solicitud
				,rec.valor_contable
				,'A01-00007; La fecha de otorgamiento es posterior a la fecha de proceso'
			);		

		END LOOP;							
		
		
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.val_interfaz_a01',
			SQLERRM
		);
	END;
END;
$$