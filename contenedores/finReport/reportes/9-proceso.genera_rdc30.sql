CREATE OR REPLACE PROCEDURE proceso.genera_rdc30()
LANGUAGE plpgsql
AS $$
DECLARE
	fecha_archivo varchar(8);
	codigo_institucion varchar(10);
	var_valor numeric(15);
	v_fecha date;
	v_fecha_anterior date;
	
BEGIN
	BEGIN

		/*
			Proceso de generacion de RDC30
		*/


		-- | Determina fecha de proceso y fecha anterior | --		

		select valor
		into fecha_archivo
		from interno.parametros_generales where cod = '3';

		v_fecha := to_date(fecha_archivo, 'YYYYMMDD');
		v_fecha_anterior := v_fecha - 7;

		RAISE NOTICE 'Fecha de proceso para RDC30: %', fecha_archivo;

		-- | Determina codigo de la institucion | --		

		select LPAD(valor,10,'0')
		into codigo_institucion
		from interno.parametros_generales where cod = '1';		

		RAISE NOTICE 'Codigo de institucion para RDC30: %', codigo_institucion;

		-- | Trunca tablas de uso en el procedimiento | --		

		TRUNCATE TABLE reporte.rdc30_caratula;
		TRUNCATE TABLE reporte.rdc30_texto;
		TRUNCATE TABLE reporte.rdc30_detalle;
		TRUNCATE TABLE reporte.rdc30_final;

		delete from reporte.rdc30_hist where fecha_proceso = fecha_archivo;


		-- | En caso que no sea viernes salir del procedimiento | --

		if EXTRACT(DOW FROM v_fecha) <> 5 then

			RAISE NOTICE 'Fecha de proceso para RDC30 no corresponde a un viernes';
			RETURN;
		
		end if;

		-- | Logica de generacion de reporte desde la interfaz registro_consentimientos | --

		insert into reporte.rdc30_detalle(  fecha_proceso					
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
			 a.fecha_proceso												as "fecha_proceso"
			,a.cod_consentimiento											as "cod_consentimiento"
			,a.fecha_otorgamiento											as "fecha_otorgamiento"
			,a.hora_otorgamiento											as "hora_otorgamiento"
			,a.fecha_fin_consentimiento										as "fecha_fin_consentimiento"
			,case
				when a.fecha_fin_consentimiento = '19000101' then '999999'
				else a.hora_fin_consentimiento end							as "hora_fin_consentimiento"
			,a.rut_consultado												as "rut_consultado"
			,b.cod_consentimiento											as "cod_medio_consentimiento"
			,c.cod_finalidad												as "cod_finalidad_consentimiento"
			,a.rut_ejecutivo												as "rut_ejecutivo"
			,d.cod_objetivo													as "cod_objetivo_consentimiento"
			,a.cod_encriptado												as "cod_encriptado"
		FROM historico.registro_consentimientos a inner join interno.medio_consentimiento_rel b     on a.cod_medio_consentimiento = b.cod_entidad
											  	  inner join interno.finalidad_consentimiento_rel c on a.cod_finalidad_consentimiento = c.cod_entidad
											  	  inner join interno.objetivo_consentimiento_rel d  on a.cod_objetivo_consentimiento = d.cod_entidad
			 where 
			    (a.fecha_otorgamiento > v_fecha_anterior and a.fecha_otorgamiento <= v_fecha) or 
				(a.fecha_fin_consentimiento > v_fecha_anterior and a.fecha_fin_consentimiento <= v_fecha);
		   

		-- | GENERA RDC30_FINAL | --						


		insert into reporte.rdc30_final(
											 cod_consentimiento				
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
			 cod_consentimiento				
			,to_char(fecha_otorgamiento,'YYYYMMDD')::varchar			as "fecha_otorgamiento"
			,LPAD(hora_otorgamiento,6,'0')								as "hora_otorgamiento"
			,to_char(fecha_fin_consentimiento,'YYYYMMDD')::varchar		as "fecha_fin_consentimiento"
			,LPAD(hora_fin_consentimiento,6,'0')						as "hora_fin_consentimiento"
			,LPAD(rut_consultado,10,'0')								as "rut_consultado"
			,cod_medio_consentimiento		
			,cod_finalidad_consentimiento	
			,LPAD(rut_ejecutivo,10,'0')									as "rut_ejecutivo"					
			,LPAD(cod_objetivo_consentimiento,2,'0')					as "cod_objetivo_consentimiento"	
			,cod_encriptado
		FROM reporte.rdc30_detalle;


		-- | GENERA RDC30_HIST | --						


		insert into reporte.rdc30_hist(
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
		     fecha_archivo                 as "fecha_proceso"
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
		FROM reporte.rdc30_final;		


		-- | GENERA RDC30_TEXTO | --								
		

		insert into reporte.rdc30_texto(registro)  
		select RPAD(codigo_institucion || 'RDC30' || fecha_archivo,136,' ')  as "registro"
		union all
		select 
		    RPAD(cod_consentimiento,20,' ') || 
			fecha_otorgamiento || 
 			hora_otorgamiento ||
			fecha_fin_consentimiento ||
			hora_fin_consentimiento ||
			rut_consultado ||
			cod_medio_consentimiento ||
			cod_finalidad_consentimiento ||
			rut_ejecutivo ||
			cod_objetivo_consentimiento ||
			RPAD(cod_encriptado,64,' ')			as "registro"
		FROM reporte.rdc30_final;


		-- | GENERA CARATULA | --								

		/* Item 1:  Número de registros totales informados (recuento simple)*/

		select count(1)
		into var_valor
		from reporte.rdc30_final;

		
		insert into reporte.rdc30_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de registros totales informados (recuento simple)', var_valor);


		/* Item 2:  Número de consentimientos obtenidos en el periodo (recuento distintivo de campo 1 con campo 2 igual a una fecha existente dentro de la última semana)*/

		 select count(distinct cod_consentimiento)
		 into var_valor
		 from reporte.rdc30_detalle
		 where fecha_otorgamiento > v_fecha_anterior and fecha_otorgamiento <= v_fecha;


		insert into reporte.rdc30_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de consentimientos obtenidos en el periodo (recuento distintivo de campo 1 con campo 2 igual a una fecha existente dentro de la última semana)', var_valor);		 


		/* Item 3:  Número de consentimientos revocados en el periodo (recuento distintivo de campo 4 distinto de “19000101”)*/		
		/* ultima semana se entiende despues del ultimo viernes, es decir, sabado a viernes */

		select count(distinct cod_consentimiento)
		into var_valor
		from reporte.rdc30_final
		where fecha_fin_consentimiento <> '19000101' and to_date(fecha_fin_consentimiento,'YYYYMMDD') > v_fecha_anterior and to_date(fecha_fin_consentimiento,'YYYYMMDD') <= v_fecha;

		insert into reporte.rdc30_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de consentimientos revocados en el periodo (recuento distintivo de campo 4 distinto de “19000101”)', var_valor);


		/* Item 4:  Número de consentimientos obtenidos en forma digital (recuento distintivo de campo1 con campo 7 igual 1 dentro de la última semana)*/
		/* ultima semana se entiende despues del ultimo viernes, es decir, sabado a viernes */

		select count(distinct cod_consentimiento)
		into var_valor
		from reporte.rdc30_detalle 
		where cod_medio_consentimiento = '1' and fecha_otorgamiento > v_fecha_anterior and fecha_otorgamiento <= v_fecha;

		insert into reporte.rdc30_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de consentimientos obtenidos en forma digital (recuento distintivo de campo1 con campo 7 igual 1 dentro de la última semana)', var_valor);


		/* Item 5:  Número de consentimientos obtenidos en forma verbal (recuento distintivo de campo 1con campo 7 igual 2 dentro de la última semana)*/
		/* ultima semana se entiende despues del ultimo viernes, es decir, sabado a viernes */

		select count(distinct cod_consentimiento)
		into var_valor
		from reporte.rdc30_detalle 
		where cod_medio_consentimiento = '2' and fecha_otorgamiento > v_fecha_anterior and fecha_otorgamiento <= v_fecha;

		insert into reporte.rdc30_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de consentimientos obtenidos en forma verbal (recuento distintivo de campo 1con campo 7 igual 2 dentro de la última semana)', var_valor);


		/* Item 6:  Número de consentimientos obtenidos en forma escrita (recuento distintivo de campo 1 con campo 7 igual 3 dentro de la última semana)*/
		/* ultima semana se entiende despues del ultimo viernes, es decir, sabado a viernes */

		select count(distinct cod_consentimiento)
		into var_valor
		from reporte.rdc30_detalle 
		where cod_medio_consentimiento = '3' and fecha_otorgamiento > v_fecha_anterior and fecha_otorgamiento <= v_fecha;

		insert into reporte.rdc30_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de consentimientos obtenidos en forma escrita (recuento distintivo de campo 1 con campo 7 igual 3 dentro de la última semana)', var_valor);		


	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.genera_rdc30',
			SQLERRM
		);
	END;
END;
$$