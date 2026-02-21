CREATE OR REPLACE PROCEDURE proceso.genera_hist_interface()
LANGUAGE plpgsql
AS $$
DECLARE
	fecha_archivo date;
	
BEGIN
	BEGIN

		/*
			Proceso de generacion de historico de interfaces
		*/


		-- | Determina fecha de proceso | --		

		select to_date(valor,'YYYYMMDD')
		into fecha_archivo
		from interno.parametros_generales where cod = '3';

		RAISE NOTICE 'Fecha de proceso: %', fecha_archivo;


		-- | Ingresa historico cartera operaciones | --				

		delete from historico.cartera_operaciones
		where fecha_proceso = fecha_archivo;

		insert into historico.cartera_operaciones (fecha_proceso, rut, cod_persona, cod_operacion, cod_titulo_3, cod_tipo_obligacion, fecha_otorgamiento, carga_financiera, fecha_extincion, monto_original, capital, interes, otros, cod_moneda, fecha_aceleracion, deuda_renegociada, operacion_desfasada, fecha_a_rectificar, fecha_rectificacion, causal_rectificacion, numero_solicitud, valor_contable)
		select		
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
		from interface.cartera_operaciones
		where fecha_proceso = fecha_archivo;		


		-- | Ingresa historico cuadro operaciones | --				

		delete from historico.cuadro_operaciones
		where fecha_proceso = fecha_archivo;

		insert into historico.cuadro_operaciones (fecha_proceso, cod_operacion, fecha_cuota, capital, capital_pagado, interes_devengado, interes_por_pagar, interes_moroso, interes_pagado, otros, otros_pagado)
		select
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
		from interface.cuadro_operaciones
		where fecha_proceso = fecha_archivo;

		-- | Ingresa historico cuadro rectificaciones | --				

		delete from historico.cuadro_rectificaciones
		where fecha_proceso = fecha_archivo;

		insert into historico.cuadro_rectificaciones (fecha_proceso, fecha_a_rectificar, cod_operacion, causal_eliminacion, campo_rdc01, valor, fecha_rectificacion, causal_rectificacion, numero_solicitud)
		select
			 fecha_proceso
			,fecha_a_rectificar
			,cod_operacion
			,causal_eliminacion
			,campo_rdc01
			,valor
			,fecha_rectificacion
			,causal_rectificacion
			,numero_solicitud
		from interface.cuadro_rectificaciones
		where fecha_proceso = fecha_archivo;


		-- | Ingresa historico tipo de cambio | --				

		delete from historico.tipo_cambio
		where fecha_proceso = fecha_archivo;
		
		insert into historico.tipo_cambio (fecha_proceso, cod_moneda, valor)
		select
			 fecha_proceso
			,cod_moneda
			,valor
		from interface.tipo_cambio
		where fecha_proceso = fecha_archivo;


		-- | Ingresa historico variacion de stock | --						

		delete from historico.variacion_stock
		where fecha_proceso = fecha_archivo;

		insert into historico.variacion_stock (fecha_proceso, cod_operacion, tipo_flujo, fecha_efectivo_flujo, ident_tribunal, rut_tercera_parte)
		select
			 fecha_proceso
			,cod_operacion
			,tipo_flujo
			,fecha_efectivo_flujo
			,ident_tribunal
			,rut_tercera_parte		
		from interface.variacion_stock
		where fecha_proceso = fecha_archivo;


		-- | Ingresa historico cartera de garantias | --						

		delete from historico.cartera_garantias
		where fecha_proceso = fecha_archivo;	

		insert into historico.cartera_garantias (fecha_proceso, id_garantia, rut_garante, cod_persona, cod_operacion, fecha_otorgamiento, gar_real_inmobiliaria, porc_real_inmobiliaria, gar_real_mobiliaria, porc_real_mobiliaria, gar_financiera, porc_financiera, gar_personal, porc_personal)
		select
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
		from interface.cartera_garantias
		where fecha_proceso = fecha_archivo;


		-- | Ingresa historico registro de consentimientos | --								

		delete from historico.registro_consentimientos
		where fecha_proceso = fecha_archivo;

		insert into historico.registro_consentimientos (
														 fecha_proceso			    	
														,cod_consentimiento				
														,fecha_otorgamiento		    	
														,hora_otorgamiento				
														,fecha_fin_consentimiento		
														,hora_fin_consentimiento		
														,rut_consultado					
														,cod_medio_consentimiento		
														,cod_finalidad_consentimiento	
														,rut_ejecutivo					
														,cod_objetivo_consentimiento	
														,cod_encriptado
		)
		select 
			 fecha_proceso			    	
			,cod_consentimiento				
			,fecha_otorgamiento		    	
			,hora_otorgamiento				
			,fecha_fin_consentimiento		
			,hora_fin_consentimiento		
			,rut_consultado					
			,cod_medio_consentimiento		
			,cod_finalidad_consentimiento	
			,rut_ejecutivo					
			,cod_objetivo_consentimiento	
			,cod_encriptado
		from interface.registro_consentimientos
		where fecha_proceso = fecha_archivo;
				
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.genera_hist_interface',
			SQLERRM
		);
	END;
END;
$$