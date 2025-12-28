CREATE OR REPLACE FUNCTION proceso.val_en_dominio(
    valor varchar,
    dominios varchar[]
)
RETURNS varchar
LANGUAGE plpgsql
AS $$
BEGIN
    /*************************************************************/
    
	/*  Validacion generica de valor dentro de dominio permitido */
    
	/*************************************************************/

    -- 1) Validar NULL
	
    if valor IS NULL then
        return 'NOOK';
    end if;

 	-- 2) Validar dominio configurado
    
	if dominios IS NULL OR array_length(dominios, 1) IS NULL then
        RAISE EXCEPTION 'Dominio no definido o vacío';
    end if;

	-- 3) Validar dominio permitido
	
    if valor = ANY (dominios) then
        return 'OK';
    end if;

    return 'NOOK';

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO log.log_eventos (
            fecha, nivel, dag, procedimiento, mensaje
        )
        VALUES (
            CURRENT_TIMESTAMP,
            'ERROR',
            '',
            'proceso.val_en_dominio',
            SQLERRM
        );

        RETURN 'ERROR';
END;
$$;
