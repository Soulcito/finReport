CREATE OR REPLACE PROCEDURE proceso.val_reporte_rdc01()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
	v_descripcion varchar(2000);
BEGIN

		/**************************************************/
		/***	GENERA validador.rdc01_detalle			***/
		/**************************************************/

		truncate table validador.rdc01_detalle;

		insert into validador.rdc01_detalle (linea, rut, tipo_persona, codigo_operacion, operacion_titulo, tipo_deudor, tipo_obligacion, fecha_otorgamiento, carga_financiera, fecha_extincion, valor_gtia_inmobiliaria, valor_gtia_mobiliaria, valor_gtia_financiera, valor_gtia_personal, monto_original, monto_actual, monto_al_dia, monto_mora_1_tramo, monto_mora_2_tramo, monto_mora_3_tramo, monto_mora_4_tramo, monto_mora_5_tramo, monto_mora_6_tramo, monto_mora_7_tramo, monto_mora_8_tramo, monto_mora_9_tramo, mora_actual, deuda_renegociada, deuda_acelerada)
		select
			 linea
			,substring(registro,   1, 10) 					as "rut"
			,substring(registro,  11,  1) 					as "tipo_persona"
			,substring(registro,  12, 30) 					as "codigo_operacion"
			,substring(registro,  42,  1) 					as "operacion_titulo"
			,substring(registro,  43,  1) 					as "tipo_deudor"
			,substring(registro,  44,  2) 					as "tipo_obligacion"
			,substring(registro,  46,  8) 					as "fecha_otorgamiento"
			,substring(registro,  54, 15) 					as "carga_financiera"
			,substring(registro,  69,  8) 					as "fecha_extincion"
			,substring(registro,  77, 15) 					as "valor_gtia_inmobiliaria"
			,substring(registro,  92, 15) 					as "valor_gtia_mobiliaria"
			,substring(registro, 107, 15) 					as "valor_gtia_financiera"
			,substring(registro, 122, 15) 					as "valor_gtia_personal"
			,substring(registro, 137, 15) 					as "monto_original"
			,substring(registro, 152, 15) 					as "monto_actual"
			,substring(registro, 167, 15) 					as "monto_al_dia"
			,substring(registro, 182, 15) 					as "monto_mora_1_tramo"
			,substring(registro, 197, 15) 					as "monto_mora_2_tramo"
			,substring(registro, 212, 15) 					as "monto_mora_3_tramo"
			,substring(registro, 227, 15) 					as "monto_mora_4_tramo"
			,substring(registro, 242, 15) 					as "monto_mora_5_tramo"
			,substring(registro, 257, 15) 					as "monto_mora_6_tramo"
			,substring(registro, 272, 15) 					as "monto_mora_7_tramo"
			,substring(registro, 287, 15) 					as "monto_mora_8_tramo"
			,substring(registro, 302, 15) 					as "monto_mora_9_tramo"
			,substring(registro, 317,  4) 					as "mora_actual"
			,substring(registro, 321,  1) 					as "deuda_renegociada"
			,substring(registro, 322,  1) 					as "deuda_acelerada"
		from validador.rdc01_texto where linea > 1;


		/*
			1: Codigo de la institucion no corresponde
		*/

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 1;

		insert into validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
		SELECT 
			 linea
			,1        											as "num_validador"
			,v_descripcion										as "descripcion"
			,'header-cod_institucion'							as "campo"	
			,substring(registro,1,10)							as "dato_reportado"
			,proceso.val_num_1(substring(registro,1,10))	    as "status"
		FROM validador.rdc01_texto
			 where linea = 1;


		/*
			2: Identificacion del archivo no corresponde
		*/
		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 2;

		insert into validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
		SELECT 
			 linea
			,2        											as "num_validador"
			,v_descripcion										as "descripcion"
			,'header-ident_archivo'								as "campo"
			,substring(registro,11,5)							as "dato_reportado"
			,proceso.val_num_2('RDC01', 11, 5, registro)		as "status"
		FROM validador.rdc01_texto where linea = 1;


		/*
			9: Fecha reportada no corresponde al formato YYYYMMDD
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 9;

		insert into validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
		SELECT 
			 linea
			,9        											as "num_validador"
			,v_descripcion										as "descripcion"	
			,'header-fecha_archivo'								as "campo"
			,substring(registro,16,8)							as "dato_reportado"
			,proceso.val_num_9(substring(registro,16,8))		as "status"
		FROM validador.rdc01_texto where linea = 1;			


		/*
			16: Filler debe ser completado con espacios y tener un largo especifico
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 16;

		insert into validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
		SELECT 
			 linea
			,16        												as "num_validador"
			,v_descripcion											as "descripcion"
			,'header-filler'										as "campo"
			,substring(registro, 24, 299)							as "dato_reportado"
			,proceso.val_num_16(substring(registro, 24, 299), 299)	as "status"
		FROM validador.rdc01_texto where linea = 1;				


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
				,proceso.val_num_3(registro, 322)		as "status"
		    FROM validador.rdc01_texto 
		
		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			4: RUT informado es invalido
		*/

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 4;

		FOR rec IN 

			SELECT 
				 linea
				,4                  					as "num_validador"
				,v_descripcion							as "descripcion"
				,'rut'									as "campo"
				,rut									as "dato_reportado"
				,proceso.val_num_4(rut)					as "status"
		    FROM validador.rdc01_detalle
		
		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			5: Tipo de persona informado no corresponde
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 5;

		FOR rec IN 

			SELECT 
				 linea
				,5                  											as "num_validador"
				,v_descripcion													as "descripcion"
				,'tipo_persona'													as "campo"	
				,tipo_persona													as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_persona, 'interno.tipo_persona') as "status"
		    FROM validador.rdc01_detalle
		
		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			6: Operacion Titulo III reportado no corresponde
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 6;

		FOR rec IN 

			SELECT 
				 linea
				,6                  													as "num_validador"
				,v_descripcion															as "descripcion"
				,'operacion_titulo'														as "campo"
				,operacion_titulo														as "dato_reportado"
				,proceso.val_codigo_tabla(operacion_titulo, 'interno.operacion_titulo') as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			7: Tipo deudor reportado no corresponde
		*/

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 7;		

		FOR rec IN 

			SELECT 
				 linea
				,7                  													as "num_validador"
				,v_descripcion															as "descripcion"
				,'tipo_deudor'															as "campo"	
				,tipo_deudor															as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_deudor, 'interno.tipo_deudor') 			as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			9: Fecha reportada no corresponde al formato YYYYMMDD
			campo: fecha_otorgamiento
		*/

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 9;				

		FOR rec IN 

			SELECT 
				 linea
				,9                  													as "num_validador"
				,v_descripcion															as "descripcion"	
				,'fecha_otorgamiento'													as "campo"
				,fecha_otorgamiento														as "dato_reportado"
				,proceso.val_num_9(fecha_otorgamiento)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: carga_financiera
		*/

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'carga_financiera'														as "campo"
				,carga_financiera														as "dato_reportado"
				,proceso.val_num_10(carga_financiera)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			9: Fecha reportada no corresponde al formato YYYYMMDD
			campo: fecha_extincion
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 9;

		FOR rec IN 

			SELECT 
				 linea
				,9                  													as "num_validador"
				,v_descripcion															as "descripcion"
				,'fecha_extincion'														as "campo"
				,fecha_extincion														as "dato_reportado"
				,proceso.val_num_9(fecha_extincion)										as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: valor_gtia_inmobiliaria
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'valor_gtia_inmobiliaria'												as "campo"
				,valor_gtia_inmobiliaria												as "dato_reportado"
				,proceso.val_num_10(valor_gtia_inmobiliaria)							as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: valor_gtia_mobiliaria
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'valor_gtia_mobiliaria'												as "campo"
				,valor_gtia_mobiliaria													as "dato_reportado"
				,proceso.val_num_10(valor_gtia_mobiliaria)								as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: valor_gtia_financiera
		*/

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'valor_gtia_financiera'												as "campo"
				,valor_gtia_financiera													as "dato_reportado"
				,proceso.val_num_10(valor_gtia_financiera)								as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: valor_gtia_personal
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"	
				,'valor_gtia_personal'													as "campo"
				,valor_gtia_personal													as "dato_reportado"
				,proceso.val_num_10(valor_gtia_personal)								as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: monto_original
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"	
				,'monto_original'														as "campo"
				,monto_original															as "dato_reportado"
				,proceso.val_num_10(monto_original)										as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: monto_actual
		*/

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'monto_actual'															as "campo"
				,monto_actual															as "dato_reportado"
				,proceso.val_num_10(monto_actual)										as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: monto_al_dia
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'monto_al_dia'															as "campo"
				,monto_al_dia															as "dato_reportado"
				,proceso.val_num_10(monto_al_dia)										as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: monto_mora_1_tramo
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'monto_mora_1_tramo'													as "campo"
				,monto_mora_1_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_1_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: monto_mora_2_tramo
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'monto_mora_2_tramo'													as "campo"
				,monto_mora_2_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_2_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: monto_mora_3_tramo
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'monto_mora_3_tramo'													as "campo"
				,monto_mora_3_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_3_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: monto_mora_4_tramo
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'monto_mora_4_tramo'													as "campo"
				,monto_mora_4_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_4_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: monto_mora_5_tramo
		*/

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"	
				,'monto_mora_5_tramo'													as "campo"
				,monto_mora_5_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_5_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: monto_mora_6_tramo
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'monto_mora_6_tramo'													as "campo"
				,monto_mora_6_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_6_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: monto_mora_7_tramo
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"	
				,'monto_mora_7_tramo'													as "campo"
				,monto_mora_7_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_7_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: monto_mora_8_tramo
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'monto_mora_8_tramo'													as "campo"
				,monto_mora_8_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_8_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: monto_mora_9_tramo
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'monto_mora_9_tramo'													as "campo"
				,monto_mora_9_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_9_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			campo: mora_actual
		*/

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'mora_actual'															as "campo"
				,mora_actual															as "dato_reportado"
				,proceso.val_num_10(mora_actual)										as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			12: Deuda renegociada reportada no corresponde
			campo: deuda_renegociada
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 12;

		FOR rec IN 

			SELECT 
				 linea
				,12                 													as "num_validador"
				,v_descripcion															as "descripcion"
				,'deuda_renegociada'													as "campo"
				,deuda_renegociada														as "dato_reportado"
				,proceso.val_en_dominio(deuda_renegociada, ARRAY['1','2'])				as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			13: Deuda acelerada reportada no corresponde
			campo: deuda_acelerada
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 13;

		FOR rec IN 

			SELECT 
				 linea
				,13                 													as "num_validador"
				,v_descripcion															as "descripcion"	
				,'deuda_acelerada'														as "campo"
				,deuda_acelerada														as "dato_reportado"
				,proceso.val_en_dominio(deuda_acelerada, ARRAY['1','2'])				as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			17: Si se informa tipo deudor 1, el sujeto esta 100% moroso y el monto actual = suma( tramos de mora de 1 a 9) entonces carga financiera tiene que estar en cero.
			campo: Carga financiera
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 17;

		FOR rec IN 

			SELECT 
				 linea
				,17                 													as "num_validador"
				,v_descripcion															as "descripcion"	
				,'carga_financiera'														as "campo"
				,carga_financiera														as "dato_reportado"
				,'NOOK'																	as "status"
		    FROM validador.rdc01_detalle 
			where tipo_deudor = '1' and 
			(monto_mora_1_tramo::numeric + 
			 monto_mora_2_tramo::numeric + 
			 monto_mora_3_tramo::numeric + 
			 monto_mora_4_tramo::numeric + 
			 monto_mora_5_tramo::numeric + 
			 monto_mora_6_tramo::numeric + 
			 monto_mora_7_tramo::numeric + 
			 monto_mora_8_tramo::numeric + 
			 monto_mora_9_tramo::numeric) > 0
			and 
			   monto_actual::numeric = (
			   							monto_mora_1_tramo::numeric + 
			                            monto_mora_2_tramo::numeric + 
										monto_mora_3_tramo::numeric + 
										monto_mora_4_tramo::numeric + 
										monto_mora_5_tramo::numeric + 
										monto_mora_6_tramo::numeric + 
										monto_mora_7_tramo::numeric + 
										monto_mora_8_tramo::numeric + 
										monto_mora_9_tramo::numeric)
			and carga_financiera::numeric <> 0			

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			18: Si se informa dato en el campo mora_actual entonces la suma de los campos de mora del 1 al 9 tiene que ser mayor a cero.
			campo: Mora actual
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 18;

		FOR rec IN 

			SELECT 
				 linea
				,18                 													as "num_validador"
				,v_descripcion															as "descripcion"	
				,'mora_actual'															as "campo"
				,mora_actual															as "dato_reportado"
				,'NOOK'																	as "status"
		    FROM validador.rdc01_detalle 
			where 
			mora_actual::numeric <> 0 and
			(monto_mora_1_tramo::numeric + 
			 monto_mora_2_tramo::numeric + 
			 monto_mora_3_tramo::numeric + 
			 monto_mora_4_tramo::numeric + 
			 monto_mora_5_tramo::numeric + 
			 monto_mora_6_tramo::numeric + 
			 monto_mora_7_tramo::numeric + 
			 monto_mora_8_tramo::numeric + 
			 monto_mora_9_tramo::numeric) = 0


		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			19: Si la suma de los campos de mora 1 al 9 es mayor a cero, entonces el campo mora actual debe ser mayor a cero.
			campo: Mora actual
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 19;

		FOR rec IN 

			SELECT 
				 linea
				,19                 													as "num_validador"
				,v_descripcion															as "descripcion"	
				,'mora_actual'															as "campo"
				,mora_actual															as "dato_reportado"
				,'NOOK'																	as "status"
		    FROM validador.rdc01_detalle 
			where 
			mora_actual::numeric = 0 and
			(monto_mora_1_tramo::numeric + 
			 monto_mora_2_tramo::numeric + 
			 monto_mora_3_tramo::numeric + 
			 monto_mora_4_tramo::numeric + 
			 monto_mora_5_tramo::numeric + 
			 monto_mora_6_tramo::numeric + 
			 monto_mora_7_tramo::numeric + 
			 monto_mora_8_tramo::numeric + 
			 monto_mora_9_tramo::numeric) > 0


		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			20: Si el campo deuda acelerada es igual a 1, entonces campo monto al dia tiene que ser igual a cero y la suma de los campos en mora del 1 al 9 debe ser mayor a cero.
			campo: Deuda acelerada
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 20;

		FOR rec IN 

			SELECT 
				 linea
				,20                 													as "num_validador"
				,v_descripcion															as "descripcion"	
				,'deuda_acelerada'														as "campo"
				,deuda_acelerada														as "dato_reportado"
				,'NOOK'																	as "status"
		    FROM validador.rdc01_detalle 
			where 
			deuda_acelerada = '1' and
			not (
				monto_al_dia::numeric = 0 and
					(monto_mora_1_tramo::numeric + 
					 monto_mora_2_tramo::numeric + 
					 monto_mora_3_tramo::numeric + 
					 monto_mora_4_tramo::numeric + 
					 monto_mora_5_tramo::numeric + 
					 monto_mora_6_tramo::numeric + 
					 monto_mora_7_tramo::numeric + 
					 monto_mora_8_tramo::numeric + 
					 monto_mora_9_tramo::numeric) > 0
			)


		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			21: Si el campo deuda acelerada es igual a 1, entonces el campo mora actual debe ser mayor a cero.
			campo: Deuda acelerada
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 21;

		FOR rec IN 

			SELECT 
				 linea
				,21                 													as "num_validador"
				,v_descripcion															as "descripcion"	
				,'deuda_acelerada'														as "campo"
				,deuda_acelerada														as "dato_reportado"
				,'NOOK'																	as "status"
		    FROM validador.rdc01_detalle 
			where 
			deuda_acelerada = '1' and mora_actual::numeric = 0
			
		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			22: Si el campo deuda acelerada es igual a 1, entonces el campo de carga financiera debe ser igual a cero
			campo: Deuda acelerada
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 22;

		FOR rec IN 

			SELECT 
				 linea
				,22                 													as "num_validador"
				,v_descripcion															as "descripcion"	
				,'deuda_acelerada'														as "campo"
				,deuda_acelerada														as "dato_reportado"
				,'NOOK'																	as "status"
		    FROM validador.rdc01_detalle 
			where 
			deuda_acelerada = '1' and
			carga_financiera::numeric <> 0
			
		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			23: Para tipo de deudor 1, campo operacion + tipo de obligacion, deben ser unicos
			campo: codigo_operacion + tipo_obligacion
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 23;

		FOR rec IN 

			SELECT 
				 linea
				,23                 																		as "num_validador"
				,v_descripcion																				as "descripcion"	
				,'codigo_operacion + tipo_obligacion'														as "campo"
				,'codigo_operacion: ' || codigo_operacion || ' tipo_obligacion: ' || tipo_obligacion		as "dato_reportado"
				,'NOOK'																						as "status"
		    FROM validador.rdc01_detalle 
			where 
			tipo_deudor = '1' and
			(codigo_operacion, tipo_obligacion) in (
				select 
					codigo_operacion, tipo_obligacion	
					from validador.rdc01_detalle where tipo_deudor = '1'
					group by codigo_operacion, tipo_obligacion
					having count(*) > 1
			)
			
		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
			24: Para tipo de deudor 2, campo operacion + campo rut + tipo de obligacion, deben ser unicos
			campo: codigo_operacion + rut + tipo_obligacion
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 24;

		FOR rec IN 

			SELECT 
				 linea
				,24                 																		as "num_validador"
				,v_descripcion																				as "descripcion"	
				,'codigo_operacion + rut + tipo_obligacion'													as "campo"
				,'codigo_operacion: ' || codigo_operacion || ' rut: ' || rut  || ' tipo_obligacion: ' || tipo_obligacion		as "dato_reportado"
				,'NOOK'																						as "status"
		    FROM validador.rdc01_detalle 
			where 
			tipo_deudor = '2' and
			(rut, codigo_operacion, tipo_obligacion) in (
				select 
					rut, codigo_operacion, tipo_obligacion	
					from validador.rdc01_detalle where tipo_deudor = '2'
					group by rut, codigo_operacion, tipo_obligacion
					having count(*) > 1
			)
			
		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, descripcion, campo, dato_reportado, status)
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
		        'proceso.val_reporte_rdc01',
		        SQLERRM
		    );
		
		    RAISE EXCEPTION 'Error en validación RDC01: %', SQLERRM;
END;
$$