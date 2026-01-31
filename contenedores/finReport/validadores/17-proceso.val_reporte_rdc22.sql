CREATE OR REPLACE PROCEDURE proceso.val_reporte_rdc22()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
	v_descripcion varchar(2000);
BEGIN

		/**************************************************/
		/***	GENERA validador.rdc22_detalle			***/
		/**************************************************/

		truncate table validador.rdc22_detalle;

		insert into validador.rdc22_detalle (linea, tipo_obligacion, valor_contable, filler)
		select
			 linea
			,substring(registro,  1,  2) 					as "tipo_obligacion"
			,substring(registro,  3, 15) 					as "valor_contable"
			,substring(registro, 18,  7)					as "filler"
		from validador.rdc22_texto where linea > 1;


		/*
			1: Codigo de la institucion no corresponde
		*/

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 1;

		insert into validador.rdc22_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
		SELECT 
			 linea
			,1        											as "num_validador"
			,v_descripcion										as "descripcion"
			,'header-cod_institucion'							as "campo"	
			,substring(registro,1,10)							as "dato_reportado"
			,proceso.val_num_1(substring(registro,1,10))	    as "status"
		FROM validador.rdc22_texto
			 where linea = 1;


		/*
			2: Identificacion del archivo no corresponde
		*/
		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 2;

		insert into validador.rdc22_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
		SELECT 
			 linea
			,2        											as "num_validador"
			,v_descripcion										as "descripcion"
			,'header-ident_archivo'								as "campo"
			,substring(registro,11,5)							as "dato_reportado"
			,proceso.val_num_2('RDC22', 11, 5, registro)		as "status"
		FROM validador.rdc22_texto where linea = 1;


		/*
			9: Fecha reportada no corresponde al formato YYYYMMDD
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 9;

		insert into validador.rdc22_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
		SELECT 
			 linea
			,9        											as "num_validador"
			,v_descripcion										as "descripcion"	
			,'header-fecha_archivo'								as "campo"
			,substring(registro,16,8)							as "dato_reportado"
			,proceso.val_num_9(substring(registro,16,8))		as "status"
		FROM validador.rdc22_texto where linea = 1;			


		/*
			16: Filler debe ser completado con espacios y tener un largo especifico
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 16;

		insert into validador.rdc22_resultado (linea, num_validador, descripcion, campo, dato_reportado, status)
		SELECT 
			 linea
			,16        												as "num_validador"
			,v_descripcion											as "descripcion"
			,'header-filler'										as "campo"
			,substring(registro, 24, 1)								as "dato_reportado"
			,proceso.val_num_16(substring(registro, 24, 1), 1)		as "status"
		FROM validador.rdc22_texto where linea = 1;				


		/*
			3: Largo del registro no corresponde
		*/

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 3;

		FOR rec IN 

			SELECT 
				 linea
				,3                  					as "num_validador"
				,v_descripcion							as "descripcion"
				,'registro'								as "campo"
				,registro								as "dato_reportado"
				,proceso.val_num_3(registro, 24)		as "status"
		    FROM validador.rdc22_texto 
		
		LOOP

			INSERT INTO validador.rdc22_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		
		
		/*
			8: Tipo de obligacion reportado no corresponde a tabla 126
		*/

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 8;		

		FOR rec IN 

			SELECT 
				 linea
				,8                  													as "num_validador"
				,v_descripcion															as "descripcion"
				,'tipo_obligacion'														as "campo"
				,tipo_obligacion														as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_obligacion, 'interno.tabla_banco_126') 	as "status"
		    FROM validador.rdc22_detalle

		LOOP

			INSERT INTO validador.rdc22_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;				


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: valor_contable
		*/

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'valor_contable'														as "campo"
				,valor_contable															as "dato_reportado"
				,proceso.val_num_10(valor_contable)										as "status"
		    FROM validador.rdc22_detalle

		LOOP

			INSERT INTO validador.rdc22_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;				
		
		
		EXCEPTION WHEN OTHERS THEN
		    INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		    VALUES (
		        CURRENT_TIMESTAMP,
		        'ERROR',
		        '',
		        'proceso.val_reporte_rdc22',
		        SQLERRM
		    );
		
		    RAISE EXCEPTION 'Error en validación RDC22: %', SQLERRM;
END;
$$