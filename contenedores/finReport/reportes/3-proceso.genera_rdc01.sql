CREATE OR REPLACE PROCEDURE proceso.genera_rdc01()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
	fecha_archivo varchar(8);
	codigo_institucion varchar(10);
	var_valor numeric(15);
	
BEGIN
	BEGIN

		/*
			Proceso de generacion de RDC01
		*/

		-- | Trunca tablas de uso en el procedimiento | --		

		TRUNCATE TABLE reporte.rdc01_caratula;
		TRUNCATE TABLE reporte.rdc01_texto;
		TRUNCATE TABLE reporte.rdc01_detalle;
		TRUNCATE TABLE reporte.rdc01_final;

		delete from reporte.rdc01_hist where fecha_proceso = fecha_archivo;

		-- | Determina fecha de proceso | --		

		select TO_CHAR(max(fecha_proceso), 'YYYYMMDD')::VARCHAR
		into fecha_archivo
		from interface.cartera_operaciones;

		RAISE NOTICE 'Fecha de proceso para RDC01: %', fecha_archivo;

		-- | Determina codigo de la institucion | --		

		select LPAD(valor,10,'0')
		into codigo_institucion
		from interno.parametros_generales where cod = '1';		

		RAISE NOTICE 'Codigo de institucion para RDC01: %', codigo_institucion;

		-- | Logica de generacion de reporte desde la interfaz cartera_operaciones | --

		insert into reporte.rdc01_detalle(fecha_proceso, rut, tipo_persona, codigo_operacion, operacion_titulo, tipo_deudor, tipo_obligacion, fecha_otorgamiento, carga_financiera, fecha_extincion, valor_gtia_inmobiliaria, valor_gtia_mobiliaria, valor_gtia_financiera, valor_gtia_personal, monto_original, monto_actual, monto_al_dia, monto_mora_1_tramo, monto_mora_2_tramo, monto_mora_3_tramo, monto_mora_4_tramo, monto_mora_5_tramo, monto_mora_6_tramo, monto_mora_7_tramo, monto_mora_8_tramo, monto_mora_9_tramo, mora_actual, deuda_renegociada, deuda_acelerada, tipo_persona_interfaz, operacion_titulo_interfaz, tipo_obligacion_interfaz, fecha_primera_cuota_inpaga, cod_moneda, tipo_cambio)
		select 
			a.fecha_proceso, 
			a.rut, 
			b.cod_persona::INTEGER               										as "tipo_persona",
		    a.cod_operacion                      										as "codigo_operacion", 
		    c.cod_operacional::INTEGER           										as "operacion_titulo",
			1                										                    as "tipo_deudor",        --Por definicion de interfaz cartera_operaciones, todos los registros corresponden al deudor directo
			e.cod_obligacion::INTEGER            										as "tipo_obligacion",
			TO_CHAR(a.fecha_otorgamiento,'YYYYMMDD')::VARCHAR       					as "fecha_otorgamiento", 
	   		case
			   when e.cod_obligacion::INTEGER in (41,42,43,44) then 0
			   else a.carga_financiera::NUMERIC(15) end               					as "carga_financiera",   -- Para tipo de creditos con cuadro de pago se sacara desde el cuadro de pago.
			case
				when e.cod_obligacion::INTEGER in (7,8,41,42,43,44) then '19000101'
				else TO_CHAR(a.fecha_extincion,'YYYYMMDD')::VARCHAR end					as "fecha_extincion",
			0    					                                                    as "valor_gtia_inmobiliaria", 
            0      					                                                    as "valor_gtia_mobiliaria", 
            0												           					as "valor_gtia_financiera", 
			0											            					as "valor_gtia_personal", 
			case
				when e.cod_obligacion::INTEGER in (41,42,43,44) then 0			
				when e.cod_obligacion::INTEGER in (31,32,33)    then 0                 -- PARA LEASING, SE ACTUALIZA CON LO QUE QUEDA POR PAGAR DESDE EL CUADRO DE PAGO
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
			a.cod_tipo_obligacion   													as "tipo_obligacion_interfaz",
			''                      													as "fecha_primera_cuota_inpaga",
			a.cod_moneda																as "cod_moneda",
			f.valor																		as "tipo_cambio"
		FROM interface.cartera_operaciones  a inner join interno.tipo_persona_rel b     on a.cod_persona = b.cod_entidad
											  inner join interno.operacion_titulo_rel c on a.cod_titulo_3 = c.cod_entidad
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
		  and extract(month from a.fecha_proceso) = extract(month from b.fecha_cuota);


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
					 )::NUMERIC(15) as "monto"
					   from 
				         reporte.rdc01_detalle a inner join 
						                          (
													    select
													       cod_operacion
														  ,sum(capital) 			as "capital"
														  ,sum(interes_por_pagar) 	as "interes_por_pagar"
														  ,sum(otros) 				as "otros"
														  ,sum(capital_pagado) 		as "capital_pagado"
														  ,sum(interes_pagado) 		as "interes_pagado"
														  ,sum(otros_pagado) 		as "otros_pagado"
													    from interface.cuadro_operaciones
													    group by cod_operacion
												   ) as b on a.codigo_operacion = b.cod_operacion
				                                 inner join interface.tipo_cambio c on a.cod_moneda = c.cod_moneda
		  		       where 
		                  a.tipo_obligacion::INTEGER in (31,32,33)
				   
              ) as BASE 
			  where a.codigo_operacion = BASE.codigo_operacion;

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
			   from (
						select 
						    cod_operacion
						   ,case
						      when (fecha_proceso - fecha_cuota) + 1 <  30                                                  then 1
							  when (fecha_proceso - fecha_cuota) + 1 >= 30  and (fecha_proceso - fecha_cuota) + 1 < 60      then 2
							  when (fecha_proceso - fecha_cuota) + 1 >= 60  and (fecha_proceso - fecha_cuota) + 1 < 90      then 3
							  when (fecha_proceso - fecha_cuota) + 1 >= 90  and (fecha_proceso - fecha_cuota) + 1 < 180     then 4
							  when (fecha_proceso - fecha_cuota) + 1 >= 180 
							       and fecha_cuota > make_date(extract(year from fecha_proceso)::int - 1, extract(month from fecha_proceso)::int, extract(day from fecha_proceso)::int)  then 5
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
					group by BASE.cod_operacion, tramo, c.valor
				) AS GBASE 
				where a.codigo_operacion = GBASE.cod_operacion;


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
			   from (
						select 
						    a.cod_operacion
						   ,
	                        case
							  -- Mantiene la mora antigua con la fecha de proceso
							  when fecha_cuota < fecha_aceleracion then
		 						   case
								      when (a.fecha_proceso - fecha_cuota) + 1 <  30                                                    then 1
									  when (a.fecha_proceso - fecha_cuota) + 1 >= 30  and (a.fecha_proceso - fecha_cuota) + 1 < 60      then 2
									  when (a.fecha_proceso - fecha_cuota) + 1 >= 60  and (a.fecha_proceso - fecha_cuota) + 1 < 90      then 3
									  when (a.fecha_proceso - fecha_cuota) + 1 >= 90  and (a.fecha_proceso - fecha_cuota) + 1 < 180     then 4
									  when (a.fecha_proceso - fecha_cuota) + 1 >= 180 
									       and fecha_cuota > make_date(extract(year from a.fecha_proceso)::int - 1, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)  then 5
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
								      when (a.fecha_proceso - fecha_aceleracion) + 1 <  30                                                          then 1
									  when (a.fecha_proceso - fecha_aceleracion) + 1 >= 30  and (a.fecha_proceso - fecha_aceleracion) + 1 < 60      then 2
									  when (a.fecha_proceso - fecha_aceleracion) + 1 >= 60  and (a.fecha_proceso - fecha_aceleracion) + 1 < 90      then 3
									  when (a.fecha_proceso - fecha_aceleracion) + 1 >= 90  and (a.fecha_proceso - fecha_aceleracion) + 1 < 180     then 4
									  when (a.fecha_proceso - fecha_aceleracion) + 1 >= 180 
									       and fecha_aceleracion > make_date(extract(year from a.fecha_proceso)::int - 1, extract(month from a.fecha_proceso)::int, extract(day from a.fecha_proceso)::int)  then 5
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
						   from interface.cuadro_operaciones a inner join interface.cartera_operaciones b on a.cod_operacion = b.cod_operacion
					) as BASE   inner join interface.cartera_operaciones b on BASE.cod_operacion = b.cod_operacion
					            inner join interface.tipo_cambio c         on b.cod_moneda = c.cod_moneda
					  where to_char(b.fecha_aceleracion,'YYYYMMDD')::VARCHAR <> '19000101'
					group by BASE.cod_operacion, tramo, c.valor
				) AS GBASE 
				where a.codigo_operacion = GBASE.cod_operacion;				



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
			   from (
						select 
						    cod_operacion
						   ,(capital - capital_pagado + interes_devengado + interes_moroso - interes_pagado) as "monto_origen"
						   ,(otros - otros_pagado)                                                           as "otros"
						    from interface.cuadro_operaciones  
					) as BASE   inner join interface.cartera_operaciones b on BASE.cod_operacion = b.cod_operacion
					            inner join interface.tipo_cambio c         on b.cod_moneda = c.cod_moneda
					  where to_char(b.fecha_aceleracion,'YYYYMMDD')::VARCHAR = '19000101'
					group by BASE.cod_operacion, c.valor
				) AS GBASE 
				where a.codigo_operacion = GBASE.cod_operacion;								

		
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
			  		where (capital <> capital_pagado or interes_por_pagar <> interes_pagado or otros <> otros_pagado)
					  and fecha_cuota <= fecha_proceso
			  group by cod_operacion
		   ) AS BASE where a.codigo_operacion = BASE.cod_operacion;

        -- | Actualiza garantias en deudores directos | --

           update reporte.rdc01_detalle as a
		   set 
		       valor_gtia_inmobiliaria = GBASE.gar_real_inmobiliaria
			  ,valor_gtia_mobiliaria   = GBASE.gar_real_mobiliaria
			  ,valor_gtia_financiera   = GBASE.gar_financiera
			  ,valor_gtia_personal     = GBASE.gar_personal
           from (
			    select 
				   cod_operacion,
				   sum(gar_real_inmobiliaria)                as "gar_real_inmobiliaria",
				   sum(gar_real_mobiliaria)                  as "gar_real_mobiliaria",
				   sum(gar_financiera)                       as "gar_financiera",
				   sum(gar_personal)                         as "gar_personal"
				   from (
					select 
					  a.cod_operacion,
					  a.rut_garante,
					  c.cod_persona,
					  ((a.gar_real_inmobiliaria * a.porc_real_inmobiliaria)/100)::numeric(15)    as "gar_real_inmobiliaria",
					  ((a.gar_real_mobiliaria * a.porc_real_mobiliaria)/100)::numeric(15)        as "gar_real_mobiliaria",
					  ((a.gar_financiera * a.porc_financiera)/100)::numeric(15)                  as "gar_financiera",
					  ((a.gar_personal * a.porc_personal)/100)::numeric(15)                      as "gar_personal"
					   from interface.cartera_garantias a inner join interno.tipo_persona_rel c on a.cod_persona = c.cod_entidad
				   ) as BASE
				   group by cod_operacion
			) as GBASE
			WHERE a.codigo_operacion = GBASE.cod_operacion
			and a.tipo_deudor = 1;

        
		-- | Actualiza garantias personales cuando sean mayores a la deuda, se dejan igual a la deuda | --			

			update reporte.rdc01_detalle set valor_gtia_personal = monto_actual
			where valor_gtia_personal > monto_actual
			and tipo_deudor = 1;


		-- | Se inserta deudores indirectos | --						

           insert into reporte.rdc01_detalle(fecha_proceso, rut, tipo_persona, codigo_operacion, operacion_titulo, tipo_deudor, tipo_obligacion, fecha_otorgamiento, carga_financiera, fecha_extincion, valor_gtia_inmobiliaria, valor_gtia_mobiliaria, valor_gtia_financiera, valor_gtia_personal, monto_original, monto_actual, monto_al_dia, monto_mora_1_tramo, monto_mora_2_tramo, monto_mora_3_tramo, monto_mora_4_tramo, monto_mora_5_tramo, monto_mora_6_tramo, monto_mora_7_tramo, monto_mora_8_tramo, monto_mora_9_tramo, mora_actual, deuda_renegociada, deuda_acelerada, tipo_persona_interfaz, operacion_titulo_interfaz, tipo_obligacion_interfaz, fecha_primera_cuota_inpaga, cod_moneda, tipo_cambio)
		   select
                a.fecha_proceso
			   ,GBASE.rut_garante              as "rut"
			   ,GBASE.cod_persona::integer     as "tipo_persona"
			   ,a.codigo_operacion
			   ,a.operacion_titulo
			   ,2                              as "tipo_deudor"
			   ,a.tipo_obligacion
			   ,a.fecha_otorgamiento
			   ,0                              as "carga_financiera"
			   ,a.fecha_extincion
			   ,0                              as "valor_gtia_inmobiliaria"
			   ,0                              as "valor_gtia_mobiliaria"
			   ,0                              as "valor_gtia_financiera"
			   ,a.valor_gtia_personal          as "valor_gtia_personal"            -- SE COLOCA SOLO PARA VALIDAR QUE LA DEUDA NO SEA MAYOR A LA GARANTIA PARA DEUDORES INDIRECTOS
			   ,a.monto_original
			   ,a.monto_actual
			   ,a.monto_al_dia
			   ,a.monto_mora_1_tramo
			   ,a.monto_mora_2_tramo
			   ,a.monto_mora_3_tramo
			   ,a.monto_mora_4_tramo
			   ,a.monto_mora_5_tramo
			   ,a.monto_mora_6_tramo
			   ,a.monto_mora_7_tramo
			   ,a.monto_mora_8_tramo
			   ,a.monto_mora_9_tramo
			   ,a.mora_actual
			   ,a.deuda_renegociada
			   ,a.deuda_acelerada
			   ,a.tipo_persona_interfaz
			   ,a.operacion_titulo_interfaz
			   ,a.tipo_obligacion_interfaz
			   ,a.fecha_primera_cuota_inpaga
			   ,a.cod_moneda
			   ,a.tipo_cambio
		    from reporte.rdc01_detalle a inner join 
               (
				    select 
					   cod_operacion,
					   rut_garante,
					   cod_persona,
					   sum(gar_personal)                         as "gar_personal"
					   from (
						select 
						  a.cod_operacion,
						  a.rut_garante,
						  c.cod_persona,
						  ((a.gar_personal * a.porc_personal)/100)::numeric(15)                      as "gar_personal"
						   from interface.cartera_garantias a inner join interno.tipo_persona_rel c on a.cod_persona = c.cod_entidad
						   where a.gar_personal > 0
					   ) as BASE
					   group by cod_operacion, rut_garante, cod_persona
			   ) as GBASE on a.codigo_operacion = GBASE.cod_operacion;



		-- | AJUSTA DEUDA DEL RUT INDIRECTO CUANDO ESTA SEA MAYOR A LA GARANTIA | --						

		update reporte.rdc01_detalle 
		       set 
			       monto_actual = valor_gtia_personal
			      ,monto_al_dia =  case
				                      when monto_al_dia = 0 then 0
									  else 
							             case 
										    when (monto_actual - valor_gtia_personal) <= monto_al_dia then monto_al_dia - (monto_actual - valor_gtia_personal)  
											else 0 end          -- CUANDO LA DIFERENCIA ES MAYOR QUE EL MONTO AL DIA
									  end
				  ,monto_mora_1_tramo = 
							       case
								      when monto_mora_1_tramo = 0 then 0
									  when (monto_actual - valor_gtia_personal - monto_al_dia) < 0 then monto_mora_1_tramo
									  else
								        case 
										    when (monto_actual - valor_gtia_personal - monto_al_dia) <= monto_mora_1_tramo then monto_mora_1_tramo - (monto_actual - valor_gtia_personal - monto_al_dia)
   								            else 0 end          -- CUANDO LA DIFERENCIA ES MAYOR QUE EL MONTO AL DIA + MORA_TRAMO_1													
									  end
				  ,monto_mora_2_tramo = 
				  				   case
									  when monto_mora_2_tramo = 0 then 0
									  when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo) < 0 then monto_mora_2_tramo
									  else
								        case 
										    when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo) <= monto_mora_2_tramo then monto_mora_2_tramo - (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo)
   								            else 0 end          -- CUANDO LA DIFERENCIA ES MAYOR QUE EL MONTO AL DIA + MORA_TRAMO_1 + MORA_TRAMO_2											
									  end
				  ,monto_mora_3_tramo = 
				  				   case
									  when monto_mora_3_tramo = 0 then 0
									  when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo) < 0 then monto_mora_3_tramo
									  else
								        case 
										    when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo) <= monto_mora_3_tramo then monto_mora_3_tramo - (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo)
   								            else 0 end          -- CUANDO LA DIFERENCIA ES MAYOR QUE EL MONTO AL DIA + MORA_TRAMO_1 + MORA_TRAMO_2 + MORA_TRAMO_3										
									  end
				  ,monto_mora_4_tramo = 
				  				   case
									  when monto_mora_4_tramo = 0 then 0
									  when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo) < 0 then monto_mora_4_tramo
									  else
								        case 
										    when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo) <= monto_mora_4_tramo then monto_mora_4_tramo - (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo)
   								            else 0 end          -- CUANDO LA DIFERENCIA ES MAYOR QUE EL MONTO AL DIA + MORA_TRAMO_1 + MORA_TRAMO_2 + MORA_TRAMO_3 + MORA_TRAMO_4									
									  end
				  ,monto_mora_5_tramo = 
				  				   case
									  when monto_mora_5_tramo = 0 then 0
									  when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo) < 0 then monto_mora_5_tramo
									  else
								        case 
										    when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo) <= monto_mora_5_tramo then monto_mora_5_tramo - (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo)
   								            else 0 end          -- CUANDO LA DIFERENCIA ES MAYOR QUE EL MONTO AL DIA + MORA_TRAMO_1 + MORA_TRAMO_2 + MORA_TRAMO_3 + MORA_TRAMO_4 + MORA_TRAMO_5								
									  end
				  ,monto_mora_6_tramo = 
				  				   case
									  when monto_mora_6_tramo = 0 then 0
									  when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo - monto_mora_5_tramo) < 0 then monto_mora_6_tramo
									  else
								        case 
										    when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo - monto_mora_5_tramo) <= monto_mora_6_tramo then monto_mora_6_tramo - (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo - monto_mora_5_tramo)
   								            else 0 end          -- CUANDO LA DIFERENCIA ES MAYOR QUE EL MONTO AL DIA + MORA_TRAMO_1 + MORA_TRAMO_2 + MORA_TRAMO_3 + MORA_TRAMO_4 + MORA_TRAMO_5 + MORA_TRAMO_6								
									  end
				  ,monto_mora_7_tramo = 
				  				   case
									  when monto_mora_7_tramo = 0 then 0
									  when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo - monto_mora_5_tramo - monto_mora_6_tramo) < 0 then monto_mora_7_tramo
									  else
								        case 
										    when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo - monto_mora_5_tramo - monto_mora_6_tramo) <= monto_mora_7_tramo then monto_mora_7_tramo - (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo - monto_mora_5_tramo - monto_mora_6_tramo)
   								            else 0 end          -- CUANDO LA DIFERENCIA ES MAYOR QUE EL MONTO AL DIA + MORA_TRAMO_1 + MORA_TRAMO_2 + MORA_TRAMO_3 + MORA_TRAMO_4 + MORA_TRAMO_5 + MORA_TRAMO_6 + MORA_TRAMO_7									
									  end
				  ,monto_mora_8_tramo = 
				  				   case
									  when monto_mora_8_tramo = 0 then 0
									  when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo - monto_mora_5_tramo - monto_mora_6_tramo - monto_mora_7_tramo) < 0 then monto_mora_8_tramo
									  else
								        case 
										    when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo - monto_mora_5_tramo - monto_mora_6_tramo - monto_mora_7_tramo) <= monto_mora_8_tramo then monto_mora_8_tramo - (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo - monto_mora_5_tramo - monto_mora_6_tramo - monto_mora_7_tramo)
   								            else 0 end          -- CUANDO LA DIFERENCIA ES MAYOR QUE EL MONTO AL DIA + MORA_TRAMO_1 + MORA_TRAMO_2 + MORA_TRAMO_3 + MORA_TRAMO_4 + MORA_TRAMO_5 + MORA_TRAMO_6 + MORA_TRAMO_7 + MORA_TRAMO_8									
									  end
				  ,monto_mora_9_tramo = 
				  				   case
									  when monto_mora_9_tramo = 0 then 0
									  when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo - monto_mora_5_tramo - monto_mora_6_tramo - monto_mora_7_tramo - monto_mora_8_tramo) < 0 then monto_mora_9_tramo
									  else
								        case 
										    when (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo - monto_mora_5_tramo - monto_mora_6_tramo - monto_mora_7_tramo - monto_mora_8_tramo) <= monto_mora_9_tramo then monto_mora_9_tramo - (monto_actual - valor_gtia_personal - monto_al_dia - monto_mora_1_tramo - monto_mora_2_tramo - monto_mora_3_tramo - monto_mora_4_tramo - monto_mora_5_tramo - monto_mora_6_tramo - monto_mora_7_tramo - monto_mora_8_tramo)
   								            else 0 end          -- CUANDO LA DIFERENCIA ES MAYOR QUE EL MONTO AL DIA + MORA_TRAMO_1 + MORA_TRAMO_2 + MORA_TRAMO_3 + MORA_TRAMO_4 + MORA_TRAMO_5 + MORA_TRAMO_6 + MORA_TRAMO_7 + MORA_TRAMO_8 + MORA_TRAMO_9								
									  end									  
			      
		where valor_gtia_personal < monto_actual
		  and tipo_deudor = 2;

		-- | MUEVE CERO AL CAMPO DE GARANTIA PERSONAL EN DEUDORES INDIRECTOS | --						

		update reporte.rdc01_detalle set valor_gtia_personal = 0
		where tipo_deudor = 2;


		-- | EXCLUSION DE MOROSOS QUE CUMPLIERON 5 AñOS O MAS | --

		delete from reporte.rdc01_detalle a
		using interno.exclusion_morosidad b
		where a.codigo_operacion = b.cod_operacion
		  and b.fecha_exclusion <= a.fecha_proceso;


		-- | GENERA RDC01_FINAL | --						


		insert into reporte.rdc01_final(rut, tipo_persona, codigo_operacion, operacion_titulo, tipo_deudor, tipo_obligacion, fecha_otorgamiento, carga_financiera, fecha_extincion, valor_gtia_inmobiliaria, valor_gtia_mobiliaria, valor_gtia_financiera, valor_gtia_personal, monto_original, monto_actual, monto_al_dia, monto_mora_1_tramo, monto_mora_2_tramo, monto_mora_3_tramo, monto_mora_4_tramo, monto_mora_5_tramo, monto_mora_6_tramo, monto_mora_7_tramo, monto_mora_8_tramo, monto_mora_9_tramo, mora_actual, deuda_renegociada, deuda_acelerada)
		select 
			rut, 
			tipo_persona,
		    codigo_operacion, 
		    operacion_titulo,
			tipo_deudor,
			tipo_obligacion,
			fecha_otorgamiento, 
	   		carga_financiera,
			fecha_extincion,
			valor_gtia_inmobiliaria, 
			valor_gtia_mobiliaria, 
			valor_gtia_financiera, 
			valor_gtia_personal, 
			monto_original,     
			monto_actual,
			monto_al_dia,
			monto_mora_1_tramo,
			monto_mora_2_tramo,
			monto_mora_3_tramo,
			monto_mora_4_tramo,
			monto_mora_5_tramo,
			monto_mora_6_tramo,
			monto_mora_7_tramo,
			monto_mora_8_tramo,
			monto_mora_9_tramo,
			mora_actual,
			deuda_renegociada, 
			deuda_acelerada
		FROM reporte.rdc01_detalle;


		-- | GENERA RDC01_HIST | --						


		insert into reporte.rdc01_hist(fecha_proceso, rut, tipo_persona, codigo_operacion, operacion_titulo, tipo_deudor, tipo_obligacion, fecha_otorgamiento, carga_financiera, fecha_extincion, valor_gtia_inmobiliaria, valor_gtia_mobiliaria, valor_gtia_financiera, valor_gtia_personal, monto_original, monto_actual, monto_al_dia, monto_mora_1_tramo, monto_mora_2_tramo, monto_mora_3_tramo, monto_mora_4_tramo, monto_mora_5_tramo, monto_mora_6_tramo, monto_mora_7_tramo, monto_mora_8_tramo, monto_mora_9_tramo, mora_actual, deuda_renegociada, deuda_acelerada)
		select 
		    fecha_archivo    as "fecha_proceso",
			rut, 
			tipo_persona,
		    codigo_operacion, 
		    operacion_titulo,
			tipo_deudor,
			tipo_obligacion,
			fecha_otorgamiento, 
	   		carga_financiera,
			fecha_extincion,
			valor_gtia_inmobiliaria, 
			valor_gtia_mobiliaria, 
			valor_gtia_financiera, 
			valor_gtia_personal, 
			monto_original,     
			monto_actual,
			monto_al_dia,
			monto_mora_1_tramo,
			monto_mora_2_tramo,
			monto_mora_3_tramo,
			monto_mora_4_tramo,
			monto_mora_5_tramo,
			monto_mora_6_tramo,
			monto_mora_7_tramo,
			monto_mora_8_tramo,
			monto_mora_9_tramo,
			mora_actual,
			deuda_renegociada, 
			deuda_acelerada
		FROM reporte.rdc01_final;		


		-- | GENERA RDC01_TEXTO | --								
		

		insert into reporte.rdc01_texto(registro)  
		select RPAD(codigo_institucion || 'RDC01' || fecha_archivo,322,' ')  as "registro"
		union all
		select 
			LPAD(rut,10,'0') ||  
			tipo_persona::varchar ||
		    RPAD(codigo_operacion,30,' ') || 
		    operacion_titulo::varchar ||
			tipo_deudor::varchar ||
			LPAD(tipo_obligacion::varchar,2,'0') ||
			fecha_otorgamiento || 
	   		LPAD(carga_financiera::varchar,15,'0') ||
			fecha_extincion ||
			LPAD(valor_gtia_inmobiliaria::varchar,15,'0') || 
			LPAD(valor_gtia_mobiliaria::varchar,15,'0') || 
			LPAD(valor_gtia_financiera::varchar,15,'0') ||
			LPAD(valor_gtia_personal::varchar,15,'0') || 
			LPAD(monto_original::varchar,15,'0') ||
			LPAD(monto_actual::varchar,15,'0') ||
			LPAD(monto_al_dia::varchar,15,'0') ||
			LPAD(monto_mora_1_tramo::varchar,15,'0') ||
			LPAD(monto_mora_2_tramo::varchar,15,'0') ||
			LPAD(monto_mora_3_tramo::varchar,15,'0') ||
			LPAD(monto_mora_4_tramo::varchar,15,'0') ||
			LPAD(monto_mora_5_tramo::varchar,15,'0') ||
			LPAD(monto_mora_6_tramo::varchar,15,'0') ||
			LPAD(monto_mora_7_tramo::varchar,15,'0') ||
			LPAD(monto_mora_8_tramo::varchar,15,'0') ||
			LPAD(monto_mora_9_tramo::varchar,15,'0') ||
			LPAD(mora_actual::varchar,4,'0') ||
			deuda_renegociada::varchar || 
			deuda_acelerada::varchar                                         as "registro"
		FROM reporte.rdc01_final;


		-- | GENERA CARATULA | --								

		/* Item 1:  Número registros informados (recuento simple)*/

		select count(1)
		into var_valor
		from reporte.rdc01_final;
		
		insert into reporte.rdc01_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número registros informados (recuento simple)', var_valor);


		/* Item 2:  Número de deudores vigentes (recuento de RUTs distintos)*/

		 select count(1)
		 into var_valor
		 from (		 
		   select rut from reporte.rdc01_final group by rut
		 ) as B;

		insert into reporte.rdc01_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de deudores vigentes (recuento de RUTs distintos)', var_valor);		 


		/* Item 3:  Total obligaciones reportables al día y operaciones contingentes (suma campo 16)*/		

		select coalesce(sum(monto_al_dia),0)
		into var_valor
		from reporte.rdc01_final;

		insert into reporte.rdc01_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Total obligaciones reportables al día y operaciones contingentes (suma campo 16)', var_valor);


		/* Item 4:  Total obligaciones reportables con morosidad menor a 30 días (suma campo 17)*/

		select coalesce(sum(monto_mora_1_tramo),0)
		into var_valor
		from reporte.rdc01_final;

		insert into reporte.rdc01_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Total obligaciones reportables con morosidad menor a 30 días (suma campo 17)', var_valor);


		/* Item 5:  Total obligaciones reportables con morosidad desde 30 a menos de 60 días (suma campo 18)*/

		select coalesce(sum(monto_mora_2_tramo),0)
		into var_valor
		from reporte.rdc01_final;

		insert into reporte.rdc01_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Total obligaciones reportables con morosidad desde 30 a menos de 60 días (suma campo 18)', var_valor);


		/* Item 6:  Total obligaciones reportables con morosidad desde 60 a menos de 90 días (suma campo 19)*/

		select coalesce(sum(monto_mora_3_tramo),0)
		into var_valor
		from reporte.rdc01_final;

		insert into reporte.rdc01_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Total obligaciones reportables con morosidad desde 60 a menos de 90 días (suma campo 19)', var_valor);


		/* Item 7:  Total obligaciones reportables con morosidad desde 90 días a menos de 180 días (suma campo 20)*/

		select coalesce(sum(monto_mora_4_tramo),0)
		into var_valor
		from reporte.rdc01_final;

		insert into reporte.rdc01_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Total obligaciones reportables con morosidad desde 90 días a menos de 180 días (suma campo 20)', var_valor);		


		/* Item 8:  Total obligaciones reportables con morosidad desde 180 días a menos de un año (suma campo 21)*/

		select coalesce(sum(monto_mora_5_tramo),0)
		into var_valor
		from reporte.rdc01_final;

		insert into reporte.rdc01_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Total obligaciones reportables con morosidad desde 180 días a menos de un año (suma campo 21)', var_valor);


		/* Item 9:  Total obligaciones reportables con morosidad desde un año a menos de dos años (suma campo 22)*/

		select coalesce(sum(monto_mora_6_tramo),0)
		into var_valor
		from reporte.rdc01_final;

		insert into reporte.rdc01_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Total obligaciones reportables con morosidad desde un año a menos de dos años (suma campo 22)', var_valor);		
		

		/* Item 10:  Total obligaciones reportables con morosidad desde dos años a menos de tres años (suma campo 23)*/

		select coalesce(sum(monto_mora_7_tramo),0)
		into var_valor
		from reporte.rdc01_final;

		insert into reporte.rdc01_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Total obligaciones reportables con morosidad desde dos años a menos de tres años (suma campo 23)', var_valor);		


		/* Item 11:  Total obligaciones reportables con morosidad desde tres años a menos de cuatro años (suma campo 24)*/

		select coalesce(sum(monto_mora_8_tramo),0)
		into var_valor
		from reporte.rdc01_final;

		insert into reporte.rdc01_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Total obligaciones reportables con morosidad desde tres años a menos de cuatro años (suma campo 24)', var_valor);


		/* Item 12:  Total obligaciones reportables con morosidad superior a cuatro años (suma campo 25)*/

		select coalesce(sum(monto_mora_9_tramo),0)
		into var_valor
		from reporte.rdc01_final;

		insert into reporte.rdc01_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Total obligaciones reportables con morosidad superior a cuatro años (suma campo 25)', var_valor);


		/* Item 13:  Número de deudores con morosidad en cualquier tramo (recuento distintivo de RUTs con montos de mora distintos de cero)*/

		select count(1)
		into var_valor
		from (
			select rut
			from reporte.rdc01_final
			where (monto_mora_1_tramo + monto_mora_2_tramo + monto_mora_3_tramo + monto_mora_4_tramo + monto_mora_5_tramo + monto_mora_6_tramo + monto_mora_7_tramo + monto_mora_8_tramo + monto_mora_9_tramo) > 0
			group by rut
		) as B;

		insert into reporte.rdc01_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de deudores con morosidad en cualquier tramo (recuento distintivo de RUTs con montos de mora distintos de cero)', var_valor);		


		/* Item 14:  Total líneas de crédito de libre disposición (suma campo 15 para campo 6 igual a 42)*/

		select coalesce(sum(monto_actual),0)
		into var_valor
		from reporte.rdc01_final
		where tipo_obligacion = 42;

		insert into reporte.rdc01_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Total líneas de crédito de libre disposición (suma campo 15 para campo 6 igual a 42)', var_valor);		

		
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