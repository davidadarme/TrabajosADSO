/*
CREACION DE KARDEX 
Hecho por: DAVID JOSÉ ADARME DELGADO
Fecha: 3 de Junio de 2023
Fecha ultima act: 9 de Junio de 2023
ADSO - SENA
*/

-- SELECT fun_kardex('S', 5, 500000, 10, 'text');
--  wind_tipomov character varying, wid_prod integer, wval_prod integer, wcant_prod integer, wval_observa text 

CREATE OR REPLACE FUNCTION fun_kardex(wind_tipomov tab_kardex.ind_tipomov%TYPE, wid_prod tab_prod.id_prod%TYPE, wval_prod tab_kardex.val_prod%TYPE, wcant_prod tab_kardex.cant_prod%TYPE, wval_observa tab_kardex.val_observa%TYPE) RETURNS VARCHAR AS

$$
DECLARE
    wreg_prod   RECORD;
    suma_stock  INTEGER;
    resta_stock INTEGER;
    prom_total  FLOAT;
    sumcosprom  BIGINT;
    val_total   BIGINT;
    cur      
    CURSOR FOR SELECT val_cosprom, val_stock, val_stockmin, val_stockmax, ind_estado FROM tab_prod WHERE id_prod = wid_prod AND ind_estado = TRUE;

BEGIN
    IF wind_tipomov <> 'E' AND wind_tipomov <> 'S' OR wind_tipomov IS NULL THEN
        RAISE NOTICE 'Escriba algo en el tipo de movimiento que sirva';
        RETURN 'Error en el tipo de movimiento';
    END IF;

    IF wid_prod IS NULL OR wid_prod <= 0 THEN
        RAISE NOTICE 'Escriba algo en el ID del producto que sirva';
        RETURN 'Error en el ID del producto';
    END IF;

    IF wval_prod IS NULL OR wval_prod <= 0 OR wval_prod > 100000000 THEN
        RAISE NOTICE 'Escriba algo en el valor del producto que sirva';
        RETURN 'Error en el valor del producto';
    END IF;

    IF wcant_prod IS NULL OR wcant_prod <= 0 OR wcant_prod > 1000 THEN
        RAISE NOTICE 'Escriba algo en la cantidad del producto que sirva';
        RETURN 'Error en la cantidad del producto';
    END IF;

    -- Abrir el cursor
    OPEN cur;
    FETCH cur INTO wreg_prod;

    IF FOUND THEN
        prom_total = wreg_prod.val_cosprom / wreg_prod.val_stock;

        CASE
            WHEN wind_tipomov = 'E' THEN
                suma_stock = wreg_prod.val_stock + wcant_prod;
                val_total = wcant_prod * wval_prod;

                -- ENTRADA DE PRODUCTOS
                IF wreg_prod.val_stock = 0 AND wcant_prod > 0 THEN -- Validación de creación del primer producto
                    RETURN 'Felicidades';
                ELSIF suma_stock > wreg_prod.val_stockmin AND suma_stock < wreg_prod.val_stockmax THEN -- Validación positiva de entrada de acuerdo al stock mínimo y stock máximo
                    RETURN 'Felicidades';
                ELSIF wcant_prod > wreg_prod.val_stockmax OR suma_stock > wreg_prod.val_stockmax THEN -- Validación de exceso de stock máximo
                    RETURN 'Error';
                END IF;

                UPDATE tab_prod SET val_cosprom = prom_total, val_stock = resta_stock WHERE id_prod = wid_prod;
                RETURN 'Se actualizó el producto';

            -- SALIDA DE PRODUCTOS
            WHEN wind_tipomov = 'S' THEN
                resta_stock = wreg_prod.val_stock - wcant_prod;

                IF wreg_prod.val_stock > wreg_prod.val_stockmin AND wreg_prod.val_stockmax THEN -- Hay salida de producto(s)
                    RETURN 'Felicidades';
                ELSIF wreg_prod.val_stock = 0 OR wcant_prod < wreg_prod.val_stockmin THEN -- Validación de stock
                    RETURN 'Error';
                ELSE -- Fin
                    UPDATE tab_prod SET val_cosprom = prom_total, val_stock = resta_stock WHERE id_prod = wid_prod;
                    RETURN 'Se actualizó el producto';
                END IF;
        END CASE;
    ELSE
        RETURN 'No se encontró el producto';
    END IF;

    -- Cerrar el cursor
    CLOSE cur;
END;
$$
LANGUAGE PLPGSQL;

--TRIGGER INSERT, UPDATE & DELETE
CREATE OR REPLACE FUNCTION fun_act_tabla() RETURNS "trigger" AS
$$
    DECLARE wid_consec tab_borrados.id_consec%TYPE;
    BEGIN
        IF TG_OP = 'INSERT' THEN
           NEW.usr_insert = CURRENT_USER;
           NEW.fec_insert = CURRENT_TIMESTAMP;
           RETURN NEW;
        END IF;
        IF TG_OP = 'UPDATE' THEN
           NEW.usr_update = CURRENT_USER;
           NEW.fec_update = CURRENT_TIMESTAMP;
           RETURN NEW;
        END IF;
        IF TG_OP = 'DELETE' THEN
            SELECT MAX(a.id_consec) INTO wid_consec FROM tab_borrados a;
            IF wid_consec IS NULL THEN
                wid_consec = 1;
            ELSE
                wid_consec = wid_consec + 1;
            END IF;
            INSERT INTO tab_borrados VALUES(wid_consec,TG_RELNAME,CURRENT_USER,CURRENT_TIMESTAMP);
            RETURN OLD; 
        END IF;
    END;
$$
LANGUAGE PLPGSQL;