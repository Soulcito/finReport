CREATE OR REPLACE PROCEDURE proceso.excluir_por_morosidad()
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
	fecha_archivo date;	
	var_valor int;	
BEGIN
	BEGIN

		/*
			Procedimiento que calcula las operaciones morosas que tienen mas o igual a 5 años y las registra para RDC01 y RDC20
		*/

		-- | Determina fecha de proceso | --		

		select max(fecha_proceso)
		into fecha_archivo
		from interface.cartera_operaciones;

		-- | Calculo 5 años de morosidad en dias | --				

		var_valor := fecha_archivo - (fecha_archivo - INTERVAL '5 years')::date;


		FOR rec IN 

			-- Ademas de cumplir morosidad de 5 o mas años, se debe verificar que no exista en tabla de exclusion ya que causaria error por PK
			-- Ademas solo se necesita saber cuando se excluyo por primera ves ......
			
            select
				 B.cod_operacion
				,(fecha_archivo - fecha)::int      as "dias_morosos"			
			 from (
				  select
				  	 cod_operacion
					,min(fecha_cuota)   as "fecha"
				  from interface.cuadro_operaciones
				  		where (capital <> capital_pagado or interes_por_pagar <> interes_pagado or otros <> otros_pagado)
						  and fecha_cuota <= fecha_proceso
				  group by cod_operacion
			) as B left join interno.exclusion_morosidad as C on B.cod_operacion = C.cod_operacion
			where (fecha_archivo - fecha)::int >= var_valor
			  and C.cod_operacion is null 
		
		LOOP

			INSERT INTO interno.exclusion_morosidad (cod_operacion, fecha_exclusion, dias_morosos)
			VALUES(
				 rec.cod_operacion
				,fecha_archivo
				,rec.dias_morosos
			);

		END LOOP;

		
	EXCEPTION WHEN OTHERS THEN
		RAISE NOTICE 'Error durante en el proceso: %', SQLERRM;
		INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
		VALUES (
			CURRENT_TIMESTAMP,
			'ERROR',
			'',
			'proceso.excluir_por_morosidad',
			SQLERRM
		);
	END;
END;
$$