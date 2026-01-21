CREATE OR REPLACE PROCEDURE proceso.val_reporte_rdc20()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
	v_descripcion varchar(2000);
	v_valor_1 int;
	v_valor_2 int;
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

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 1;

		insert into validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
		SELECT 
			 linea
			,1        											as "num_validador"
			,v_descripcion										as "descripcion"
			,''													as "tipo_registro"
			,'header-cod_institucion'							as "campo"	
			,substring(registro,1,10)							as "dato_reportado"
			,proceso.val_num_1(substring(registro,1,10))	    as "status"
		FROM validador.rdc20_texto where linea = 1;


		/*
			2: Identificacion del archivo no corresponde
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 2;

		insert into validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
		SELECT 
			 linea
			,2        											as "num_validador"
			,v_descripcion										as "descripcion"
			,''													as "tipo_registro"
			,'header-ident_archivo'								as "campo"
			,substring(registro,11,5)							as "dato_reportado"
			,proceso.val_num_2('RDC20', 11, 5, registro)		as "status"
		FROM validador.rdc20_texto where linea = 1;


		/*
			9: Fecha reportada no corresponde al formato YYYYMMDD
		*/

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 9;		

		insert into validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
		SELECT 
			 linea
			,9        											as "num_validador"
			,v_descripcion										as "descripcion"
			,''													as "tipo_registro"
			,'header-fecha_archivo'											as "campo"
			,substring(registro,16,8)							as "dato_reportado"
			,proceso.val_num_9(substring(registro,16,8))		as "status"
		FROM validador.rdc20_texto where linea = 1;		


		/*
			16: Filler debe ser completado con espacios y tener un largo especifico
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 16;

		insert into validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
		SELECT 
			 linea
			,16        												as "num_validador"
			,v_descripcion											as "descripcion"
			,''														as "tipo_registro"
			,'header-filler'										as "campo"
			,substring(registro, 24, 59)							as "dato_reportado"
			,proceso.val_num_16(substring(registro, 24, 59), 59)	as "status"
		FROM validador.rdc20_texto where linea = 1;		


		/*
			3: Largo del registro no corresponde
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 3;

		FOR rec IN 

			SELECT 
				 linea
				,3                  					as "num_validador"
				,v_descripcion							as "descripcion"
				,''										as "tipo_registro"	
				,'registro'								as "campo"
				,registro								as "dato_reportado"
				,proceso.val_num_3(registro, 82)		as "status"
		    FROM validador.rdc20_texto 
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		


		/*
			14: Tipo de registro no corresponde
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 14;

		FOR rec IN 

			SELECT 
				 linea
				,14                 																as "num_validador"
				,v_descripcion																		as "descripcion"
				,''																					as "tipo_registro"	
				,'tipo_registro'																	as "campo"
				,substring(registro, 1, 2)															as "dato_reportado"
				,proceso.val_en_dominio(substring(registro, 1, 2), ARRAY['01','02','03','04'])		as "status"
		    FROM validador.rdc20_texto where linea > 1
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 8;		

		FOR rec IN 

			SELECT 
				 linea
				,8                 																	as "num_validador"
				,v_descripcion																		as "descripcion"
				,'01'																				as "tipo_registro"	
				,'tipo_obligacion'																	as "campo"
				,tipo_obligacion																	as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_obligacion, 'interno.tabla_banco_126')				as "status"
		    FROM validador.rdc20_detalle_1

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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
		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 15;

		FOR rec IN 

			SELECT 
				 linea
				,15                																	as "num_validador"
				,v_descripcion																		as "descripcion"
				,'01'																				as "tipo_registro"	
				,'tipo_flujo'																		as "campo"
				,tipo_flujo																			as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_flujo, 'interno.tipo_flujo')							as "status"
		    FROM validador.rdc20_detalle_1

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			11: Campo con signo no corresponde, signo debe ir al final
			Campo: monto
			Tipo_registro: 1			
		*/
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 11;

		FOR rec IN 

			SELECT 
				 linea
				,11                																	as "num_validador"
				,v_descripcion																		as "descripcion"
				,'01'																				as "tipo_registro"	
				,'monto'																			as "campo"
				,monto																				as "dato_reportado"
				,proceso.val_num_11(monto)															as "status"
		    FROM validador.rdc20_detalle_1

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 16;

		FOR rec IN 

			SELECT 
				 linea
				,16                 																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'01'																				as "tipo_registro"	
				,'filler'																			as "campo"
				,filler																				as "dato_reportado"
				,proceso.val_num_16(filler, 55)														as "status"
		    FROM validador.rdc20_detalle_1
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 4;		

		FOR rec IN 

			SELECT 
				 linea
				,4                 																		as "num_validador"
				,v_descripcion																			as "descripcion"
				,'02'																					as "tipo_registro"	
				,'rut_deudor'																			as "campo"
				,rut_deudor																				as "dato_reportado"
				,proceso.val_num_4(rut_deudor)															as "status"
		    FROM validador.rdc20_detalle_2
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 9;		

		FOR rec IN 

			SELECT 
				 linea
				,9                 																		as "num_validador"
				,v_descripcion																			as "descripcion"
				,'02'																					as "tipo_registro"	
				,'fecha_informacion'																	as "campo"
				,fecha_informacion																		as "dato_reportado"
				,proceso.val_num_9(fecha_informacion)													as "status"
		    FROM validador.rdc20_detalle_2
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 8;		

		FOR rec IN 

			SELECT 
				 linea
				,8                 																		as "num_validador"
				,v_descripcion																			as "descripcion"
				,'02'																					as "tipo_registro"	
				,'tipo_obligacion'																		as "campo"
				,tipo_obligacion																		as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_obligacion, 'interno.tabla_banco_126')					as "status"
		    FROM validador.rdc20_detalle_2

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                																		as "num_validador"
				,v_descripcion																			as "descripcion"
				,'02'																					as "tipo_registro"	
				,'ident_tribunal'																		as "campo"
				,ident_tribunal																			as "dato_reportado"
				,proceso.val_num_10(ident_tribunal)														as "status"
		    FROM validador.rdc20_detalle_2

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10                																		as "num_validador"
				,v_descripcion																			as "descripcion"
				,'02'																					as "tipo_registro"	
				,'monto'																				as "campo"
				,monto																					as "dato_reportado"
				,proceso.val_num_10(monto)																as "status"
		    FROM validador.rdc20_detalle_2

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 16;

		FOR rec IN 

			SELECT 
				 linea
				,16                 																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'02'																				as "tipo_registro"	
				,'filler'																			as "campo"
				,filler																				as "dato_reportado"
				,proceso.val_num_16(filler, 3)														as "status"
		    FROM validador.rdc20_detalle_2
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 4;

		FOR rec IN 

			SELECT 
				 linea
				,4 	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'03'																				as "tipo_registro"	
				,'rut_comprador'																	as "campo"
				,rut_comprador																		as "dato_reportado"
				,proceso.val_num_4(rut_comprador)													as "status"
		    FROM validador.rdc20_detalle_3
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 4;

		FOR rec IN 

			SELECT 
				 linea
				,4 	                																as "num_validador"
				,v_descripcion																		as "descripcion"	
				,'03'																				as "tipo_registro"	
				,'rut_deudor'																		as "campo"
				,rut_deudor																			as "dato_reportado"
				,proceso.val_num_4(rut_deudor)														as "status"
		    FROM validador.rdc20_detalle_3
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 9;	

		FOR rec IN 

			SELECT 
				 linea
				,9 	                																as "num_validador"
				,v_descripcion																		as "descripcion"	
				,'03'																				as "tipo_registro"	
				,'fecha_informacion'																as "campo"
				,fecha_informacion																	as "dato_reportado"
				,proceso.val_num_9(fecha_informacion)												as "status"
		    FROM validador.rdc20_detalle_3
		
		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 8;		

		FOR rec IN 

			SELECT 
				 linea
				,8 	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'03'																				as "tipo_registro"	
				,'tipo_obligacion'																	as "campo"
				,tipo_obligacion																	as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_obligacion, 'interno.tabla_banco_126')				as "status"
		    FROM validador.rdc20_detalle_3

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'03'																				as "tipo_registro"	
				,'monto'																			as "campo"
				,monto																				as "dato_reportado"
				,proceso.val_num_10(monto)															as "status"
		    FROM validador.rdc20_detalle_3

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 4;

		FOR rec IN 

			SELECT 
				 linea
				,4	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'04'																				as "tipo_registro"	
				,'rut_vendedor'																		as "campo"
				,rut_vendedor																		as "dato_reportado"
				,proceso.val_num_4(rut_vendedor)													as "status"
		    FROM validador.rdc20_detalle_4

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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
		
		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 4;

		FOR rec IN 

			SELECT 
				 linea
				,4	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'04'																				as "tipo_registro"	
				,'rut_deudor'																		as "campo"
				,rut_deudor																			as "dato_reportado"
				,proceso.val_num_4(rut_deudor)														as "status"
		    FROM validador.rdc20_detalle_4

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 9;		

		FOR rec IN 

			SELECT 
				 linea
				,9	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'04'																				as "tipo_registro"	
				,'fecha_informacion'																as "campo"
				,fecha_informacion																	as "dato_reportado"
				,proceso.val_num_9(fecha_informacion)												as "status"
		    FROM validador.rdc20_detalle_4

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 8;

		FOR rec IN 

			SELECT 
				 linea
				,8	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'04'																				as "tipo_registro"	
				,'tipo_obligacion'																	as "campo"
				,tipo_obligacion																	as "dato_reportado"
				,proceso.val_codigo_tabla(tipo_obligacion, 'interno.tabla_banco_126')				as "status"
		    FROM validador.rdc20_detalle_4

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
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

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 10;

		FOR rec IN 

			SELECT 
				 linea
				,10	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'04'																				as "tipo_registro"	
				,'monto'																			as "campo"
				,monto																				as "dato_reportado"
				,proceso.val_num_10(monto)															as "status"
		    FROM validador.rdc20_detalle_4

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		


		/*
			25: Tipo de obligacion reportado igual a (07, 08, 41, 42, 43, 44) y tipo de flujo es distinto a 03
			Campo: Tipo de obligacion
			Tipo_registro: 1
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 25;

		FOR rec IN 

			SELECT 
				 linea
				,25	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'01'																				as "tipo_registro"	
				,'tipo_obligacion'																	as "campo"
				,'Tipo obligacion: ' || tipo_obligacion	|| ', Tipo flujo: ' || tipo_flujo			as "dato_reportado"
				,'NOOK'																				as "status"
		    FROM validador.rdc20_detalle_1
				 WHERE tipo_obligacion in ('07','08','41','42','43','44') and tipo_flujo <> '03'

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;				


		/*
			26: Tipo de flujo informado Amortizacion de capital (01) con signo distinto de negativo(-)
			Campo: Tipo de flujo
			Tipo_registro: 1
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 26;

		FOR rec IN 

			SELECT 
				 linea
				,26	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'01'																				as "tipo_registro"	
				,'tipo_flujo'																		as "campo"
				,monto																				as "dato_reportado"
				,'NOOK'																				as "status"
		    FROM validador.rdc20_detalle_1
				 WHERE tipo_flujo = '01' and substring(monto,21,1) <> '-'

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;						


		/*
			27: Tipo de flujo informado Interes capitalizado (02) con signo distinto de positivo (+)
			Campo: Tipo de flujo
			Tipo_registro: 1
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 27;

		FOR rec IN 

			SELECT 
				 linea
				,27	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'01'																				as "tipo_registro"	
				,'tipo_flujo'																		as "campo"
				,monto																				as "dato_reportado"
				,'NOOK'																				as "status"
		    FROM validador.rdc20_detalle_1
				 WHERE tipo_flujo = '02' and substring(monto,21,1) <> '+'

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			28: Tipo de flujo informado Venta de cartera (04) con signo distinto de negativo (-)
			Campo: Tipo de flujo
			Tipo_registro: 1
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 28;

		FOR rec IN 

			SELECT 
				 linea
				,28	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'01'																				as "tipo_registro"	
				,'tipo_flujo'																		as "campo"
				,monto																				as "dato_reportado"
				,'NOOK'																				as "status"
		    FROM validador.rdc20_detalle_1
				 WHERE tipo_flujo = '04' and substring(monto,21,1) <> '-'

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			29: Tipo de flujo informado Compra de cartera (05) con signo distinto de positivo (+)
			Campo: Tipo de flujo
			Tipo_registro: 1
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 29;

		FOR rec IN 

			SELECT 
				 linea
				,29	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'01'																				as "tipo_registro"	
				,'tipo_flujo'																		as "campo"
				,monto																				as "dato_reportado"
				,'NOOK'																				as "status"
		    FROM validador.rdc20_detalle_1
				 WHERE tipo_flujo = '05' and substring(monto,21,1) <> '+'

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			30: Tipo de flujo informado Cesion de credito del reportante a otra entidad (06) con signo distinto de negativo (-)
			Campo: Tipo de flujo
			Tipo_registro: 1
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 30;

		FOR rec IN 

			SELECT 
				 linea
				,30	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'01'																				as "tipo_registro"	
				,'tipo_flujo'																		as "campo"
				,monto																				as "dato_reportado"
				,'NOOK'																				as "status"
		    FROM validador.rdc20_detalle_1
				 WHERE tipo_flujo = '06' and substring(monto,21,1) <> '-'

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;		


		/*
			31: Tipo de flujo informado Cesion de credito adquirido por el reportante (07) con signo distinto de positivo (+)
			Campo: Tipo de flujo
			Tipo_registro: 1
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 31;

		FOR rec IN 

			SELECT 
				 linea
				,31	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'01'																				as "tipo_registro"	
				,'tipo_flujo'																		as "campo"
				,monto																				as "dato_reportado"
				,'NOOK'																				as "status"
		    FROM validador.rdc20_detalle_1
				 WHERE tipo_flujo = '07' and substring(monto,21,1) <> '+'

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			32: Tipo de flujo informado Prescripcion sentenciada por Tribunal diferentes a un procedimiento concursal de liquidacion (08) con signo distinto a negativo (-)
			Campo: Tipo de flujo
			Tipo_registro: 1
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 32;

		FOR rec IN 

			SELECT 
				 linea
				,32	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'01'																				as "tipo_registro"	
				,'tipo_flujo'																		as "campo"
				,monto																				as "dato_reportado"
				,'NOOK'																				as "status"
		    FROM validador.rdc20_detalle_1
				 WHERE tipo_flujo = '08' and substring(monto,21,1) <> '-'

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			33: Tipo de flujo informado Exclusion por obligacion reportable que cumple cinco años en morosidad (09) con signo distinto a negativo (-)
			Campo: Tipo de flujo
			Tipo_registro: 1
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 33;

		FOR rec IN 

			SELECT 
				 linea
				,33	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'01'																				as "tipo_registro"	
				,'tipo_flujo'																		as "campo"
				,monto																				as "dato_reportado"
				,'NOOK'																				as "status"
		    FROM validador.rdc20_detalle_1
				 WHERE tipo_flujo = '09' and substring(monto,21,1) <> '-'

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			34: Tipo de flujo informado Liquidacion de la obligacion por Procedimiento Concursal de liquidacion (10) con signo distinto de negativo (-)
			Campo: Tipo de flujo
			Tipo_registro: 1
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 34;

		FOR rec IN 

			SELECT 
				 linea
				,34	                																as "num_validador"
				,v_descripcion																		as "descripcion"
				,'01'																				as "tipo_registro"	
				,'tipo_flujo'																		as "campo"
				,monto																				as "dato_reportado"
				,'NOOK'																				as "status"
		    FROM validador.rdc20_detalle_1
				 WHERE tipo_flujo = '10' and substring(monto,21,1) <> '-'

		LOOP

			INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
			VALUES(
				 rec.linea
				,rec.num_validador
				,rec.descripcion
				,rec.tipo_registro
				,rec.campo
				,rec.dato_reportado
				,rec.status
			);			
		    
		END LOOP;


		/*
			35: Se informa tipo de flujo 08 y/o 10 en el registro 01 y no existe tipo de registro 02 informado
			Campo: Tipo de flujo
			Tipo_registro: 1
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 35;
		select count(1) into v_valor_1 from validador.rdc20_detalle_1 where tipo_flujo in ('08','10');
		select count(1) into v_valor_2 from validador.rdc20_detalle_2;

		IF v_valor_1 > 0 and v_valor_2 = 0 THEN

			FOR rec IN 
	
				SELECT 
					 linea
					,35	                																as "num_validador"
					,v_descripcion																		as "descripcion"
					,'01'																				as "tipo_registro"	
					,'tipo_flujo'																		as "campo"
					,'Monto reportado: ' || monto														as "dato_reportado"
					,'NOOK'																				as "status"
			    FROM validador.rdc20_detalle_1
					 WHERE tipo_flujo in ('08','10')
	
			LOOP
	
				INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
				VALUES(
					 rec.linea
					,rec.num_validador
					,rec.descripcion
					,rec.tipo_registro
					,rec.campo
					,rec.dato_reportado
					,rec.status
				);			
			    
			END LOOP;		

		END IF;


		/*
			36: Se informa tipo de registro 02 y no existen flujos 08 y/o 10 en el registro 01
			Campo: Tipo de flujo
			Tipo_registro: 2
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 36;
		select count(1) into v_valor_1 from validador.rdc20_detalle_1 where tipo_flujo in ('08','10');
		select count(1) into v_valor_2 from validador.rdc20_detalle_2;

		IF v_valor_1 = 0 and v_valor_2 > 0 THEN

			FOR rec IN 
	
				SELECT 
					 linea
					,36	                																as "num_validador"
					,v_descripcion																		as "descripcion"
					,'02'																				as "tipo_registro"	
					,'tipo_registro'																	as "campo"
					,'Codigo operacion: ' || codigo_operacion											as "dato_reportado"
					,'NOOK'																				as "status"
			    FROM validador.rdc20_detalle_2
					 	
			LOOP
	
				INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
				VALUES(
					 rec.linea
					,rec.num_validador
					,rec.descripcion
					,rec.tipo_registro
					,rec.campo
					,rec.dato_reportado
					,rec.status
				);			
			    
			END LOOP;		

		END IF;		


		/*
			37: Se informa tipo de flujo 04 y/o 06 en el registro 01 y no existe tipo de registro 03 informado
			Campo: Tipo de flujo
			Tipo_registro: 1
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 37;
		select count(1) into v_valor_1 from validador.rdc20_detalle_1 where tipo_flujo in ('04','06');
		select count(1) into v_valor_2 from validador.rdc20_detalle_3;

		IF v_valor_1 > 0 and v_valor_2 = 0 THEN

			FOR rec IN 
	
				SELECT 
					 linea
					,37	                																as "num_validador"
					,v_descripcion																		as "descripcion"
					,'01'																				as "tipo_registro"	
					,'tipo_flujo'																		as "campo"
					,'Monto reportado: ' || monto														as "dato_reportado"
					,'NOOK'																				as "status"
			    FROM validador.rdc20_detalle_1
					 WHERE tipo_flujo in ('04','06')
	
			LOOP
	
				INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
				VALUES(
					 rec.linea
					,rec.num_validador
					,rec.descripcion
					,rec.tipo_registro
					,rec.campo
					,rec.dato_reportado
					,rec.status
				);			
			    
			END LOOP;		

		END IF;


		/*
			38: Se informa tipo de registro 03 y no existen flujos 04 y/o 06 en el registro 01
			Campo: Tipo de flujo
			Tipo_registro: 3
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 38;
		select count(1) into v_valor_1 from validador.rdc20_detalle_1 where tipo_flujo in ('04','06');
		select count(1) into v_valor_2 from validador.rdc20_detalle_3;

		IF v_valor_1 = 0 and v_valor_2 > 0 THEN

			FOR rec IN 
	
				SELECT 
					 linea
					,38	                																as "num_validador"
					,v_descripcion																		as "descripcion"
					,'03'																				as "tipo_registro"	
					,'tipo_registro'																	as "campo"
					,'Codigo operacion: ' || codigo_operacion											as "dato_reportado"
					,'NOOK'																				as "status"
			    FROM validador.rdc20_detalle_3
					 	
			LOOP
	
				INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
				VALUES(
					 rec.linea
					,rec.num_validador
					,rec.descripcion
					,rec.tipo_registro
					,rec.campo
					,rec.dato_reportado
					,rec.status
				);			
			    
			END LOOP;		

		END IF;		


		/*
			39: Se informa tipo de flujo 05 y/o 07 en el registro 01 y no existe tipo de registro 04 informado
			Campo: Tipo de flujo
			Tipo_registro: 1
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 39;
		select count(1) into v_valor_1 from validador.rdc20_detalle_1 where tipo_flujo in ('05','07');
		select count(1) into v_valor_2 from validador.rdc20_detalle_4;

		IF v_valor_1 > 0 and v_valor_2 = 0 THEN

			FOR rec IN 
	
				SELECT 
					 linea
					,39	                																as "num_validador"
					,v_descripcion																		as "descripcion"
					,'01'																				as "tipo_registro"	
					,'tipo_flujo'																		as "campo"
					,'Monto reportado: ' || monto														as "dato_reportado"
					,'NOOK'																				as "status"
			    FROM validador.rdc20_detalle_1
					 WHERE tipo_flujo in ('05','07')
	
			LOOP
	
				INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
				VALUES(
					 rec.linea
					,rec.num_validador
					,rec.descripcion
					,rec.tipo_registro
					,rec.campo
					,rec.dato_reportado
					,rec.status
				);			
			    
			END LOOP;		

		END IF;		


		/*
			40: Se informa tipo de registro 04 y no existen flujos 05 y/o 07 en el registro 01
			Campo: Tipo de flujo
			Tipo_registro: 4
		*/		

		select descripcion into v_descripcion from interno.diccionario_validador where num_validador = 40;
		select count(1) into v_valor_1 from validador.rdc20_detalle_1 where tipo_flujo in ('05','07');
		select count(1) into v_valor_2 from validador.rdc20_detalle_4;

		IF v_valor_1 = 0 and v_valor_2 > 0 THEN

			FOR rec IN 
	
				SELECT 
					 linea
					,40	                																as "num_validador"
					,v_descripcion																		as "descripcion"
					,'04'																				as "tipo_registro"	
					,'tipo_registro'																	as "campo"
					,'Codigo operacion: ' || codigo_operacion											as "dato_reportado"
					,'NOOK'																				as "status"
			    FROM validador.rdc20_detalle_4
					 	
			LOOP
	
				INSERT INTO validador.rdc20_resultado(linea, num_validador, descripcion, tipo_registro, campo, dato_reportado, status)
				VALUES(
					 rec.linea
					,rec.num_validador
					,rec.descripcion
					,rec.tipo_registro
					,rec.campo
					,rec.dato_reportado
					,rec.status
				);			
			    
			END LOOP;		

		END IF;		
		
		
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