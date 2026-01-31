CREATE OR REPLACE PROCEDURE proceso.genera_rdc22()
LANGUAGE plpgsql
AS $$
DECLARE
	fecha_archivo varchar(8);
	codigo_institucion varchar(10);
	var_valor numeric(15);
	v_fecha date;
	
BEGIN
	BEGIN

		/*
			Proceso de generacion de RDC22
		*/


		-- | Determina fecha de proceso | --		

		select valor
		into fecha_archivo
		from interno.parametros_generales where cod = '3';

		v_fecha := to_date(fecha_archivo, 'YYYYMMDD');

		RAISE NOTICE 'Fecha de proceso para RDC22: %', fecha_archivo;

		-- | Determina codigo de la institucion | --		

		select LPAD(valor,10,'0')
		into codigo_institucion
		from interno.parametros_generales where cod = '1';		

		RAISE NOTICE 'Codigo de institucion para RDC22: %', codigo_institucion;

		-- | Trunca tablas de uso en el procedimiento | --		

		TRUNCATE TABLE reporte.rdc22_caratula;
		TRUNCATE TABLE reporte.rdc22_texto;
		TRUNCATE TABLE reporte.rdc22_detalle;
		TRUNCATE TABLE reporte.rdc22_final;

		delete from reporte.rdc22_hist where fecha_proceso = fecha_archivo;

		-- | Logica de generacion de reporte desde la interfaz cartera_operaciones | --

		insert into reporte.rdc22_detalle(fecha_proceso, tipo_obligacion, valor_contable, tipo_obligacion_interfaz)
		select 
			a.fecha_proceso, 
			e.cod_obligacion::INTEGER            										as "tipo_obligacion",
			round(sum(a.valor_contable),0)                                              as "valor_contable",
			a.cod_tipo_obligacion														as "tipo_obligacion_interfaz"
		from interface.cartera_operaciones  a inner join interno.tabla_banco_126_rel e  on a.cod_tipo_obligacion = e.cod_entidad
			 where a.fecha_proceso = v_fecha
			 and e.cod_obligacion not in ('13','14','15','16')
		group by  a.fecha_proceso
		         ,e.cod_obligacion
				 ,a.cod_tipo_obligacion;
		   

		-- | GENERA RDC22_FINAL | --						


		insert into reporte.rdc22_final(tipo_obligacion, valor_contable)
		select 
			tipo_obligacion,
			sum(valor_contable)  as "valor_contable"
		FROM reporte.rdc22_detalle
		group by tipo_obligacion;


		-- | GENERA RDC22_HIST | --


		insert into reporte.rdc22_hist(fecha_proceso, tipo_obligacion, valor_contable)
		select 
		    fecha_archivo    as "fecha_proceso",
			tipo_obligacion,
			valor_contable
		FROM reporte.rdc22_final;


		-- | GENERA RDC22_TEXTO | --
		

		insert into reporte.rdc22_texto(registro)  
		select RPAD(codigo_institucion || 'RDC22' || fecha_archivo,24,' ')  as "registro"
		union all
		select 
		  RPAD(
			LPAD(tipo_obligacion::varchar,2,'0') ||
	   		LPAD(valor_contable::varchar,15,'0')
		    ,24,' ') 														as "registro"
		FROM reporte.rdc22_final;


		-- | GENERA CARATULA | --								

		/* Item 1:  Número de registros totales informados (recuento simple)*/

		select count(1)
		into var_valor
		from reporte.rdc22_final;
		
		insert into reporte.rdc22_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Número de registros totales informados (recuento simple)', var_valor);


		/* Item 2:  Valor contable de operaciones informadas en el period0 (suma campo 2)*/

		select coalesce(sum(valor_contable),0)
		into var_valor
		from reporte.rdc22_final;

		insert into reporte.rdc22_caratula (fecha, item, valor) 
		values (fecha_archivo, 'Valor contable de operaciones informadas en el period0 (suma campo 2)', var_valor);		 

	
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.genera_rdc22',
			SQLERRM
		);
	END;
END;
$$