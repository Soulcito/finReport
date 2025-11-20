CREATE OR REPLACE PROCEDURE proceso.genera_rdc01()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
	
BEGIN
	BEGIN

		/*
			Proceso de generacion de RDC01
		*/



		-- | Borrado de tablas | --
		
		truncate table reporte.rdc01_texto;
		truncate table reporte.rdc01_detalle;
		truncate table reporte.rdc01_final;

		-- | Logica de generacion de reporte desde la interfaz cartera_operaciones | --

		insert into reporte.rdc01_detalle(fecha_proceso, rut, tipo_persona, codigo_operacion, operacion_titulo, tipo_deudor, tipo_obligacion, fecha_otorgamiento, carga_financiera, fecha_extincion, valor_gtia_inmobiliaria, valor_gtia_mobiliaria, valor_gtia_financiera, valor_gtia_personal, monto_original, monto_actual, monto_al_dia, monto_mora_1_tramo, monto_mora_2_tramo, monto_mora_3_tramo, monto_mora_4_tramo, monto_mora_5_tramo, monto_mora_6_tramo, monto_mora_7_tramo, monto_mora_8_tramo, monto_mora_9_tramo, mora_actual, deuda_renegociada, deuda_acelerada, tipo_persona_interfaz, operacion_titulo_interfaz, tipo_deudor_interfaz, tipo_obligacion_interfaz, fecha_primera_cuota_inpaga, cod_moneda, tipo_cambio)
		select 
			a.fecha_proceso, 
			a.rut, 
			b.cod_persona::INTEGER               										as "tipo_persona",
		    a.cod_operacion                      										as "codigo_operacion", 
		    c.cod_operacional::INTEGER           										as "operacion_titulo",
			d.cod_deudor::INTEGER                										as "tipo_deudor",
			e.cod_obligacion::INTEGER            										as "tipo_obligacion",
			TO_CHAR(a.fecha_otorgamiento,'YYYYMMDD')::VARCHAR       					as "fecha_otorgamiento", 
			case
			   when d.cod_deudor::INTEGER = 2 then 0
			   else 
			   		case
					   when e.cod_obligacion::INTEGER in (41,42,43,44) then 0
					   else a.carga_financiera::NUMERIC(15) end              
			   end							                         					as "carga_financiera",   -- Para tipo de creditos con cuadro de pago se sacara desde el cuadro de pago.
			case
				when e.cod_obligacion::INTEGER in (7,8,41,42,43,44) then '19000101'
				else TO_CHAR(a.fecha_extincion,'YYYYMMDD')::VARCHAR end					as "fecha_extincion",
			case 
			   when d.cod_deudor::INTEGER = 1 then 
			   		a.gar_real_inmobiliaria::NUMERIC(15) else 0 end    					as "valor_gtia_inmobiliaria", 
			case
			   when d.cod_deudor::INTEGER = 1 then
			   		a.gar_real_mobiliaria::NUMERIC(15) else 0 end      					as "valor_gtia_mobiliaria", 
			case
			   when d.cod_deudor::INTEGER = 1 then 
					a.gar_financiera::NUMERIC(15) else 0 end           					as "valor_gtia_financiera", 
			case
			   when d.cod_deudor::INTEGER = 1 then 
			   		a.gar_personal::NUMERIC(15) else 0 end            					as "valor_gtia_personal", 
			case
				when e.cod_obligacion::INTEGER in (41,42,43,44) then 0			
				when e.cod_obligacion::INTEGER in (31,32,33)    then 0                 -- SE ACTUALIZA CON LO QUE QUEDA POR PAGAR DESDE EL CUADRO DE PAGO
				else (a.monto_original * f.valor)::NUMERIC(15) end    					as "monto_original",     
			0                                                                           as "monto_actual",       -- Se entiende por monto al dia + moras
			0                                                           				as "monto_al_dia",
			0																			as "monto_mora_1_tramo",
			0																			as "monto_mora_2_tramo",
			0																			as "monto_mora_3_tramo",
			0																			as "monto_mora_4_tramo",
			0																			as "monto_mora_5_tramo",
			0																			as "monto_mora_6_tramo",
			0																			as "monto_mora_7_tramo",
			0																			as "monto_mora_8_tramo",
			0																			as "monto_mora_9_tramo",
			0																			as "mora_actual",
			deuda_renegociada::INTEGER                                  				as "deuda_renegociada", 
			case
			  when TO_CHAR(fecha_aceleracion,'YYYYMMDD')::VARCHAR = '19000101' THEN 2
			  else 1 end                                                                as "deuda_acelerada",
			a.cod_persona           													as "tipo_persona_interfaz",
			a.cod_titulo_3          													as "operacion_titulo_interfaz", 
			a.cod_deudor            													as "tipo_deudor_interfaz",
			a.cod_tipo_obligacion   													as "tipo_obligacion_interfaz",
			''                      													as "fecha_primera_cuota_inpaga",
			a.cod_moneda																as "cod_moneda",
			f.valor																		as "tipo_cambio"
		FROM interface.cartera_operaciones  a inner join interno.tipo_persona_rel b     on a.cod_persona = b.cod_entidad
											  inner join interno.operacion_titulo_rel c on a.cod_titulo_3 = c.cod_entidad
											  inner join interno.tipo_deudor_rel d      on a.cod_deudor = d.cod_entidad
											  inner join interno.tabla_banco_126_rel e  on a.cod_tipo_obligacion = e.cod_entidad
											  inner join interface.tipo_cambio f        on a.cod_moneda = f.cod_moneda and a.fecha_proceso = f.fecha_proceso;
		   
		-- | Actualiza carga financiera para creditos desde el cuadro de pago | --
		-- | Que pasa con creditos acelerados, este campo no tiene sentido, deberia ser cero .....? | --

		update reporte.rdc01_detalle as a 
		    set 
			  carga_financiera = (((b.capital + b.interes_por_pagar) * c.valor) + b.otros)::NUMERIC(15)
		from interface.cuadro_operaciones b, interface.tipo_cambio c
		where a.codigo_operacion = b.cod_operacion
		  and a.cod_moneda = c.cod_moneda
          and a.tipo_obligacion::INTEGER not in (7,8,41,42,43,44)
		  and extract(year from a.fecha_proceso) = extract(year from b.fecha_cuota)
		  and extract(month from a.fecha_proceso) = extract(month from b.fecha_cuota)
		  and a.tipo_deudor::INTEGER = 1;


		-- | Actualiza monto original para creditos 31,32,33 desde el cuadro de pago | --

		update reporte.rdc01_detalle as a 
		    set 
			  monto_original = monto
        from ( 
		 		select 
				     a.codigo_operacion,
				     (
					   (((b.capital + b.interes_por_pagar) * c.valor) + b.otros) - 
					   (((b.capital_pagado + b.interes_pagado) * c.valor) + b.otros_pagado)
					 )::NUMERIC(15) as "monto",
					 a.tipo_deudor
					   from 
				         reporte.rdc01_detalle a inner join 
						                          (
													    select
													       cod_operacion
														  ,sum(capital) as "capital"
														  ,sum(interes_por_pagar) as "interes_por_pagar"
														  ,sum(otros) as "otros"
														  ,sum(capital_pagado) as "capital_pagado"
														  ,sum(interes_pagado) as "interes_pagado"
														  ,sum(otros_pagado) as "otros_pagado"
													    from interface.cuadro_operaciones
													    group by cod_operacion
												   ) as b on a.codigo_operacion = b.cod_operacion
				                                 inner join interface.tipo_cambio c on a.cod_moneda = c.cod_moneda
		  		       where 
		                  a.tipo_obligacion::INTEGER in (31,32,33)
				   
              ) as BASE 
			  where a.codigo_operacion = BASE.codigo_operacion and a.tipo_deudor = BASE.tipo_deudor;

		-- | Actualiza mora SIN aceleracion | --

		update reporte.rdc01_detalle as a 
		    set 
			  monto_mora_1_tramo = case when GBASE.tramo = 1 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_2_tramo = case when GBASE.tramo = 2 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_3_tramo = case when GBASE.tramo = 3 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_4_tramo = case when GBASE.tramo = 4 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_5_tramo = case when GBASE.tramo = 5 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_6_tramo = case when GBASE.tramo = 6 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_7_tramo = case when GBASE.tramo = 7 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_8_tramo = case when GBASE.tramo = 8 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_9_tramo = case when GBASE.tramo = 9 then GBASE.mora + GBASE.otros else 0 end		   
		from (
			 select
			    BASE.cod_operacion
			   ,tramo
			   ,(sum(mora_moneda_origen) * c.valor)::numeric(15) as "mora"
			   ,sum(BASE.otros)::numeric(15)                     as "otros"
			   ,b.cod_deudor::integer                            as "tipo_deudor"
			   from (
						select 
						    cod_operacion
						   ,case
						      when (fecha_proceso - fecha_cuota) + 1 < 30                                                  then 1
							  when (fecha_proceso - fecha_cuota) + 1 >= 30  and (fecha_proceso - fecha_cuota) + 1 < 60      then 2
							  when (fecha_proceso - fecha_cuota) + 1 >= 60  and (fecha_proceso - fecha_cuota) + 1 < 90      then 3
							  when (fecha_proceso - fecha_cuota) + 1 >= 90  and (fecha_proceso - fecha_cuota) + 1 < 180     then 4
							  when (fecha_proceso - fecha_cuota) + 1 >= 180 
							       and fecha_cuota > make_date(extract(year from fecha_proceso)::int - 1, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int) then 5
							  when fecha_cuota <= make_date(extract(year from fecha_proceso)::int - 1, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)
							       and fecha_cuota > make_date(extract(year from fecha_proceso)::int - 2, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)  then 6
							  when fecha_cuota <= make_date(extract(year from fecha_proceso)::int - 2, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)
							       and fecha_cuota > make_date(extract(year from fecha_proceso)::int - 3, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)  then 7
							  when fecha_cuota <= make_Date(extract(year from fecha_proceso)::int - 3, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)
							       and fecha_cuota > make_date(extract(year from fecha_proceso)::int - 4, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)  then 8
							  when fecha_cuota <= make_date(extract(year from fecha_proceso)::int - 4, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)     then 9  
							else 1 end  as "tramo"
						   ,(capital - capital_pagado + interes_por_pagar + interes_moroso - interes_pagado) as "mora_moneda_origen"
						   ,(otros - otros_pagado)                                                           as "otros"
						    from interface.cuadro_operaciones  
							     where fecha_cuota <= fecha_proceso
					) as BASE   inner join interface.cartera_operaciones b on BASE.cod_operacion = b.cod_operacion
					            inner join interface.tipo_cambio c         on b.cod_moneda = c.cod_moneda
					  where to_char(b.fecha_aceleracion,'YYYYMMDD')::VARCHAR = '19000101'
					group by BASE.cod_operacion, tramo, c.valor,b.cod_deudor
				) AS GBASE 
				where a.codigo_operacion = GBASE.cod_operacion and a.tipo_deudor = GBASE.tipo_deudor;


		-- | Actualiza mora CON aceleracion | --

		update reporte.rdc01_detalle as a 
		    set 
			  monto_mora_1_tramo = case when GBASE.tramo = 1 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_2_tramo = case when GBASE.tramo = 2 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_3_tramo = case when GBASE.tramo = 3 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_4_tramo = case when GBASE.tramo = 4 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_5_tramo = case when GBASE.tramo = 5 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_6_tramo = case when GBASE.tramo = 6 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_7_tramo = case when GBASE.tramo = 7 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_8_tramo = case when GBASE.tramo = 8 then GBASE.mora + GBASE.otros else 0 end
		     ,monto_mora_9_tramo = case when GBASE.tramo = 1 then GBASE.mora + GBASE.otros else 0 end		   
		from (
			 select
			    BASE.cod_operacion
			   ,tramo
			   ,(sum(mora_moneda_origen) * c.valor)::numeric(15) as "mora"
			   ,sum(BASE.otros)::numeric(15)                     as "otros"
			   ,BASE.cod_deudor::integer                              as "tipo_deudor"
			   from (
						select 
						    a.cod_operacion
						   ,
	                        case
							  -- Mantiene la mora antigua con la fecha de proceso
							  when fecha_cuota < fecha_aceleracion then
		 						   case
								      when (a.fecha_proceso - fecha_cuota) + 1 < 30                                                  then 1
									  when (a.fecha_proceso - fecha_cuota) + 1 >= 30  and (a.fecha_proceso - fecha_cuota) + 1 < 60      then 2
									  when (a.fecha_proceso - fecha_cuota) + 1 >= 60  and (a.fecha_proceso - fecha_cuota) + 1 < 90      then 3
									  when (a.fecha_proceso - fecha_cuota) + 1 >= 90  and (a.fecha_proceso - fecha_cuota) + 1 < 180     then 4
									  when (a.fecha_proceso - fecha_cuota) + 1 >= 180 
									       and fecha_cuota > make_date(extract(year from a.fecha_proceso)::int - 1, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int) then 5
									  when fecha_cuota <= make_date(extract(year from a.fecha_proceso)::int - 1, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)
									       and fecha_cuota > make_date(extract(year from a.fecha_proceso)::int - 2, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)  then 6
									  when fecha_cuota <= make_date(extract(year from a.fecha_proceso)::int - 2, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)
									       and fecha_cuota > make_date(extract(year from a.fecha_proceso)::int - 3, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)  then 7
									  when fecha_cuota <= make_Date(extract(year from a.fecha_proceso)::int - 3, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)
									       and fecha_cuota > make_date(extract(year from a.fecha_proceso)::int - 4, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)  then 8
									  when fecha_cuota <= make_date(extract(year from a.fecha_proceso)::int - 4, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)     then 9  
									else 1 end
                              else
							  -- Nueva mora acelerada para las cuotas futuras
		 						   case
								      when (a.fecha_proceso - fecha_aceleracion) + 1 < 30                                                  then 1
									  when (a.fecha_proceso - fecha_aceleracion) + 1 >= 30  and (a.fecha_proceso - fecha_aceleracion) + 1 < 60      then 2
									  when (a.fecha_proceso - fecha_aceleracion) + 1 >= 60  and (a.fecha_proceso - fecha_aceleracion) + 1 < 90      then 3
									  when (a.fecha_proceso - fecha_aceleracion) + 1 >= 90  and (a.fecha_proceso - fecha_aceleracion) + 1 < 180     then 4
									  when (a.fecha_proceso - fecha_aceleracion) + 1 >= 180 
									       and fecha_aceleracion > make_date(extract(year from a.fecha_proceso)::int - 1, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int) then 5
									  when fecha_aceleracion <= make_date(extract(year from a.fecha_proceso)::int - 1, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)
									       and fecha_aceleracion > make_date(extract(year from a.fecha_proceso)::int - 2, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)  then 6
									  when fecha_aceleracion <= make_date(extract(year from a.fecha_proceso)::int - 2, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)
									       and fecha_aceleracion > make_date(extract(year from a.fecha_proceso)::int - 3, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)  then 7
									  when fecha_aceleracion <= make_Date(extract(year from a.fecha_proceso)::int - 3, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)
									       and fecha_aceleracion > make_date(extract(year from a.fecha_proceso)::int - 4, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)  then 8
									  when fecha_aceleracion <= make_date(extract(year from a.fecha_proceso)::int - 4, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)     then 9  
									else 1 end
							 end  as "tramo"							  
						   ,(a.capital - a.capital_pagado + a.interes_por_pagar + a.interes_moroso - a.interes_pagado) as "mora_moneda_origen"
						   ,(a.otros - a.otros_pagado)                                                                 as "otros"
						   ,b.cod_deudor
						   from interface.cuadro_operaciones a inner join interface.cartera_operaciones b on a.cod_operacion = b.cod_operacion
					) as BASE   inner join interface.cartera_operaciones b on BASE.cod_operacion = b.cod_operacion and BASE.cod_deudor = b.cod_deudor
					            inner join interface.tipo_cambio c         on b.cod_moneda = c.cod_moneda
					  where to_char(b.fecha_aceleracion,'YYYYMMDD')::VARCHAR <> '19000101'
					group by BASE.cod_operacion, tramo, c.valor, BASE.cod_deudor
				) AS GBASE 
				where a.codigo_operacion = GBASE.cod_operacion and a.tipo_deudor = GBASE.tipo_deudor;				



		-- | Actualiza monto al dia | --

		update reporte.rdc01_detalle as a 
		    set 
			  monto_al_dia = GBASE.monto + GBASE.otros 
			   - a.monto_mora_1_tramo 		   
			   - a.monto_mora_2_tramo
			   - a.monto_mora_3_tramo
			   - a.monto_mora_4_tramo
			   - a.monto_mora_5_tramo
			   - a.monto_mora_6_tramo
			   - a.monto_mora_7_tramo
			   - a.monto_mora_8_tramo
			   - a.monto_mora_9_tramo
		from (
			 select
			    BASE.cod_operacion
			   ,(sum(monto_origen) * c.valor)::numeric(15) as "monto"
			   ,sum(BASE.otros)::numeric(15)               as "otros"
			   ,b.cod_deudor::integer                      as "tipo_deudor"
			   from (
						select 
						    cod_operacion
						   ,(capital - capital_pagado + interes_por_pagar + interes_moroso - interes_pagado) as "monto_origen"
						   ,(otros - otros_pagado)                                                           as "otros"
						    from interface.cuadro_operaciones  
					) as BASE   inner join interface.cartera_operaciones b on BASE.cod_operacion = b.cod_operacion
					            inner join interface.tipo_cambio c         on b.cod_moneda = c.cod_moneda
					  where to_char(b.fecha_aceleracion,'YYYYMMDD')::VARCHAR = '19000101'
					group by BASE.cod_operacion, c.valor, cod_deudor
				) AS GBASE 
				where a.codigo_operacion = GBASE.cod_operacion and a.tipo_deudor = GBASE.tipo_deudor;								

		
		-- | Actualiza monto actual | --

		update reporte.rdc01_detalle
		    set 
			  monto_actual = monto_al_dia 
			        + monto_mora_1_tramo 
					+ monto_mora_2_tramo 
					+ monto_mora_3_tramo
					+ monto_mora_4_tramo
					+ monto_mora_5_tramo
					+ monto_mora_6_tramo
					+ monto_mora_7_tramo
					+ monto_mora_8_tramo
					+ monto_mora_9_tramo;

        
		-- | Actualiza mora actual | --					

		update reporte.rdc01_detalle as a
		   set
		   	  mora_actual = case 
				                 when (a.fecha_proceso - BASE.fecha)::INTEGER < 0 then 0 else (a.fecha_proceso - BASE.fecha)::INTEGER + 1 end
		   from (
			  select
			  	 cod_operacion
				,min(fecha_cuota)   as "fecha"
			  from interface.cuadro_operaciones
			  		where capital <> capital_pagado or interes_por_pagar <> interes_pagado or otros <> otros_pagado
			  group by cod_operacion
		   ) AS BASE where a.codigo_operacion = BASE.cod_operacion;

		
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.genera_rdc01',
			SQLERRM
		);
	END;
END;
$$