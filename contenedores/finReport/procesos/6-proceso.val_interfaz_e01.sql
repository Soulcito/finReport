CREATE OR REPLACE PROCEDURE proceso.val_interfaz_e01()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
	v_fecha date;
	
BEGIN
	BEGIN


		/* Obtencion de fecha de proceso */

		select to_date(valor,'YYYYMMDD')
		into v_fecha
		from interno.parametros_generales where cod = '3';

		/*
			E01-00001: Validacion de campo cod_persona si existe en la tabla relacion interno.tipo_persona_rel
		*/

		FOR rec IN 

			SELECT a.*
		    FROM interface.cartera_garantias a
		    LEFT JOIN interno.tipo_persona_rel b 
		        ON a.cod_persona = b.cod_entidad
		    WHERE b.cod_entidad IS NULL
		
		LOOP

			INSERT INTO log.cartera_garantias (fecha_proceso, id_garantia, rut_garante, cod_persona, cod_operacion, fecha_otorgamiento, gar_real_inmobiliaria, porc_real_inmobiliaria, gar_real_mobiliaria, porc_real_mobiliaria, gar_financiera, porc_financiera, gar_personal, porc_personal, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.id_garantia
				,rec.rut_garante
				,rec.cod_persona
				,rec.cod_operacion
				,rec.fecha_otorgamiento
				,rec.gar_real_inmobiliaria
				,rec.porc_real_inmobiliaria
				,rec.gar_real_mobiliaria
				,rec.porc_real_mobiliaria
				,rec.gar_financiera
				,rec.porc_financiera
				,rec.gar_personal
				,rec.porc_personal
				,'E01-00001; cod_persona: No se encuentra el codigo del campo cod_persona en la tabla interno.tipo_persona_rel'
			);

		END LOOP;


		/*
			E01-00002: Validacion de campo cod_operacion que exista en la interfaz cartera_operaciones
		*/

		FOR rec IN 

			SELECT a.*
		    FROM interface.cartera_garantias a
		    LEFT JOIN interface.cartera_operaciones b 
		        ON a.cod_operacion = b.cod_operacion
		    WHERE b.cod_operacion IS NULL
		
		LOOP

			INSERT INTO log.cartera_garantias (fecha_proceso, id_garantia, rut_garante, cod_persona, cod_operacion, fecha_otorgamiento, gar_real_inmobiliaria, porc_real_inmobiliaria, gar_real_mobiliaria, porc_real_mobiliaria, gar_financiera, porc_financiera, gar_personal, porc_personal, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.id_garantia
				,rec.rut_garante
				,rec.cod_persona
				,rec.cod_operacion
				,rec.fecha_otorgamiento
				,rec.gar_real_inmobiliaria
				,rec.porc_real_inmobiliaria
				,rec.gar_real_mobiliaria
				,rec.porc_real_mobiliaria
				,rec.gar_financiera
				,rec.porc_financiera
				,rec.gar_personal
				,rec.porc_personal
				,'E01-00002; cod_operacion: No se encuentra el campo cod_operacion en la interfaz cartera_operaciones'
			);

		END LOOP;		


		/*
			E01-00003: Validacion que los campos de porcentajes sean menores o igual a 100
		*/

		FOR rec IN 

			SELECT a.*
		    FROM interface.cartera_garantias a
			WHERE porc_real_inmobiliaria > 100.00 or porc_real_mobiliaria > 100.00 or porc_financiera > 100.00 or porc_personal > 100.00
		
		LOOP

			INSERT INTO log.cartera_garantias (fecha_proceso, id_garantia, rut_garante, cod_persona, cod_operacion, fecha_otorgamiento, gar_real_inmobiliaria, porc_real_inmobiliaria, gar_real_mobiliaria, porc_real_mobiliaria, gar_financiera, porc_financiera, gar_personal, porc_personal, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.id_garantia
				,rec.rut_garante
				,rec.cod_persona
				,rec.cod_operacion
				,rec.fecha_otorgamiento
				,rec.gar_real_inmobiliaria
				,rec.porc_real_inmobiliaria
				,rec.gar_real_mobiliaria
				,rec.porc_real_mobiliaria
				,rec.gar_financiera
				,rec.porc_financiera
				,rec.gar_personal
				,rec.porc_personal
				,'E01-00003; Los campos de porcentaje deben ser menores o igual a 100'
			);

		END LOOP;				


		/*
			E01-00004: Combinacion id_garantia + campo cod_operacion debe ser informado solo una ves en la interfaz de garantia
		*/

		FOR rec IN 

			SELECT a.*
		    FROM interface.cartera_garantias a
			INNER JOIN (
				select (id_garantia || cod_operacion) as "llave", count(id_garantia || cod_operacion) as "cantidad" from interface.cartera_garantias
				group by id_garantia || cod_operacion
				having count(id_garantia || cod_operacion) > 1
			) as b on (a.id_garantia || a.cod_operacion) = b.llave
		
		LOOP

			INSERT INTO log.cartera_garantias (fecha_proceso, id_garantia, rut_garante, cod_persona, cod_operacion, fecha_otorgamiento, gar_real_inmobiliaria, porc_real_inmobiliaria, gar_real_mobiliaria, porc_real_mobiliaria, gar_financiera, porc_financiera, gar_personal, porc_personal, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.id_garantia
				,rec.rut_garante
				,rec.cod_persona
				,rec.cod_operacion
				,rec.fecha_otorgamiento
				,rec.gar_real_inmobiliaria
				,rec.porc_real_inmobiliaria
				,rec.gar_real_mobiliaria
				,rec.porc_real_mobiliaria
				,rec.gar_financiera
				,rec.porc_financiera
				,rec.gar_personal
				,rec.porc_personal
				,'E01-00004; Combinacion id_garantia mas cod_operacion solo debe informarse una ves en la interfaz'
			);

		END LOOP;				


		/*
			E01-00005: Campo fecha de otorgamiento debe ser menor o igual a la fecha de proceso
		*/

		FOR rec IN 

			SELECT a.*
		    FROM interface.cartera_garantias a
			WHERE fecha_otorgamiento > fecha_proceso
		
		LOOP

			INSERT INTO log.cartera_garantias (fecha_proceso, id_garantia, rut_garante, cod_persona, cod_operacion, fecha_otorgamiento, gar_real_inmobiliaria, porc_real_inmobiliaria, gar_real_mobiliaria, porc_real_mobiliaria, gar_financiera, porc_financiera, gar_personal, porc_personal, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.id_garantia
				,rec.rut_garante
				,rec.cod_persona
				,rec.cod_operacion
				,rec.fecha_otorgamiento
				,rec.gar_real_inmobiliaria
				,rec.porc_real_inmobiliaria
				,rec.gar_real_mobiliaria
				,rec.porc_real_mobiliaria
				,rec.gar_financiera
				,rec.porc_financiera
				,rec.gar_personal
				,rec.porc_personal
				,'E01-00005; fecha_otorgamiento: Debe ser menor o igual a la fecha de proceso'
			);

		END LOOP;				


		/*
			E01-00006: Valida que las fecha de proceso que se informa en la interfaz, correspondan a la que estan parametrizadas en parametros generales
		*/

		FOR rec IN 

			SELECT a.*
		    FROM interface.cartera_garantias a
			WHERE a.fecha_proceso <> v_fecha
		
		LOOP

			INSERT INTO log.cartera_garantias (fecha_proceso, id_garantia, rut_garante, cod_persona, cod_operacion, fecha_otorgamiento, gar_real_inmobiliaria, porc_real_inmobiliaria, gar_real_mobiliaria, porc_real_mobiliaria, gar_financiera, porc_financiera, gar_personal, porc_personal, problema)
			VALUES(
				 rec.fecha_proceso
				,rec.id_garantia
				,rec.rut_garante
				,rec.cod_persona
				,rec.cod_operacion
				,rec.fecha_otorgamiento
				,rec.gar_real_inmobiliaria
				,rec.porc_real_inmobiliaria
				,rec.gar_real_mobiliaria
				,rec.porc_real_mobiliaria
				,rec.gar_financiera
				,rec.porc_financiera
				,rec.gar_personal
				,rec.porc_personal
				,'E01-00006; fecha_proceso: Valida que las fecha de proceso que se informa en la interfaz, correspondan a la que estan parametrizadas en parametros generales'
			);

		END LOOP;						
	
		
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.val_interfaz_e01',
			SQLERRM
		);
	END;
END;
$$