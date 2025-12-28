CREATE OR REPLACE PROCEDURE proceso.trunca_tablas_validador()
LANGUAGE plpgsql
AS $$
BEGIN

		/*
			Procedimiento que elimina datos en tablas ocupadas en procesos para el validador
		*/

		-- RDC01

		truncate table validador.rdc01_texto;
		truncate table validador.rdc01_detalle;
		truncate table validador.rdc01_resultado;

		-- RDC20

		truncate table validador.rdc20_texto;
		truncate table validador.rdc20_detalle_1;
		truncate table validador.rdc20_detalle_2;
		truncate table validador.rdc20_detalle_3;
		truncate table validador.rdc20_detalle_4;
		truncate table validador.rdc20_resultado;		

		-- MANTENEDOR PARA VALIDADOR

		truncate table interno.diccionario_validador;

		-- LOG

        TRUNCATE TABLE log.log_eventos;
		
		
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.trunca_tablas_validador',
			SQLERRM
		);
END;
$$