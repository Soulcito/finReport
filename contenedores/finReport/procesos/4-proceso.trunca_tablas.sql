CREATE OR REPLACE PROCEDURE proceso.trunca_tablas()
LANGUAGE plpgsql
AS $$
BEGIN
	BEGIN

		/*
			Procedimiento que elimina datos en tablas ocupadas en procesos
		*/

		-- TMP
		
		TRUNCATE TABLE tmp.cartera_operaciones;
		TRUNCATE TABLE tmp.cuadro_operaciones;
		TRUNCATE TABLE tmp.tipo_cambio;
		TRUNCATE TABLE tmp.cuadro_rectificaciones;

		-- LOG

		TRUNCATE TABLE log.cartera_operaciones;
		TRUNCATE TABLE log.cuadro_operaciones;
		TRUNCATE TABLE log.tipo_cambio;
		TRUNCATE TABLE log.cuadro_rectificaciones;

		-- INTERFACE

		TRUNCATE TABLE interface.cartera_operaciones;
		TRUNCATE TABLE interface.cuadro_operaciones;
		TRUNCATE TABLE interface.tipo_cambio;
		TRUNCATE TABLE interface.cuadro_rectificaciones;

		-- INTERNO

		DELETE FROM interno.interfaz_rel;
		DELETE FROM interno.interfaz;
		DELETE FROM interno.operacion_titulo_rel;
		DELETE FROM interno.operacion_titulo;
		DELETE FROM interno.tabla_banco_126_rel;
		DELETE FROM interno.tabla_banco_126;
		DELETE FROM interno.tipo_deudor_rel;
		DELETE FROM interno.tipo_deudor;
		DELETE FROM interno.tipo_persona_rel;
		DELETE FROM interno.tipo_persona;
		
		
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.trunca_tablas',
			SQLERRM
		);
	END;
END;
$$