CREATE OR REPLACE PROCEDURE proceso.genera_rdc31()
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
			Proceso de generacion de RDC31
		*/


		-- | Determina fecha de proceso y fecha anterior | --		

		select valor
		into fecha_archivo
		from interno.parametros_generales where cod = '3';

		v_fecha := to_date(fecha_archivo, 'YYYYMMDD');
		v_fecha_anterior := v_fecha - 7;

		RAISE NOTICE 'Fecha de proceso para RDC31: %', fecha_archivo;

		-- | Determina codigo de la institucion | --		

		select LPAD(valor,10,'0')
		into codigo_institucion
		from interno.parametros_generales where cod = '1';		

		RAISE NOTICE 'Codigo de institucion para RDC31: %', codigo_institucion;

		-- | Trunca tablas de uso en el procedimiento | --		

		TRUNCATE TABLE reporte.rdc31_caratula;
		TRUNCATE TABLE reporte.rdc31_texto;
		TRUNCATE TABLE reporte.rdc31_detalle;
		TRUNCATE TABLE reporte.rdc31_final;

		delete from reporte.rdc31_hist where fecha_proceso = fecha_archivo;


		-- | En caso que no sea viernes salir del procedimiento | --

		if EXTRACT(DOW FROM v_fecha) <> 5 then

			RAISE NOTICE 'Fecha de proceso para RDC31 no corresponde a un viernes';
			RETURN;
		
		end if;

		-- | Logica de generacion de reporte desde la interfaz acceso_consentimientos | --

		insert into reporte.rdc31_detalle(   fecha_proceso					
											,cod_consentimiento				
											,fecha_acceso
											,hora_acceso
											,rut_mandatario

		)
		select 
			 fecha_proceso												as "fecha_proceso"
			,cod_consentimiento											as "cod_consentimiento"
			,fecha_acceso												as "fecha_acceso"
			,hora_acceso												as "hora_acceso"
			,rut_mandatario												as "rut_mandatario"
		FROM historico.acceso_consentimientos
			 where 
			    fecha_acceso > v_fecha_anterior and fecha_acceso <= v_fecha;
		   

		-- | GENERA RDC31_FINAL | --						


		insert into reporte.rdc31_final(
											 cod_consentimiento				
											,fecha_acceso				
											,hora_acceso
											,rut_mandatario
		)
		select 
			 cod_consentimiento				
			,to_char(fecha_acceso,'YYYYMMDD')::varchar														as "fecha_acceso"
			,LPAD(hora_acceso,6,'0')																		as "hora_acceso"
			,case 
				when rut_mandatario is null or trim(rut_mandatario) = '' then rpad(rut_mandatario,10,' ')
			    else LPAD(rut_mandatario,10,'0') end 														as "rut_mandatario"
		FROM reporte.rdc31_detalle;


		-- | GENERA RDC31_HIST | --						


		insert into reporte.rdc31_hist(
										 fecha_proceso              	
										 ,cod_consentimiento				
									  	 ,fecha_acceso				
										 ,hora_acceso
										 ,rut_mandatario

		)
		select 
		     fecha_archivo                 as "fecha_proceso"
			,cod_consentimiento				
			,fecha_acceso
			,hora_acceso
			,rut_mandatario
		FROM reporte.rdc31_final;		


		-- | GENERA RDC31_TEXTO | --								
		

		insert into reporte.rdc31_texto(registro)  
		select RPAD(codigo_institucion || 'RDC31' || fecha_archivo,44,' ')  as "registro"
		union all
		select 
		    RPAD(cod_consentimiento,20,' ') || 
			fecha_acceso || 
 			hora_acceso ||
			rut_mandatario						as "registro"
		FROM reporte.rdc31_final;


		-- | GENERA CARATULA | --								

		/* Item 1:  Número de registros totales informados (recuento simple)*/

		select count(1)
		into var_valor
		from reporte.rdc31_final;

		insert into reporte.rdc31_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de registros totales informados (recuento simple)', var_valor);


		/* Item 2:  Número de accesos al REDEC bajo consentimiento de mandatarios (recuento de accesos con campo 4 no nulo)*/

		 select count(1)
		 into var_valor
		 from reporte.rdc31_final
		 where trim(rut_mandatario) <> '';


		insert into reporte.rdc31_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de accesos al REDEC bajo consentimiento de mandatarios (recuento de accesos con campo 4 no nulo)', var_valor);		 


		/* Item 3:  Número de accesos al REDEC bajo consentimiento en días hábiles (lunes a viernes, excluyendo días feriados)*/		

		select count(1)
		into var_valor
  	    from reporte.rdc31_detalle a left join interno.feriados b on a.fecha_acceso = to_date(trim(b.fecha),'YYYYMMDD')
   	    where
		    a.fecha_acceso is not null
			and (extract(DOW from a.fecha_acceso) between 1 and 5)
			and b.fecha is null;


		insert into reporte.rdc31_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de accesos al REDEC bajo consentimiento en días hábiles (lunes a viernes, excluyendo días feriados)', var_valor);


		/* Item 4:  Número de accesos al REDEC bajo consentimiento entre 20:00 y 8:00 horas*/


		select count(1)
		into var_valor
		from reporte.rdc31_detalle 
		where to_timestamp(hora_acceso,'HH24MISS')::time >= '20:00:00' or
		      to_timestamp(hora_acceso,'HH24MISS')::time <= '08:00:00';

		insert into reporte.rdc31_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de accesos al REDEC bajo consentimiento entre 20:00 y 8:00 horas', var_valor);


	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.genera_rdc31',
			SQLERRM
		);
	END;
END;
$$