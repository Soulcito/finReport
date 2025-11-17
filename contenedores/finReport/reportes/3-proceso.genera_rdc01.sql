CREATE OR REPLACE PROCEDURE proceso.genera_rdc01()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
	
BEGIN
	BEGIN

		/*
			Proceso de generacion de RDC01
		*/

		-- | Borrado de tablas | --
		
		truncate table reporte.rdc01_texto;
		truncate table reporte.rdc01_detalle;
		truncate table reporte.rdc01_final;

		-- | Logica de generacion de reporte desde la interfaz cartera_operaciones | --

		SELECT 
			a.fecha_proceso, 
			a.rut, 
			b.cod_persona::INTEGER               										as "tipo_persona",
		    a.cod_operacion                      										as "codigo_operacion", 
		    b.cod_operacional::INTEGER           										as "operacion_titulo",
			d.cod_deudor::INTEGER                										as "tipo_deudor",
			e.cod_obligacion::INTEGER            										as "tipo_obligacion",
			TO_CHAR(a.fecha_otorgamiento,'YYYYMMDD')::VARCHAR       					as "fecha_otorgamiento", 
			a.carga_financiera::NUMERIC(15)                         					as "carga_financiera", 
			TO_CHAR(a.fecha_extincion,'YYYYMMDD')::VARCHAR          					as "fecha_extincion", 		
			a.gar_real_inmobiliaria::NUMERIC(15)                    					as "valor_gtia_inmobiliaria", 
			a.gar_real_mobiliaria::NUMERIC(15)                      					as "valor_gtia_mobiliaria", 
			a.gar_financiera::NUMERIC(15)                           					as "valor_gtia_financiera", 
			a.gar_personal::NUMERIC(15)                             					as "valor_gtia_personal", 
			(a.monto_original * f.valor)::NUMERIC(15)                 					as "monto_original", 
			(((a.capital + a.interes) * f.valor) + otros)::NUMERIC(15)  				as "monto_actual", 
			0                                                           				as "monto_al_dia",
			0																			as "monto_mora_1_tramo",
			0																			as "monto_mora_2_tramo",
			0																			as "monto_mora_3_tramo",
			0																			as "monto_mora_4_tramo",
			0																			as "monto_mora_5_tramo",
			0																			as "monto_mora_6_tramo",
			0																			as "monto_mora_7_tramo",
			0																			as "monto_mora_8_tramo",
			0																			as "monto_mora_9_tramo",
			0																			as "mora_actual",
			deuda_renegociada::INTEGER                                  				as "deuda_renegociada", 
			case
			  when TO_CHAR(fecha_aceleracion,'YYYYMMDD')::VARCHAR = '19000101' THEN 2
			  else 1 end                                                                as "deuda_acelerada",
			a.cod_persona           													as "tipo_persona_interfaz",
			a.cod_titulo_3          													as "operacion_titulo_interfaz", 
			a.cod_deudor            													as "tipo_deudor_interfaz",
			a.cod_tipo_obligacion   													as "tipo_obligacion_interfaz",
			''                      													as "fecha_primera_cuota_inpaga",
			a.cod_moneda																as "cod_moneda",
			f.valor																		as "tipo_cambio"
		FROM interface.cartera_operacionesa a inner join interno.tipo_persona_rel b     on a.cod_persona = b.cod_entidad
											  inner join interno.operacion_titulo_rel c on a.cod_titulo_3 = c.cod_entidad
											  inner join interno.tipo_deudor_rel d      on a.cod_deudor = d.cod_entidad
											  inner join interno.tabla_banco_126_rel e  on a.cod_tipo_obligacion = e.cod_entidad
											  inner join interface.tipo_cambio f        on a.cod_moneda = f.cod_moneda and a.fecha_proceso = f.fecha_proceso;
		   
		
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.genera_rdc01',
			SQLERRM
		);
	END;
END;
$$