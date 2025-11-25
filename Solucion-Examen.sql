-- Script de carga/actualización de cambios de moneda
-- BD: Monedas

DO $$
DECLARE
    -- Id de las monedas a trabajar
    v_id_usd   INT;
    v_id_eur   INT;
    v_id_cop   INT;
    v_id_mxn   INT;

    -- Próximo Id manual para MONEDA (porque la tabla tiene mucho DML con Id fijo)
    v_next_moneda_id INT;

    -- Variables para el ciclo de fechas
    v_fecha        DATE;
    v_cambio_usd   NUMERIC;
    v_cambio_eur   NUMERIC;
    v_cambio_cop   NUMERIC;
    v_cambio_mxn   NUMERIC;
BEGIN
    ------------------------------------------------------------------
    -- 1. Preparar siguiente Id disponible para la tabla MONEDA
    ------------------------------------------------------------------
    SELECT COALESCE(MAX(Id), 0) + 1
    INTO v_next_moneda_id
    FROM Moneda;

    ------------------------------------------------------------------
    -- 2. Asegurar que existan las 4 monedas requeridas
    --    Se buscan por Sigla; si no existen, se crean con un Id nuevo
    ------------------------------------------------------------------

    -- USD
    SELECT Id
    INTO v_id_usd
    FROM Moneda
    WHERE Sigla = 'USD';

    IF v_id_usd IS NULL THEN
        INSERT INTO Moneda (Id, Moneda, Sigla, Simbolo, Emisor)
        VALUES (v_next_moneda_id,
                'Dólar estadounidense',
                'USD',
                '$',
                'Estados Unidos')
        RETURNING Id INTO v_id_usd;

        v_next_moneda_id := v_next_moneda_id + 1;
    END IF;

    -- EUR
    SELECT Id
    INTO v_id_eur
    FROM Moneda
    WHERE Sigla = 'EUR';

    IF v_id_eur IS NULL THEN
        INSERT INTO Moneda (Id, Moneda, Sigla, Simbolo, Emisor)
        VALUES (v_next_moneda_id,
                'Euro',
                'EUR',
                '€',
                'Unión Europea')
        RETURNING Id INTO v_id_eur;

        v_next_moneda_id := v_next_moneda_id + 1;
    END IF;

    -- COP
    SELECT Id
    INTO v_id_cop
    FROM Moneda
    WHERE Sigla = 'COP';

    IF v_id_cop IS NULL THEN
        INSERT INTO Moneda (Id, Moneda, Sigla, Simbolo, Emisor)
        VALUES (v_next_moneda_id,
                'Peso colombiano',
                'COP',
                '$',
                'República de Colombia')
        RETURNING Id INTO v_id_cop;

        v_next_moneda_id := v_next_moneda_id + 1;
    END IF;

    -- MXN
    SELECT Id
    INTO v_id_mxn
    FROM Moneda
    WHERE Sigla = 'MXN';

    IF v_id_mxn IS NULL THEN
        INSERT INTO Moneda (Id, Moneda, Sigla, Simbolo, Emisor)
        VALUES (v_next_moneda_id,
                'Peso mexicano',
                'MXN',
                '$',
                'Estados Unidos Mexicanos')
        RETURNING Id INTO v_id_mxn;

        v_next_moneda_id := v_next_moneda_id + 1;
    END IF;

    ------------------------------------------------------------------
    -- 3. Generar cambios diarios para los últimos 2 meses
    --    Se usa generate_series para armar el rango de fechas.
    --    El valor del cambio se genera con una fórmula determinística
    --    para que siempre sea el mismo al re-ejecutar el script.
    ------------------------------------------------------------------
    FOR v_fecha IN
        SELECT generate_series(
                   (date_trunc('day', CURRENT_DATE) - INTERVAL '2 months')::date,
                   CURRENT_DATE,
                   INTERVAL '1 day'
               )::date
    LOOP
        -- Fórmulas simples para los valores de cambio (ejemplo)
        v_cambio_usd := 4000 + EXTRACT(DAY FROM v_fecha)::NUMERIC;   -- USD
        v_cambio_eur := 4300 + EXTRACT(DAY FROM v_fecha)::NUMERIC;   -- EUR
        v_cambio_cop := 1 + EXTRACT(DAY FROM v_fecha)::NUMERIC / 100; -- COP
        v_cambio_mxn := 200 + EXTRACT(DAY FROM v_fecha)::NUMERIC;    -- MXN

        ------------------------------------------------------------------
        -- Para cada moneda:
        --   * Si NO existe el registro (IdMoneda, Fecha), se inserta.
        --   * Si YA existe, se actualiza el valor de Cambio.
        -- Esto se logra con ON CONFLICT sobre el índice ixCambioMoneda.
        ------------------------------------------------------------------

        -- USD
        INSERT INTO CambioMoneda (IdMoneda, Fecha, Cambio)
        VALUES (v_id_usd, v_fecha, v_cambio_usd)
        ON CONFLICT (IdMoneda, Fecha)
        DO UPDATE
            SET Cambio = EXCLUDED.Cambio;

        -- EUR
        INSERT INTO CambioMoneda (IdMoneda, Fecha, Cambio)
        VALUES (v_id_eur, v_fecha, v_cambio_eur)
        ON CONFLICT (IdMoneda, Fecha)
        DO UPDATE
            SET Cambio = EXCLUDED.Cambio;

        -- COP
        INSERT INTO CambioMoneda (IdMoneda, Fecha, Cambio)
        VALUES (v_id_cop, v_fecha, v_cambio_cop)
        ON CONFLICT (IdMoneda, Fecha)
        DO UPDATE
            SET Cambio = EXCLUDED.Cambio;

        -- MXN
        INSERT INTO CambioMoneda (IdMoneda, Fecha, Cambio)
        VALUES (v_id_mxn, v_fecha, v_cambio_mxn)
        ON CONFLICT (IdMoneda, Fecha)
        DO UPDATE
            SET Cambio = EXCLUDED.Cambio;

    END LOOP;
END
$$;