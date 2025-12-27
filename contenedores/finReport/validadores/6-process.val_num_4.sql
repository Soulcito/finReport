CREATE OR REPLACE FUNCTION proceso.val_num_4(rut TEXT)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    rut_limpio  TEXT;
    cuerpo      TEXT;
    dv          CHAR;
    suma        INT := 0;
    factor      INT := 2;
    dig         INT;
    dv_calc     CHAR;
    i           INT;
BEGIN
    /***********************************************/
    
	/*  Validación de RUT                          */
    
	/***********************************************/

    IF rut IS NULL THEN
        RETURN 'NOOK';
    END IF;

    -- 1) Normalizar RUT
    rut_limpio := REPLACE(REPLACE(UPPER(rut), '.', ''), '-', '');

    IF LENGTH(rut_limpio) < 2 THEN
        RETURN 'NOOK';
    END IF;

    -- 2) Separar cuerpo y DV
    cuerpo := LTRIM(SUBSTRING(rut_limpio FROM 1 FOR LENGTH(rut_limpio) - 1), '0');
    dv     := SUBSTRING(rut_limpio FROM LENGTH(rut_limpio) FOR 1);

    IF cuerpo = '' THEN
        RETURN 'NOOK';
    END IF;

	IF cuerpo !~ '^[0-9]+$' THEN
    	RETURN 'NOOK';
	END IF;

    -- 3) Calcular dígito verificador
    FOR i IN REVERSE LENGTH(cuerpo)..1 LOOP
        dig := SUBSTRING(cuerpo FROM i FOR 1)::INT;
        suma := suma + (dig * factor);
        factor := CASE WHEN factor = 7 THEN 2 ELSE factor + 1 END;
    END LOOP;

    -- 4) Obtener DV esperado
    dig := 11 - (suma % 11);

    dv_calc := CASE
        WHEN dig = 11 THEN '0'
        WHEN dig = 10 THEN 'K'
        ELSE dig::TEXT
    END;

    -- 5) Comparar
    IF dv = dv_calc THEN
        RETURN 'OK';
    ELSE
        RETURN 'NOOK';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error durante el proceso: %', SQLERRM;

        INSERT INTO log.log_eventos (
            fecha, nivel, dag, procedimiento, mensaje
        )
        VALUES (
            CURRENT_TIMESTAMP,
            'ERROR',
            '',
            'proceso.val_num_4',
            SQLERRM
        );

        RETURN 'ERROR';
END;
$$;
