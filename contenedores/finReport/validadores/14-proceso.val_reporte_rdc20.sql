CREATE OR REPLACE PROCEDURE proceso.val_reporte_rdc20()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
BEGIN

		/**************************************************/
		/***	GENERA validador.rdc20_detalle 1 al 4	***/
		/**************************************************/

		truncate table validador.rdc20_detalle_1;
		truncate table validador.rdc20_detalle_2;
		truncate table validador.rdc20_detalle_3;
		truncate table validador.rdc20_detalle_4;

		insert into validador.rdc20_detalle_1 (linea, tipo_registro, tipo_obligacion, tipo_flujo, monto, filler)
		select
			 linea
			,substring(registro,   1,  2) 					as "tipo_registro"
			,substring(registro,   3,  2) 					as "tipo_obligacion"
			,substring(registro,   5,  2) 					as "tipo_flujo"
			,substring(registro,   7, 21) 					as "monto"
			,substring(registro,  28, 55) 					as "filler"
		from validador.rdc20_texto where linea > 1 and substring(registro, 1, 2) = '01';


		insert into validador.rdc20_detalle_2 (linea, tipo_registro, rut_deudor, codigo_operacion, fecha_informacion, tipo_obligacion, ident_tribunal, monto, filler)
		select
			 linea
			,substring(registro,   1,  2) 					as "tipo_registro"
			,substring(registro,   3, 10) 					as "rut_deudor"
			,substring(registro,  13, 30) 					as "codigo_operacion"
			,substring(registro,  43,  8) 					as "fecha_informacion"
			,substring(registro,  51,  2) 					as "tipo_obligacion"
			,substring(registro,  53,  7) 					as "ident_tribunal"
			,substring(registro,  60, 20) 					as "monto"
			,substring(registro,  80, 3) 					as "filler"
		from validador.rdc20_texto where linea > 1 and substring(registro, 1, 2) = '02';


		insert into validador.rdc20_detalle_3 (linea, tipo_registro, rut_comprador, rut_deudor, codigo_operacion, fecha_informacion, tipo_obligacion, monto)
		select
			 linea
			,substring(registro,   1,  2) 					as "tipo_registro"
			,substring(registro,   3, 10) 					as "rut_comprador"
			,substring(registro,  13, 10) 					as "rut_deudor"
			,substring(registro,  23, 30) 					as "codigo_operacion"
			,substring(registro,  53,  8) 					as "fecha_informacion"
			,substring(registro,  61,  2) 					as "tipo_obligacion"
			,substring(registro,  63, 20) 					as "monto"
		from validador.rdc20_texto where linea > 1 and substring(registro, 1, 2) = '03';		


		insert into validador.rdc20_detalle_4 (linea, tipo_registro, rut_vendedor, rut_deudor, codigo_operacion, fecha_informacion, tipo_obligacion, monto)
		select
			 linea
			,substring(registro,   1,  2) 					as "tipo_registro"
			,substring(registro,   3, 10) 					as "rut_vendedor"
			,substring(registro,  13, 10) 					as "rut_deudor"
			,substring(registro,  23, 30) 					as "codigo_operacion"
			,substring(registro,  53,  8) 					as "fecha_informacion"
			,substring(registro,  61,  2) 					as "tipo_obligacion"
			,substring(registro,  63, 20) 					as "monto"
		from validador.rdc20_texto where linea > 1 and substring(registro, 1, 2) = '04';


		/*
			1: Codigo de la institucion no corresponde
		*/

		insert into validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
		SELECT 
			 linea
			,1        											as "num_validador"
			,''													as "tipo_registro"
			,'header-cod_institucion'							as "campo"	
			,substring(registro,1,10)							as "dato_reportado"
			,proceso.val_num_1(substring(registro,1,10))	    as "status"
		FROM validador.rdc20_texto where linea = 1;


		/*
			2: Identificacion del archivo no corresponde
		*/
		

		insert into validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
		SELECT 
			 linea
			,2        											as "num_validador"
			,''													as "tipo_registro"
			,'header-ident_archivo'								as "campo"
			,substring(registro,11,5)							as "dato_reportado"
			,proceso.val_num_2('RDC20', 11, 5, registro)		as "status"
		FROM validador.rdc20_texto where linea = 1;


		/*
			9: Fecha reportada no corresponde al formato YYYYMMDD
		*/
		

		insert into validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
		SELECT 
			 linea
			,9        											as "num_validador"
			,''													as "tipo_registro"
			,'header-fecha_archivo'											as "campo"
			,substring(registro,16,8)							as "dato_reportado"
			,proceso.val_num_9(substring(registro,16,8))		as "status"
		FROM validador.rdc20_texto where linea = 1;		


		/*
			16: Filler debe ser completado con espacios y tener un largo especifico
		*/
		

		insert into validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
		SELECT 
			 linea
			,16        												as "num_validador"
			,''														as "tipo_registro"
			,'header-filler'										as "campo"
			,substring(registro, 24, 59)							as "dato_reportado"
			,proceso.val_num_16(substring(registro, 24, 59), 59)	as "status"
		FROM validador.rdc20_texto where linea = 1;		


		/*
			3: Largo del registro no corresponde
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,3                  					as "num_validador"
				,''										as "tipo_registro"	
				,'registro'								as "campo"
				,registro								as "dato_reportado"
				,proceso.val_num_3(registro, 82)		as "status"
		    FROM validador.rdc20_texto 
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		


		/*
			14: Tipo de registro no corresponde
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,14                 																as "num_validador"
				,''																					as "tipo_registro"	
				,'tipo_registro'																	as "campo"
				,substring(registro, 1, 2)															as "dato_reportado"
				,proceso.val_en_dominio(substring(registro, 1, 2), ARRAY['01','02','03','04'])		as "status"
		    FROM validador.rdc20_texto where linea > 1
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;				
		

		/*
			8: Tipo de obligacion reportado no corresponde a tabla 126
			Campo: tipo_obligacion
			Tipo_registro: 1			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,8                 																	as "num_validador"
				,'01'																				as "tipo_registro"	
				,'tipo_obligacion'																	as "campo"
				,tipo_obligacion																	as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_obligacion, 'interno.tabla_banco_126')				as "status"
		    FROM validador.rdc20_detalle_1

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			15: Tipo de flujo informado no corresponde
			Campo: tipo_flujo
			Tipo_registro: 1			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,15                																	as "num_validador"
				,'01'																				as "tipo_registro"	
				,'tipo_flujo'																		as "campo"
				,tipo_flujo																			as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_flujo, 'interno.tipo_flujo')							as "status"
		    FROM validador.rdc20_detalle_1

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			Campo: monto
			Tipo_registro: 1			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                																	as "num_validador"
				,'01'																				as "tipo_registro"	
				,'monto'																			as "campo"
				,monto																				as "dato_reportado"
				,proceso.val_num_10(monto)															as "status"
		    FROM validador.rdc20_detalle_1

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		


		/*
			16: Filler debe ser completado con espacios
			Campo: filler
			Tipo_registro: 1			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,16                 																as "num_validador"
				,'01'																				as "tipo_registro"	
				,'filler'																			as "campo"
				,filler																				as "dato_reportado"
				,proceso.val_num_16(filler, 55)														as "status"
		    FROM validador.rdc20_detalle_1
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			4: RUT informado es invalido
			Campo: rut_deudor
			Tipo_registro: 2			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,4                 																		as "num_validador"
				,'02'																					as "tipo_registro"	
				,'rut_deudor'																			as "campo"
				,rut_deudor																				as "dato_reportado"
				,proceso.val_num_4(rut_deudor)															as "status"
		    FROM validador.rdc20_detalle_2
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			9: Fecha reportada no corresponde al formato YYYYMMDD
			Campo: fecha_informacion
			Tipo_registro: 2			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,9                 																		as "num_validador"
				,'02'																					as "tipo_registro"	
				,'fecha_informacion'																	as "campo"
				,fecha_informacion																		as "dato_reportado"
				,proceso.val_num_9(fecha_informacion)													as "status"
		    FROM validador.rdc20_detalle_2
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;
		

		/*
			8: Tipo de obligacion reportado no corresponde a tabla 126
			Campo: tipo_obligacion
			Tipo_registro: 2			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,8                 																		as "num_validador"
				,'02'																					as "tipo_registro"	
				,'tipo_obligacion'																		as "campo"
				,tipo_obligacion																		as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_obligacion, 'interno.tabla_banco_126')					as "status"
		    FROM validador.rdc20_detalle_2

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			Campo: ident_tribunal
			Tipo_registro: 2			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                																		as "num_validador"
				,'02'																					as "tipo_registro"	
				,'ident_tribunal'																		as "campo"
				,ident_tribunal																			as "dato_reportado"
				,proceso.val_num_10(ident_tribunal)														as "status"
		    FROM validador.rdc20_detalle_2

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			Campo: monto
			Tipo_registro: 2			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10                																		as "num_validador"
				,'02'																					as "tipo_registro"	
				,'monto'																				as "campo"
				,monto																					as "dato_reportado"
				,proceso.val_num_10(monto)																as "status"
		    FROM validador.rdc20_detalle_2

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;				


		/*
			16: Filler debe ser completado con espacios
			Campo: filler
			Tipo_registro: 2			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,16                 																as "num_validador"
				,'02'																				as "tipo_registro"	
				,'filler'																			as "campo"
				,filler																				as "dato_reportado"
				,proceso.val_num_16(filler, 3)														as "status"
		    FROM validador.rdc20_detalle_2
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			4: RUT informado es invalido
			Campo: rut_comprador
			Tipo_registro: 3			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,4 	                																as "num_validador"
				,'03'																				as "tipo_registro"	
				,'rut_comprador'																	as "campo"
				,rut_comprador																		as "dato_reportado"
				,proceso.val_num_4(rut_comprador)													as "status"
		    FROM validador.rdc20_detalle_3
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			4: RUT informado es invalido
			Campo: rut_deudor
			Tipo_registro: 3			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,4 	                																as "num_validador"
				,'03'																				as "tipo_registro"	
				,'rut_deudor'																		as "campo"
				,rut_deudor																			as "dato_reportado"
				,proceso.val_num_4(rut_deudor)														as "status"
		    FROM validador.rdc20_detalle_3
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			9: Fecha reportada no corresponde al formato YYYYMMDD
			Campo: fecha_informacion
			Tipo_registro: 3			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,9 	                																as "num_validador"
				,'03'																				as "tipo_registro"	
				,'fecha_informacion'																as "campo"
				,fecha_informacion																	as "dato_reportado"
				,proceso.val_num_9(fecha_informacion)												as "status"
		    FROM validador.rdc20_detalle_3
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			8: Tipo de obligacion reportado no corresponde a tabla 126
			Campo: tipo_obligacion
			Tipo_registro: 3			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,8 	                																as "num_validador"
				,'03'																				as "tipo_registro"	
				,'tipo_obligacion'																	as "campo"
				,tipo_obligacion																	as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_obligacion, 'interno.tabla_banco_126')				as "status"
		    FROM validador.rdc20_detalle_3

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			Campo: monto
			Tipo_registro: 3			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,10	                																as "num_validador"
				,'03'																				as "tipo_registro"	
				,'monto'																			as "campo"
				,monto																				as "dato_reportado"
				,proceso.val_num_10(monto)															as "status"
		    FROM validador.rdc20_detalle_3

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			4: RUT informado es invalido
			Campo: rut_vendedor
			Tipo_registro: 4			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,4	                																as "num_validador"
				,'04'																				as "tipo_registro"	
				,'rut_vendedor'																		as "campo"
				,rut_vendedor																		as "dato_reportado"
				,proceso.val_num_4(rut_vendedor)													as "status"
		    FROM validador.rdc20_detalle_4

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			4: RUT informado es invalido
			Campo: rut_deudor
			Tipo_registro: 4			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,4	                																as "num_validador"
				,'04'																				as "tipo_registro"	
				,'rut_deudor'																		as "campo"
				,rut_deudor																			as "dato_reportado"
				,proceso.val_num_4(rut_deudor)														as "status"
		    FROM validador.rdc20_detalle_4

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			9: Fecha reportada no corresponde al formato YYYYMMDD
			Campo: fecha_informacion
			Tipo_registro: 4			
		*/
		

		FOR rec IN 

			SELECT 
				 linea
				,9	                																as "num_validador"
				,'04'																				as "tipo_registro"	
				,'fecha_informacion'																as "campo"
				,fecha_informacion																	as "dato_reportado"
				,proceso.val_num_9(fecha_informacion)												as "status"
		    FROM validador.rdc20_detalle_4

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		

		/*
			8: Tipo de obligacion reportado no corresponde a tabla 126
			Campo: tipo_obligacion
			Tipo_registro: 4
		*/		

		FOR rec IN 

			SELECT 
				 linea
				,8	                																as "num_validador"
				,'04'																				as "tipo_registro"	
				,'tipo_obligacion'																	as "campo"
				,tipo_obligacion																	as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_obligacion, 'interno.tabla_banco_126')				as "status"
		    FROM validador.rdc20_detalle_4

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			10: Campo reportado debe ser numerico y rellenado con 0 a la izquierda
			Campo: monto
			Tipo_registro: 4
		*/		

		FOR rec IN 

			SELECT 
				 linea
				,10	                																as "num_validador"
				,'04'																				as "tipo_registro"	
				,'monto'																			as "campo"
				,monto																				as "dato_reportado"
				,proceso.val_num_10(monto)															as "status"
		    FROM validador.rdc20_detalle_4

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.tipo_registro
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
		        'proceso.val_reporte_rdc20',
		        SQLERRM
		    );
		
		    RAISE EXCEPTION 'Error en validación RDC20: %', SQLERRM;
END;
$$