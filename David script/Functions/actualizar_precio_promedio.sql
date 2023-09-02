CREATE OR REPLACE FUNCTION actualizar_stock_precio_promedio() RETURNS VOID AS $$
DECLARE
    producto RECORD;
BEGIN
    FOR producto IN (SELECT id_prod, val_stock, val_stockmin, val_stockmax FROM tab_prod) LOOP
        IF producto.val_stock <= 0 THEN
            -- Stock a mínimo si es menor o igual a 0
            UPDATE tab_prod SET val_stock = producto.val_stockmin WHERE id_prod = producto.id_prod;
            -- Entrada kardex
            INSERT INTO tab_kardex (fec_movim, ind_tipomov, id_prod, val_prod, cant_prod, val_total, val_observa, usr_insert, fec_insert)
            VALUES (CURRENT_TIMESTAMP, 'E', producto.id_prod, producto.val_stockmin, producto.val_stockmin, 0, 'Actualización de stock', 'Sistema', CURRENT_TIMESTAMP);
        END IF;
    END LOOP;
    -- Actualizar el precio promedio de productos
    FOR producto IN (SELECT id_prod FROM tab_prod) LOOP
        SELECT AVG(val_costo) INTO producto.val_costo FROM tab_prodprov WHERE id_prod = producto.id_prod;
        UPDATE tab_prod SET val_cosprom = producto.val_costo WHERE id_prod = producto.id_prod;
    END LOOP;
END;
$$ LANGUAGE plpgsql;