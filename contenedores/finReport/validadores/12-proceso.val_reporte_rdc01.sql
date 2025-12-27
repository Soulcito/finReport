CREATE OR REPLACE PROCEDURE proceso.val_reporte_rdc01()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
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
			,substring(registro, 237, 15) 					as "monto_mora_4_tramo"
			,substring(registro, 252, 15) 					as "monto_mora_5_tramo"
			,substring(registro, 267, 15) 					as "monto_mora_6_tramo"
			,substring(registro, 282, 15) 					as "monto_mora_7_tramo"
			,substring(registro, 297, 15) 					as "monto_mora_8_tramo"
			,substring(registro, 312, 15) 					as "monto_mora_9_tramo"
			,substring(registro, 327, 15) 					as "mora_actual"
			,substring(registro, 342, 15) 					as "deuda_renegociada"
			,substring(registro, 357, 15) 					as "deuda_acelerada"
		from validador.rdc01_texto where linea > 1;


		/*
			1: Codigo de la institucion no corresponde
		*/

		insert into validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
		SELECT 
			 linea
			,1        											as "num_validador"
			,'header'											as "campo"	
			,substring(registro,1,10)							as "dato_reportado"
			,proceso.val_num_1(substring(registro,1,10))	    as "status"
		FROM validador.rdc01_texto where linea = 1;


		/*
			2: Identificacion del archivo no corresponde
		*/
		

		insert into validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
		SELECT 
			 linea
			,2        											as "num_validador"
			,'header'											as "campo"
			,substring(registro,11,5)							as "dato_reportado"
			,proceso.val_num_2('RDC01', 11, 5, registro)		as "status"
		FROM validador.rdc01_texto where linea = 1;


		/*
			3: Largo del registro no corresponde
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,3                  					as "num_validador"
				,'registro'								as "campo"
				,registro								as "dato_reportado"
				,proceso.val_num_3(registro, 322)		as "status"
		    FROM validador.rdc01_texto 
		
		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		
		

		/*
			4: RUT informado es invalido
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,4                  					as "num_validador"
				,'rut'									as "campo"
				,rut									as "dato_reportado"
				,proceso.val_num_4(rut)					as "status"
		    FROM validador.rdc01_detalle
		
		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		


		/*
			5: Tipo de persona informado no corresponde
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,5                  											as "num_validador"
				,'tipo_persona'													as "campo"	
				,tipo_persona													as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_persona, 'interno.tipo_persona') as "status"
		    FROM validador.rdc01_detalle
		
		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		


		/*
			6: Operacion Titulo III reportado no corresponde
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,6                  													as "num_validador"
				,'operacion_titulo'														as "campo"
				,operacion_titulo														as "dato_reportado"
				,proceso.val_codigo_tabla(operacion_titulo, 'interno.operacion_titulo') as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;				


		/*
			7: Tipo deudor reportado no corresponde
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,7                  													as "num_validador"
				,'tipo_deudor'															as "campo"	
				,tipo_deudor															as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_deudor, 'interno.tipo_deudor') 			as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;						
		

		/*
			8: Tipo de obligacion reportado no corresponde a tabla 126
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,8                  													as "num_validador"
				,'tipo_obligacion'														as "campo"
				,tipo_obligacion														as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_obligacion, 'interno.tabla_banco_126') 	as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;				


		/*
			9: Fecha reportada no corresponde al formato YYYYMMDD
			campo: fecha_otorgamiento
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,9                  													as "num_validador"
				,'fecha_otorgamiento'													as "campo"
				,fecha_otorgamiento														as "dato_reportado"
				,proceso.val_num_9(fecha_otorgamiento)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;						


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: carga_financiera
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'carga_financiera'														as "campo"
				,carga_financiera														as "dato_reportado"
				,proceso.val_num_10(carga_financiera)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;				


		/*
			9: Fecha reportada no corresponde al formato YYYYMMDD
			campo: fecha_extincion
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,9                  													as "num_validador"
				,'fecha_extincion'														as "campo"
				,fecha_extincion														as "dato_reportado"
				,proceso.val_num_9(fecha_extincion)										as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;			


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: valor_gtia_inmobiliaria
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'valor_gtia_inmobiliaria'												as "campo"
				,valor_gtia_inmobiliaria												as "dato_reportado"
				,proceso.val_num_10(valor_gtia_inmobiliaria)							as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;						



		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: valor_gtia_mobiliaria
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'valor_gtia_mobiliaria'												as "campo"
				,valor_gtia_mobiliaria													as "dato_reportado"
				,proceso.val_num_10(valor_gtia_mobiliaria)								as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: valor_gtia_financiera
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'valor_gtia_financiera'												as "campo"
				,valor_gtia_financiera													as "dato_reportado"
				,proceso.val_num_10(valor_gtia_financiera)								as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: valor_gtia_personal
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'valor_gtia_personal'													as "campo"
				,valor_gtia_personal													as "dato_reportado"
				,proceso.val_num_10(valor_gtia_personal)								as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;				
		

		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: monto_original
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'monto_original'														as "campo"
				,monto_original															as "dato_reportado"
				,proceso.val_num_10(monto_original)										as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: monto_actual
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'monto_actual'															as "campo"
				,monto_actual															as "dato_reportado"
				,proceso.val_num_10(monto_actual)										as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: monto_al_dia
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'monto_al_dia'															as "campo"
				,monto_al_dia															as "dato_reportado"
				,proceso.val_num_10(monto_al_dia)										as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: monto_mora_1_tramo
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'monto_mora_1_tramo'													as "campo"
				,monto_mora_1_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_1_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: monto_mora_2_tramo
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'monto_mora_2_tramo'													as "campo"
				,monto_mora_2_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_2_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: monto_mora_3_tramo
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'monto_mora_3_tramo'													as "campo"
				,monto_mora_3_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_3_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: monto_mora_4_tramo
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'monto_mora_4_tramo'													as "campo"
				,monto_mora_4_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_4_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: monto_mora_5_tramo
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'monto_mora_5_tramo'													as "campo"
				,monto_mora_5_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_5_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: monto_mora_6_tramo
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'monto_mora_6_tramo'													as "campo"
				,monto_mora_6_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_6_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: monto_mora_7_tramo
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'monto_mora_7_tramo'													as "campo"
				,monto_mora_7_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_7_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;				


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: monto_mora_8_tramo
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'monto_mora_8_tramo'													as "campo"
				,monto_mora_8_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_8_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;



		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: monto_mora_9_tramo
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'monto_mora_9_tramo'													as "campo"
				,monto_mora_9_tramo														as "dato_reportado"
				,proceso.val_num_10(monto_mora_9_tramo)									as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			campo: mora_actual
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                 													as "num_validador"
				,'mora_actual'															as "campo"
				,mora_actual															as "dato_reportado"
				,proceso.val_num_10(mora_actual)										as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;



		/*
			12: Deuda renegociada reportada no corresponde
			campo: deuda_renegociada
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,12                 													as "num_validador"
				,'deuda_renegociada'													as "campo"
				,deuda_renegociada														as "dato_reportado"
				,proceso.val_en_dominio(deuda_renegociada, ARRAY['1','2'])				as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		


		/*
			13: Deuda acelerada reportada no corresponde
			campo: deuda_acelerada
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,13                 													as "num_validador"
				,'deuda_acelerada'														as "campo"
				,deuda_acelerada														as "dato_reportado"
				,proceso.val_en_dominio(deuda_acelerada, ARRAY['1','2'])				as "status"
		    FROM validador.rdc01_detalle

		LOOP

			INSERT INTO validador.rdc01_resultado(linea, num_validador, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
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