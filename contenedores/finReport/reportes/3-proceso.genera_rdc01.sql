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
		    b.cod_operacional::INTEGER           										as "operacion_titulo",
			d.cod_deudor::INTEGER                										as "tipo_deudor",
			e.cod_obligacion::INTEGER            										as "tipo_obligacion",
			TO_CHAR(a.fecha_otorgamiento,'YYYYMMDD')::VARCHAR       					as "fecha_otorgamiento", 
			a.carga_financiera::NUMERIC(15)                         					as "carga_financiera", 
			TO_CHAR(a.fecha_extincion,'YYYYMMDD')::VARCHAR          					as "fecha_extincion", 		
			a.gar_real_inmobiliaria::NUMERIC(15)                    					as "valor_gtia_inmobiliaria", 
			a.gar_real_mobiliaria::NUMERIC(15)                      					as "valor_gtia_mobiliaria", 
			a.gar_financiera::NUMERIC(15)                           					as "valor_gtia_financiera", 
			a.gar_personal::NUMERIC(15)                             					as "valor_gtia_personal", 
			(a.monto_original * f.valor)::NUMERIC(15)                 					as "monto_original", 
			--(((a.capital + a.interes) * f.valor) + otros)::NUMERIC(15)  				as "monto_actual", 
			0                                                                           as "monto_actual",       -- Se saca mejor del cuadro de pago para que quede todo cuadrado. 
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
		FROM interface.cartera_operacionesa a inner join interno.tipo_persona_rel b     on a.cod_persona = b.cod_entidad
											  inner join interno.operacion_titulo_rel c on a.cod_titulo_3 = c.cod_entidad
											  inner join interno.tipo_deudor_rel d      on a.cod_deudor = d.cod_entidad
											  inner join interno.tabla_banco_126_rel e  on a.cod_tipo_obligacion = e.cod_entidad
											  inner join interface.tipo_cambio f        on a.cod_moneda = f.cod_moneda and a.fecha_proceso = f.fecha_proceso;
		   


		-- | Actualiza mora SIN aceleracion | --

		update reporte.rdc01_detalle as a 
		    set 
			  a.monto_mora_1_tramo = case when GBASE.tramo = 1 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_2_tramo = case when GBASE.tramo = 2 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_3_tramo = case when GBASE.tramo = 3 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_4_tramo = case when GBASE.tramo = 4 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_5_tramo = case when GBASE.tramo = 5 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_6_tramo = case when GBASE.tramo = 6 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_7_tramo = case when GBASE.tramo = 7 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_8_tramo = case when GBASE.tramo = 8 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_9_tramo = case when GBASE.tramo = 1 then GBASE.mora + GBASE.otros else 0 end		   
		from (
			 select
			    BASE.cod_operacion
			   ,tramo
			   ,(sum(mora_moneda_origen) * c.valor)::numeric(15) as "mora"
			   ,sum(BASE.otros)::numeric(15)                     as "otros"
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
						   ,(capital - capital_pagado + interes_termino + interes_moroso - interes_pagado) as "mora_moneda_origen"
						   ,otros                                 
						    from interface.cuadro_operaciones  
							     where fecha_cuota <= fecha_proceso
					) as BASE   inner join interface.cartera_operaciones b on BASE.cod_operacion = b.cod_operacion
					            inner join interface.tipo_cambio c         on b.cod_moneda = c.cod_moneda
					  where to_char(b.fecha_aceleracion,'YYYYMMDD')::VARCHAR = '19000101'
					group by BASE.cod_operacion, tramo
				) AS GBASE 
				where a.cod_operacion = GBASE.cod_operacion;


		-- | Actualiza mora CON aceleracion | --

		update reporte.rdc01_detalle as a 
		    set 
			  a.monto_mora_1_tramo = case when GBASE.tramo = 1 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_2_tramo = case when GBASE.tramo = 2 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_3_tramo = case when GBASE.tramo = 3 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_4_tramo = case when GBASE.tramo = 4 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_5_tramo = case when GBASE.tramo = 5 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_6_tramo = case when GBASE.tramo = 6 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_7_tramo = case when GBASE.tramo = 7 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_8_tramo = case when GBASE.tramo = 8 then GBASE.mora + GBASE.otros else 0 end
		     ,a.monto_mora_9_tramo = case when GBASE.tramo = 1 then GBASE.mora + GBASE.otros else 0 end		   
		from (
			 select
			    BASE.cod_operacion
			   ,tramo
			   ,(sum(mora_moneda_origen) * c.valor)::numeric(15) as "mora"
			   ,sum(BASE.otros)::numeric(15)                     as "otros"
			   from (
						select 
						    cod_operacion
						   ,
	                        case
							  -- Mantiene la mora antigua con la fecha de proceso
							  when fecha_cuota < fecha_aceleracion then
		 						   case
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
									else 1 end
                              else
							  -- Nueva mora acelerada para las cuotas futuras
		 						   case
								      when (fecha_proceso - fecha_aceleracion) + 1 < 30                                                  then 1
									  when (fecha_proceso - fecha_aceleracion) + 1 >= 30  and (fecha_proceso - fecha_aceleracion) + 1 < 60      then 2
									  when (fecha_proceso - fecha_aceleracion) + 1 >= 60  and (fecha_proceso - fecha_aceleracion) + 1 < 90      then 3
									  when (fecha_proceso - fecha_aceleracion) + 1 >= 90  and (fecha_proceso - fecha_aceleracion) + 1 < 180     then 4
									  when (fecha_proceso - fecha_aceleracion) + 1 >= 180 
									       and fecha_aceleracion > make_date(extract(year from fecha_proceso)::int - 1, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int) then 5
									  when fecha_aceleracion <= make_date(extract(year from fecha_proceso)::int - 1, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)
									       and fecha_aceleracion > make_date(extract(year from fecha_proceso)::int - 2, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)  then 6
									  when fecha_aceleracion <= make_date(extract(year from fecha_proceso)::int - 2, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)
									       and fecha_aceleracion > make_date(extract(year from fecha_proceso)::int - 3, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)  then 7
									  when fecha_aceleracion <= make_Date(extract(year from fecha_proceso)::int - 3, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)
									       and fecha_aceleracion > make_date(extract(year from fecha_proceso)::int - 4, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)  then 8
									  when fecha_aceleracion <= make_date(extract(year from fecha_proceso)::int - 4, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)     then 9  
									else 1 end
							 end  as "tramo"							  
						   ,(capital - capital_pagado + interes_termino + interes_moroso - interes_pagado) as "mora_moneda_origen"
						   ,otros                                 
						    from interface.cuadro_operaciones  
					) as BASE   inner join interface.cartera_operaciones b on BASE.cod_operacion = b.cod_operacion
					            inner join interface.tipo_cambio c         on b.cod_moneda = c.cod_moneda
					  where to_char(b.fecha_aceleracion,'YYYYMMDD')::VARCHAR <> '19000101'
					group by BASE.cod_operacion, tramo
				) AS GBASE 
				where a.cod_operacion = GBASE.cod_operacion;				



		-- | Actualiza monto al dia | --

		update reporte.rdc01_detalle as a 
		    set 
			  a.monto_al_dia = GBASE.monto + GBASE.otros 
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
			   ,tramo
			   ,(sum(monto_origen) * c.valor)::numeric(15) as "monto"
			   ,sum(BASE.otros)::numeric(15)               as "otros"
			   from (
						select 
						    cod_operacion
						   ,(capital - capital_pagado + interes_termino + interes_moroso - interes_pagado) as "monto_origen"
						   ,otros                                 
						    from interface.cuadro_operaciones  
					) as BASE   inner join interface.cartera_operaciones b on BASE.cod_operacion = b.cod_operacion
					            inner join interface.tipo_cambio c         on b.cod_moneda = c.cod_moneda
					  where to_char(b.fecha_aceleracion,'YYYYMMDD')::VARCHAR = '19000101'
					group by BASE.cod_operacion, tramo
				) AS GBASE 
				where a.cod_operacion = GBASE.cod_operacion;								

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