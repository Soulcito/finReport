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
		TRUNCATE TABLE tmp.cartera_garantias;
		TRUNCATE TABLE tmp.variacion_stock;

		-- LOG

        TRUNCATE TABLE log.log_eventos;
		TRUNCATE TABLE log.cartera_operaciones;
		TRUNCATE TABLE log.cuadro_operaciones;
		TRUNCATE TABLE log.tipo_cambio;
		TRUNCATE TABLE log.cuadro_rectificaciones;
		TRUNCATE TABLE log.cartera_garantias;
		TRUNCATE TABLE log.variacion_stock;

		-- INTERFACE

		TRUNCATE TABLE interface.cartera_operaciones;
		TRUNCATE TABLE interface.cuadro_operaciones;
		TRUNCATE TABLE interface.tipo_cambio;
		TRUNCATE TABLE interface.cuadro_rectificaciones;
		TRUNCATE TABLE interface.cartera_garantias;
		TRUNCATE TABLE interface.variacion_stock;

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
		TRUNCATE TABLE interno.parametros_generales;
		DELETE FROM interno.tipo_flujo_rel;
		DELETE FROM interno.tipo_flujo;
		TRUNCATE TABLE interno.calendario_rdc20;

        -- REPORTES

		TRUNCATE TABLE reporte.rdc01_texto;
		TRUNCATE TABLE reporte.rdc01_detalle;
		TRUNCATE TABLE reporte.rdc01_final;		
		TRUNCATE TABLE reporte.rdc01_caratula;
		TRUNCATE TABLE reporte.rdc20_texto;
		TRUNCATE TABLE reporte.rdc20_detalle_1;
		TRUNCATE TABLE reporte.rdc20_detalle_2;		
		TRUNCATE TABLE reporte.rdc20_detalle_3;		
		TRUNCATE TABLE reporte.rdc20_detalle_4;		
		TRUNCATE TABLE reporte.rdc20_final_1;		
		TRUNCATE TABLE reporte.rdc20_final_2;
		TRUNCATE TABLE reporte.rdc20_final_3;
		TRUNCATE TABLE reporte.rdc20_final_4;		
		TRUNCATE TABLE reporte.rdc20_caratula;				
		
		
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