CREATE OR REPLACE PROCEDURE proceso.genera_rdc20()
LANGUAGE plpgsql
AS $$
DECLARE
	fecha_archivo varchar(8);
	fecha_anterior varchar(8);
	codigo_institucion varchar(10);
	var_valor numeric(20);
	val int;
	cod_uf varchar(50);
	fecha_archivo_dt date;
	fecha_anterior_dt date;
	
BEGIN
	BEGIN

		/*
			Proceso de generacion de RDC20
		*/


		-- | Determina fecha de proceso | --		

		select valor
		into fecha_archivo
		from interno.parametros_generales where cod = '3';

		RAISE NOTICE 'Fecha de proceso para RDC20: %', fecha_archivo;

		-- | Trunca tablas de uso en el procedimiento | --		

		TRUNCATE TABLE reporte.rdc20_caratula;
		TRUNCATE TABLE reporte.rdc20_texto;
		TRUNCATE TABLE reporte.rdc20_detalle_1;
		TRUNCATE TABLE reporte.rdc20_detalle_2;
		TRUNCATE TABLE reporte.rdc20_detalle_3;
		TRUNCATE TABLE reporte.rdc20_detalle_4;
		TRUNCATE TABLE reporte.rdc20_final_1;
		TRUNCATE TABLE reporte.rdc20_final_2;
		TRUNCATE TABLE reporte.rdc20_final_3;
		TRUNCATE TABLE reporte.rdc20_final_4;

		delete from reporte.rdc20_hist_1 where fecha_proceso = fecha_archivo;
		delete from reporte.rdc20_hist_2 where fecha_proceso = fecha_archivo;
		delete from reporte.rdc20_hist_3 where fecha_proceso = fecha_archivo;
		delete from reporte.rdc20_hist_4 where fecha_proceso = fecha_archivo;

		
	
		-- | Determina codigo de la institucion | --		

		select LPAD(valor,10,'0')
		into codigo_institucion
		from interno.parametros_generales where cod = '1';		

		RAISE NOTICE 'Codigo de institucion para RDC20: %', codigo_institucion;

		-- | Determina codigo de moneda UF usada por la institucion | --		

		select valor
		into cod_uf
		from interno.parametros_generales where cod = '2';	


		-- | LOGICA DE GENERACION RDC20 | --


				/* Valida si corresponde enviar el archivo */
		
				select count(1)
				into val
				from interno.calendario_rdc20 where fecha = fecha_archivo;
		
				if val = 0 then
					RAISE NOTICE 'No existe envio en calendario_rdc20 para la fecha: %', fecha_archivo;
					return;
				end if;
		
		
				/* Valida si es primer envio */
		
				select count(1)
				into val
				from interno.calendario_rdc20 where fecha < fecha_archivo;
		
				if val = 0 then
					RAISE NOTICE 'No hay fechas anteriores con que comparar: %', fecha_archivo;
					return;
				end if;		

				/* Calculo de fecha de envio anterior */

				select max(fecha)
				into fecha_anterior
				from interno.calendario_rdc20 where fecha < fecha_archivo;


				fecha_archivo_dt := to_date(fecha_archivo, 'YYYYMMDD');
				fecha_anterior_dt := to_date(fecha_anterior, 'YYYYMMDD');
				
		
		-- | Determinacion de flujo 01 Amortizaciones de capitales cuando hay pagos y los creditos existen en ambos periodos | --

	         insert into reporte.rdc20_detalle_1 (fecha_proceso, tipo_registro, tipo_obligacion, tipo_flujo, monto, codigo_operacion, rut, cod_tipo_obligacion)
			 select 
			   fecha_archivo_dt										as "fecha_proceso"
			  ,1   													as "tipo_registro"
			  ,tipo_obligacion
			  ,1													as "tipo_flujo"
			  ,((a.capital - b.capital) * c.valor)::numeric(20)		as "monto"
			  ,a.cod_operacion
			  ,rut
			  ,tipo_obligacion_interfaz								as "cod_tipo_obligacion"
			  from 
	              (
					select 
					    a.cod_operacion
					   ,b.tipo_obligacion
					   ,b.rut
					   ,b.tipo_obligacion_interfaz
					   ,b.cod_moneda
					   ,sum(capital - capital_pagado) as "capital"
					   from interface.cuadro_operaciones a inner join reporte.rdc01_detalle b on a.cod_operacion = b.codigo_operacion
					   where b.tipo_deudor = 1
					  group by a.cod_operacion
					          ,b.tipo_obligacion
					   		  ,b.rut
					   		  ,b.tipo_obligacion_interfaz
					   		  ,b.cod_moneda
				  ) a inner join 
				  (
					select 
					    cod_operacion
					   ,sum(capital - capital_pagado) as "capital"
					   from historico.cuadro_operaciones where fecha_proceso = fecha_anterior_dt
					   group by cod_operacion
				  ) b on a.cod_operacion = b.cod_operacion
				    inner join interface.tipo_cambio c on a.cod_moneda = c.cod_moneda
				  where a.capital < b.capital;


		-- | Determinacion de flujo 02 Interes capitalizado | --

	         insert into reporte.rdc20_detalle_1 (fecha_proceso, tipo_registro, tipo_obligacion, tipo_flujo, monto, codigo_operacion, rut, cod_tipo_obligacion)
			 select 
			   fecha_archivo_dt					          			as "fecha_proceso"
			  ,1   													as "tipo_registro"
			  ,tipo_obligacion
			  ,2													as "tipo_flujo"
			  ,((a.capital - b.capital) * c.valor)::numeric(20)		as "monto"
			  ,a.cod_operacion
			  ,rut
			  ,tipo_obligacion_interfaz								as "cod_tipo_obligacion"
			  from 
	              (
					select 
					    a.cod_operacion
					   ,b.tipo_obligacion
					   ,b.rut
					   ,b.tipo_obligacion_interfaz
					   ,b.cod_moneda
					   ,sum(capital - capital_pagado) as "capital"
					   from interface.cuadro_operaciones a inner join reporte.rdc01_detalle b on a.cod_operacion = b.codigo_operacion
					   where b.tipo_deudor = 1
					  group by a.cod_operacion
					          ,b.tipo_obligacion
					   		  ,b.rut
					   		  ,b.tipo_obligacion_interfaz
					   		  ,b.cod_moneda
				  ) a inner join 
				  (
					select 
					    cod_operacion
					   ,sum(capital - capital_pagado) as "capital"
					   from historico.cuadro_operaciones where fecha_proceso = fecha_anterior_dt
					   group by cod_operacion
				  ) b on a.cod_operacion = b.cod_operacion
				    inner join interface.tipo_cambio c on a.cod_moneda = c.cod_moneda
				  where a.capital > b.capital;				  



		-- | Determinacion de flujo 02 Interes capitalizado por reajustes, esto esta en las preguntas y respuestas de la CMF | --

	         insert into reporte.rdc20_detalle_1 (fecha_proceso, tipo_registro, tipo_obligacion, tipo_flujo, monto, codigo_operacion, rut, cod_tipo_obligacion)
			 select 
			   fecha_archivo_dt					          							as "fecha_proceso"
			  ,1   																	as "tipo_registro"
			  ,tipo_obligacion
			  ,2																	as "tipo_flujo"
			  ,((a.capital  * c.valor) - (b.capital  * d.valor))::numeric(20)		as "monto"
			  ,a.cod_operacion
			  ,rut
			  ,tipo_obligacion_interfaz												as "cod_tipo_obligacion"
			  from 
	              (
					select 
					    a.cod_operacion
					   ,b.tipo_obligacion
					   ,b.rut
					   ,b.tipo_obligacion_interfaz
					   ,b.cod_moneda
					   ,sum(capital - capital_pagado) as "capital"
					   from interface.cuadro_operaciones a inner join reporte.rdc01_detalle b on a.cod_operacion = b.codigo_operacion
					   where b.cod_moneda = cod_uf and b.tipo_deudor = 1
					  group by a.cod_operacion
					          ,b.tipo_obligacion
					   		  ,b.rut
					   		  ,b.tipo_obligacion_interfaz
					   		  ,b.cod_moneda
				  ) a inner join 
				  (
					select 
					    a.cod_operacion
					   ,sum(a.capital - a.capital_pagado) as "capital"
					   from historico.cuadro_operaciones a inner join historico.cartera_operaciones b on a.cod_operacion = b.cod_operacion and a.fecha_proceso = b.fecha_proceso
					   where a.fecha_proceso = fecha_anterior_dt
					     and b.cod_moneda = cod_uf
					   group by a.cod_operacion
				  ) b on a.cod_operacion = b.cod_operacion
				    inner join interface.tipo_cambio c on a.cod_moneda = c.cod_moneda
					inner join (select *from historico.tipo_cambio where fecha_proceso = fecha_anterior_dt) d on a.cod_moneda = d.cod_moneda
				  where a.capital = b.capital;				  


		-- | Determinacion de flujo 03 Creditos nuevos | --	
		-- | Primero se considera que todos son nuevos (Flujo 03), luego se chequea en interface variacion_stock | --

		
	         insert into reporte.rdc20_detalle_1 (fecha_proceso, tipo_registro, tipo_obligacion, tipo_flujo, monto, codigo_operacion, rut, cod_tipo_obligacion)
			 select 
			   fecha_archivo_dt					          							as "fecha_proceso"
			  ,1   																	as "tipo_registro"
			  ,tipo_obligacion
			  ,3																	as "tipo_flujo"
			  ,a.monto_actual::numeric(20)											as "monto"
			  ,a.codigo_operacion
			  ,rut
			  ,tipo_obligacion_interfaz												as "cod_tipo_obligacion"
			  from 
	              (
					select 
					    codigo_operacion
					   ,tipo_obligacion
					   ,rut
					   ,tipo_obligacion_interfaz
					   ,cod_moneda
					   ,monto_actual
					   from reporte.rdc01_detalle
					   where tipo_deudor = 1
				  ) a left join 
				  (
					select 
					    codigo_operacion
					   from reporte.rdc01_hist
					   where fecha_proceso = fecha_anterior
					   and tipo_deudor = 1
				  ) b on a.codigo_operacion = b.codigo_operacion
					where b.codigo_operacion is null;


		-- | Determinacion de flujo 05 y 07 Compra de carteras y Cesion de creditos adquiridos | --	

		update reporte.rdc20_detalle_1 as a
			set tipo_flujo = c.cod_flujo::int
		from historico.variacion_stock as b inner join interno.tipo_flujo_rel as c on b.tipo_flujo = c.cod_entidad
		where b.fecha_proceso >= fecha_anterior_dt and b.fecha_proceso <= fecha_archivo_dt
		  and a.codigo_operacion = 	b.cod_operacion
		  and c.cod_flujo in ('05','07');


		-- | Determinacion de flujo 01 Amortizacion de capital | --	
		-- | Primero se considera todos los creditos que desaparecen como creditos que se pagaron, despues se veran si son ventas de cartera, etc | --

		
	         insert into reporte.rdc20_detalle_1 (fecha_proceso, tipo_registro, tipo_obligacion, tipo_flujo, monto, codigo_operacion, rut, cod_tipo_obligacion)
			 select 
			   fecha_archivo_dt					          							as "fecha_proceso"
			  ,1   																	as "tipo_registro"
			  ,tipo_obligacion
			  ,1																	as "tipo_flujo"
			  ,a.monto_actual::numeric(20) * -1										as "monto"
			  ,a.cod_operacion
			  ,rut
			  ,tipo_obligacion_interfaz												as "cod_tipo_obligacion"
			  from 
	              (
					select 
					    b.cod_operacion
					   ,a.tipo_obligacion
					   ,a.rut
					   ,cod_tipo_obligacion											as "tipo_obligacion_interfaz"
					   ,cod_moneda
					   ,monto_actual
					   from reporte.rdc01_hist a inner join historico.cartera_operaciones b on a.codigo_operacion = b.cod_operacion
					   where tipo_deudor = 1 and a.fecha_proceso = fecha_anterior
				  ) a left join 
				  (
					select 
					    codigo_operacion
					   from reporte.rdc01_detalle 
					   where tipo_deudor = 1
				  ) b on a.cod_operacion = b.codigo_operacion
					where b.codigo_operacion is null;


		-- | Determinacion de flujo 04 y 06 Venta de Carteras y Cesion de credito del reportante | --	
		-- | Determinacion de flujo 08 y 10  | --	

		update reporte.rdc20_detalle_1 as a
			set tipo_flujo = c.cod_flujo::int
		from historico.variacion_stock as b inner join interno.tipo_flujo_rel as c on b.tipo_flujo = c.cod_entidad
		where b.fecha_proceso >= fecha_anterior_dt and b.fecha_proceso <= fecha_archivo_dt
		 and a.codigo_operacion = b.cod_operacion	
		  and c.cod_flujo in ('04','06','08','10');


		-- | Determinacion de flujo 09, Exclusion por mora que cumplieron 5 o mas años  | --	

		update reporte.rdc20_detalle_1 as a
			set tipo_flujo = 9
		from interno.exclusion_morosidad as b
		where b.fecha_exclusion >= fecha_anterior_dt and b.fecha_exclusion <= fecha_archivo_dt
		      and a.codigo_operacion = b.cod_operacion;	
		

		-- | GENERA REGISTRO 2 | --	


		insert into reporte.rdc20_detalle_2 (fecha_proceso, tipo_registro, rut_deudor, codigo_operacion, fecha_informacion, tipo_obligacion, ident_tribunal, monto, cod_tipo_obligacion)
		select
			 a.fecha_proceso
			,2               										as "tipo_registro"
			,b.rut
			,a.codigo_operacion
			,to_char(c.fecha_efectivo_flujo,'YYYYMMDD')::varchar	as "fecha_informacion"	
			,a.tipo_obligacion
			,c.ident_tribunal::int									as "ident_tribunal"
			,abs(a.monto)                                           as "monto"
			,a.cod_tipo_obligacion
		from reporte.rdc20_detalle_1 a inner join reporte.rdc01_hist b on a.codigo_operacion = b.codigo_operacion
									   inner join historico.variacion_stock c on a.codigo_operacion = c.cod_operacion
		where a.tipo_flujo in (8,10)
		  and b.tipo_deudor = 1
		  and b.fecha_proceso = fecha_anterior
		  and c.fecha_proceso >= fecha_anterior_dt and c.fecha_proceso <= fecha_archivo_dt;



		-- | GENERA REGISTRO 3 | --	


		insert into reporte.rdc20_detalle_3 (fecha_proceso, tipo_registro, rut_comprador, rut_deudor, codigo_operacion, fecha_informacion, tipo_obligacion, monto, cod_tipo_obligacion)
		select
			 a.fecha_proceso
			,3               										as "tipo_registro"
			,c.rut_tercera_parte									as "rut_comprador"	
			,b.rut													as "rut_deudor"
			,a.codigo_operacion
			,to_char(c.fecha_efectivo_flujo,'YYYYMMDD')::varchar	as "fecha_informacion"	
			,a.tipo_obligacion
			,abs(a.monto)                                           as "monto"
			,a.cod_tipo_obligacion
		from reporte.rdc20_detalle_1 a inner join reporte.rdc01_hist b on a.codigo_operacion = b.codigo_operacion
									   inner join historico.variacion_stock c on a.codigo_operacion = c.cod_operacion
		where a.tipo_flujo in (4,6)
		  and b.tipo_deudor = 1
		  and b.fecha_proceso = fecha_anterior
		  and c.fecha_proceso >= fecha_anterior_dt and c.fecha_proceso <= fecha_archivo_dt;



		-- | GENERA REGISTRO 4 | --	


		insert into reporte.rdc20_detalle_4 (fecha_proceso, tipo_registro, rut_vendedor, rut_deudor, codigo_operacion, fecha_informacion, tipo_obligacion, monto, cod_tipo_obligacion)
		select
			 a.fecha_proceso
			,4               										as "tipo_registro"
			,c.rut_tercera_parte									as "rut_vendedor"	
			,b.rut													as "rut_deudor"
			,a.codigo_operacion
			,to_char(c.fecha_efectivo_flujo,'YYYYMMDD')::varchar	as "fecha_informacion"	
			,a.tipo_obligacion
			,abs(a.monto)                                           as "monto"
			,a.cod_tipo_obligacion
		from reporte.rdc20_detalle_1 a inner join reporte.rdc01_detalle b on a.codigo_operacion = b.codigo_operacion
									   inner join historico.variacion_stock c on a.codigo_operacion = c.cod_operacion
		where a.tipo_flujo in (5,7)
		  and b.tipo_deudor = 1
		  and c.fecha_proceso >= fecha_anterior_dt and c.fecha_proceso <= fecha_archivo_dt;
		  



		-- | GENERA RDC20_FINAL | --						


		insert into reporte.rdc20_final_1(tipo_registro, tipo_obligacion, tipo_flujo, monto)
		select 
		   tipo_registro
		  ,tipo_obligacion
		  ,tipo_flujo
		  ,sum(monto)		"monto"
		from reporte.rdc20_detalle_1
		group by tipo_registro
		  		,tipo_obligacion
				,tipo_flujo;


		insert into reporte.rdc20_final_2(tipo_registro, rut_deudor, codigo_operacion, fecha_informacion, tipo_obligacion, ident_tribunal, monto)		
		select
			 tipo_registro
			,rut_deudor
			,codigo_operacion
			,fecha_informacion
			,tipo_obligacion
			,ident_tribunal
			,monto
		from reporte.rdc20_detalle_2;


		insert into reporte.rdc20_final_3(tipo_registro, rut_comprador, rut_deudor, codigo_operacion, fecha_informacion, tipo_obligacion, monto)		
		select
			 tipo_registro
			,rut_comprador
			,rut_deudor
			,codigo_operacion
			,fecha_informacion
			,tipo_obligacion
			,monto
		from reporte.rdc20_detalle_3;		


		insert into reporte.rdc20_final_4(tipo_registro, rut_vendedor, rut_deudor, codigo_operacion, fecha_informacion, tipo_obligacion, monto)		
		select
			 tipo_registro
			,rut_vendedor
			,rut_deudor
			,codigo_operacion
			,fecha_informacion
			,tipo_obligacion
			,monto
		from reporte.rdc20_detalle_4;				


		-- | GENERA RDC20_HIST | --						


		insert into reporte.rdc20_hist_1(fecha_proceso, tipo_registro, tipo_obligacion, tipo_flujo, monto)
		select 
		     fecha_archivo    as "fecha_proceso"
			,tipo_registro
			,tipo_obligacion
			,tipo_flujo
			,monto
		FROM reporte.rdc20_final_1;	


		insert into reporte.rdc20_hist_2(fecha_proceso, tipo_registro, rut_deudor, codigo_operacion, fecha_informacion, tipo_obligacion, ident_tribunal, monto)	
		select
			fecha_archivo     as "fecha_proceso"		
			,tipo_registro
			,rut_deudor
			,codigo_operacion
			,fecha_informacion
			,tipo_obligacion
			,ident_tribunal
			,monto
		from reporte.rdc20_final_2;


		insert into reporte.rdc20_hist_3(fecha_proceso, tipo_registro, rut_comprador, rut_deudor, codigo_operacion, fecha_informacion, tipo_obligacion, monto)		
		select
			 fecha_archivo    as "fecha_proceso"
			,tipo_registro
			,rut_comprador
			,rut_deudor
			,codigo_operacion
			,fecha_informacion
			,tipo_obligacion
			,monto
		from reporte.rdc20_final_3;


		insert into reporte.rdc20_hist_4(fecha_proceso, tipo_registro, rut_vendedor, rut_deudor, codigo_operacion, fecha_informacion, tipo_obligacion, monto)
		select
			 fecha_archivo    as "fecha_proceso"
			,tipo_registro
			,rut_vendedor
			,rut_deudor
			,codigo_operacion
			,fecha_informacion
			,tipo_obligacion
			,monto
		from reporte.rdc20_final_4;	
		

		-- | GENERA RDC20_TEXTO | --								
		

		insert into reporte.rdc20_texto(registro)  
		select RPAD(codigo_institucion || 'RDC20' || fecha_archivo,82,' ')  as "registro"
		
		union all
		
		select
		  RPAD(
			LPAD(tipo_registro::varchar,2,'0') ||
			LPAD(tipo_obligacion::varchar,2,'0') ||
			LPAD(tipo_flujo::varchar,2,'0') ||
			LPAD(abs(monto)::varchar,20,'0') ||
			case when monto < 0 then '-' else '+' end
			,82,' ')														as "registro"
		from reporte.rdc20_final_1
		
		union all

		select
		  RPAD(	
			LPAD(tipo_registro::varchar,2,'0') ||
			LPAD(rut_deudor::varchar,10,'0') ||
			RPAD(codigo_operacion,30,' ')	||
			fecha_informacion ||
			LPAD(tipo_obligacion::varchar,2,'0') ||
			LPAD(ident_tribunal::varchar,7,'0') ||
			LPAD(monto::varchar,20,'0') 
			,82,' ')														as "registro"
		from reporte.rdc20_final_2

		union all

		select
		  RPAD(	
			LPAD(tipo_registro::varchar,2,'0') ||
			LPAD(rut_comprador::varchar,10,'0') ||
			LPAD(rut_deudor::varchar,10,'0') ||
			RPAD(codigo_operacion,30,' ')	||
			fecha_informacion ||
			LPAD(tipo_obligacion::varchar,2,'0') ||
			LPAD(monto::varchar,20,'0') 
			,82,' ')														as "registro"
		from reporte.rdc20_final_3

		union all

		select
		  RPAD(	
			LPAD(tipo_registro::varchar,2,'0') ||
			LPAD(rut_vendedor::varchar,10,'0') ||
			LPAD(rut_deudor::varchar,10,'0') ||
			RPAD(codigo_operacion,30,' ')	||
			fecha_informacion ||
			LPAD(tipo_obligacion::varchar,2,'0') ||
			LPAD(monto::varchar,20,'0') 
			,82,' ')														as "registro"
		from reporte.rdc20_final_4;


		-- | GENERA CARATULA | --								

		/* Item 1:  Número de registros totales informados en registro 01 (recuento de registros)*/

		select count(1)
		into var_valor
		from reporte.rdc20_final_1;
		
		insert into reporte.rdc20_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de registros totales informados en registro 01 (recuento de registros)', var_valor);


		/* Item 2:  Monto bruto que aumenta el stock de deudas en registro 01 (suma de variaciones positivas campo 4)*/

		 select coalesce(sum(monto),0)
		 into var_valor
		 from reporte.rdc20_final_1
		 where monto >= 0;

		insert into reporte.rdc20_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Monto bruto que aumenta el stock de deudas en registro 01 (suma de variaciones positivas campo 4)', var_valor);		 


		/* Item 3:  Monto bruto que disminuye el stock de deuda en registro 01 (suma de variaciones negativas campo 4)*/		

		 select coalesce(sum(monto),0)
		 into var_valor
		 from reporte.rdc20_final_1
		 where monto < 0;

		insert into reporte.rdc20_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Monto bruto que disminuye el stock de deuda en registro 01 (suma de variaciones negativas campo 4)', var_valor);


		/* Item 4:  Monto neto que varía el stock de deuda en registro 01 (suma de variaciones campo 4)*/

		 select coalesce(sum(monto),0)
		 into var_valor
		 from reporte.rdc20_final_1;

		insert into reporte.rdc20_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Monto neto que varía el stock de deuda en registro 01 (suma de variaciones campo 4)', var_valor);


		/* Item 5:  Número de obligaciones reportables informadas en registro 02 (recuento de registros)*/

		 select count(1)
		 into var_valor
		 from reporte.rdc20_final_2;

		insert into reporte.rdc20_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de obligaciones reportables informadas en registro 02 (recuento de registros)', var_valor);


		/* Item 6:  Monto bruto que disminuye el stock de deuda informadas en registro 02 (suma campo 7)*/

		 select coalesce(sum(monto),0)
		 into var_valor
		 from reporte.rdc20_final_2;

		insert into reporte.rdc20_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Monto bruto que disminuye el stock de deuda informadas en registro 02 (suma campo 7)', var_valor);


		/* Item 7:  Número de obligaciones reportables informadas en registro 03 (recuento de registros)*/

		 select count(1)
		 into var_valor
		 from reporte.rdc20_final_3;

		insert into reporte.rdc20_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de obligaciones reportables informadas en registro 03 (recuento de registros)', var_valor);


		/* Item 8:  Monto bruto que disminuye el stock de deuda informadas en registro 03 (suma campo 7)*/

		 select coalesce(sum(monto),0)
		 into var_valor
		 from reporte.rdc20_final_3;

		insert into reporte.rdc20_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Monto bruto que disminuye el stock de deuda informadas en registro 03 (suma campo 7)', var_valor);


		/* Item 9:  Número de obligaciones reportables informadas en registro 04 (recuento de registros)*/

		 select count(1)
		 into var_valor
		 from reporte.rdc20_final_4;

		insert into reporte.rdc20_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de obligaciones reportables informadas en registro 04 (recuento de registros)', var_valor);
		

		/* Item 10:  Monto bruto que aumenta el stock de deuda informadas en registro 04 (suma campo 7)*/

		 select coalesce(sum(monto),0)
		 into var_valor
		 from reporte.rdc20_final_4;

		insert into reporte.rdc20_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Monto bruto que aumenta el stock de deuda informadas en registro 04 (suma campo 7)', var_valor);


		
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.genera_rdc20',
			SQLERRM
		);
	END;
END;
$$