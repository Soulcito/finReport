CREATE OR REPLACE PROCEDURE proceso.calculo_calendario_rdc20()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
	fecha_archivo date;	
	var_fecha date;
	fin_mes	date;

BEGIN
	BEGIN

		/*
			Procedimiento que calcula las fechas de envio para el RDC20
		*/

		-- | Determina fecha de proceso | --		

		select valor::date
		into fecha_archivo
		from interno.parametros_generales where cod = '3';

		-- | Determina ultima fecha que existe en calendario RDC20 | --		

		select max(fecha)::date
		into var_fecha
		from interno.calendario_rdc20;

		-- | Logica para el calculo de fechas de envio | --



		while var_fecha <= fecha_archivo loop
		    
			fin_mes := date_trunc('month', var_fecha) + INTERVAL '1 month - 1 day';
			var_fecha := var_fecha + INTERVAL '14 days';			

			if var_fecha > fin_mes then

				insert into interno.calendario_rdc20 (fecha)
				values (to_char(fin_mes,'YYYYMMDD')::varchar)
				on conflict (fecha) do nothing;

				insert into interno.calendario_rdc20 (fecha)
				values (to_char(var_fecha,'YYYYMMDD')::varchar)
				on conflict (fecha) do nothing;				
			
			else	

				insert into interno.calendario_rdc20 (fecha)
				values (to_char(var_fecha,'YYYYMMDD')::varchar)
				on conflict (fecha) do nothing;
			
			end if;
			
		end loop;
		
		
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.calculo_calendario_rdc20',
			SQLERRM
		);
	END;
END;
$$