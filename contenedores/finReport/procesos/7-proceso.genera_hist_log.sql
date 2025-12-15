CREATE OR REPLACE PROCEDURE proceso.genera_hist_log()
LANGUAGE plpgsql
AS $$
DECLARE
	fecha_archivo date;
	fecha_actual date;
	
BEGIN
	BEGIN

		/*
			Proceso de generacion de historico de log
		*/


		-- | Determina fecha de proceso | --		

		select TO_CHAR(max(fecha_proceso), 'YYYYMMDD')::DATE
		into fecha_archivo
		from interface.cartera_operaciones;

		RAISE NOTICE 'Fecha de proceso: %', fecha_archivo;

		-- | Determina fecha de ejecucion | --		

		fecha_actual := TO_CHAR(CURRENT_DATE, 'YYYYMMDD')::DATE;

		RAISE NOTICE 'Fecha de ejecucion: %', fecha_actual;		


		-- | Ingresa historico log_eventos | --				

		DELETE FROM log.log_eventos_hist 
		where fecha_proceso = fecha_archivo 
		  and fecha_ejecucion = fecha_actual;

		INSERT INTO log.log_eventos_hist (fecha_proceso, fecha_ejecucion, fecha, nivel, dag, procedimiento, mensaje)
		SELECT 
		  fecha_archivo       as "fecha_proceso"
		 ,fecha_actual        as "fecha_ejecucion"
		 ,fecha
		 ,nivel
		 ,dag
		 ,procedimiento
		 ,mensaje
		 FROM log.log_eventos;


		-- | Ingresa historico cartera_operaciones_hist | --				

		DELETE FROM log.cartera_operaciones_hist
		where fecha_proceso = fecha_archivo;

		INSERT INTO log.cartera_operaciones_hist (fecha_proceso, rut, cod_persona, cod_operacion, cod_titulo_3, cod_tipo_obligacion, fecha_otorgamiento, carga_financiera, fecha_extincion, monto_original, capital, interes, otros, cod_moneda, fecha_aceleracion, deuda_renegociada, operacion_desfasada, fecha_a_rectificar, fecha_rectificacion, causal_rectificacion, numero_solicitud, valor_contable, problema)
		SELECT 
            fecha_proceso
		   ,rut
		   ,cod_persona
		   ,cod_operacion
		   ,cod_titulo_3
		   ,cod_tipo_obligacion
		   ,fecha_otorgamiento
		   ,carga_financiera
		   ,fecha_extincion
		   ,monto_original
		   ,capital
		   ,interes
		   ,otros
		   ,cod_moneda
		   ,fecha_aceleracion
		   ,deuda_renegociada
		   ,operacion_desfasada
		   ,fecha_a_rectificar
		   ,fecha_rectificacion
		   ,causal_rectificacion
		   ,numero_solicitud
		   ,valor_contable
		   ,problema
		 FROM log.cartera_operaciones;		 


		-- | Ingresa historico cuadro_operaciones_hist | --				

		DELETE FROM log.cuadro_operaciones_hist
		where fecha_proceso = fecha_archivo;

		INSERT INTO log.cuadro_operaciones_hist (fecha_proceso, cod_operacion, fecha_cuota, capital, capital_pagado, interes_devengado, interes_por_pagar, interes_moroso, interes_pagado, otros, otros_pagado, problema)
		SELECT
			 fecha_proceso
			,cod_operacion
			,fecha_cuota
			,capital
			,capital_pagado
			,interes_devengado
			,interes_por_pagar
			,interes_moroso
			,interes_pagado
			,otros
			,otros_pagado
			,problema
		FROM log.cuadro_operaciones;


		-- | Ingresa historico tipo_cambio_hist | --				

		DELETE FROM log.tipo_cambio_hist
		where fecha_proceso = fecha_archivo;

		INSERT INTO log.tipo_cambio_hist (fecha_proceso, cod_moneda, valor, problema)
		SELECT
			 fecha_proceso
			,cod_moneda
			,valor
			,problema
		FROM log.tipo_cambio;


		-- | Ingresa historico cuadro_rectificaciones_hist | --				

		DELETE FROM log.cuadro_rectificaciones_hist
		where fecha_proceso = fecha_archivo;		

		INSERT INTO log.cuadro_rectificaciones_hist (fecha_proceso, fecha_a_rectificar, cod_operacion, causal_eliminacion, campo_rdc01, valor, fecha_rectificacion, causal_rectificacion, numero_solicitud, problema)
		SELECT
			 fecha_proceso
			,fecha_a_rectificar
			,cod_operacion
			,causal_eliminacion
			,campo_rdc01
			,valor
			,fecha_rectificacion
			,causal_rectificacion
			,numero_solicitud
			,problema
		FROM log.cuadro_rectificaciones;



		-- | Ingresa historico cartera_garantias_hist | --				

		DELETE FROM log.cartera_garantias_hist
		where fecha_proceso = fecha_archivo;

		INSERT INTO log.cartera_garantias_hist (fecha_proceso, id_garantia, rut_garante, cod_persona, cod_operacion, fecha_otorgamiento, gar_real_inmobiliaria, porc_real_inmobiliaria, gar_real_mobiliaria, porc_real_mobiliaria, gar_financiera, porc_financiera, gar_personal, porc_personal, problema)
		SELECT
			 fecha_proceso
			,id_garantia
			,rut_garante
			,cod_persona
			,cod_operacion
			,fecha_otorgamiento
			,gar_real_inmobiliaria
			,porc_real_inmobiliaria
			,gar_real_mobiliaria
			,porc_real_mobiliaria
			,gar_financiera
			,porc_financiera
			,gar_personal
			,porc_personal
			,problema
		FROM log.cartera_garantias;


		-- | Ingresa historico variacion_stoc_hist | --						

		DELETE FROM log.variacion_stock_hist
		where fecha_proceso = fecha_archivo;

		INSERT INTO log.variacion_stock_hist (fecha_proceso, cod_operacion, tipo_flujo, fecha_efectivo_flujo, ident_tribunal, rut_tercera_parte, problema)
		SELECT
			 fecha_proceso
			,cod_operacion
			,tipo_flujo
			,fecha_efectivo_flujo
			,ident_tribunal
			,rut_tercera_parte
			,problema
		FROM log.variacion_stock;

		
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.genera_hist_log',
			SQLERRM
		);
	END;
END;
$$