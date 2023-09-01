CREATE OR REPLACE FUNCTION fun_del_tablasKARDEX() RETURNS "trigger" AS
$$
    DECLARE producto RECORD;
    sumastock INTEGER;
    restastock INTEGER;
    consecutivo INTEGER;
    total_valor BIGINT;
    suma_de_todos_cosprom BIGINT;
    promedio_total FLOAT;
    wid_consec tab_borrados.id_consec%TYPE;
    BEGIN
        IF TG_OP = 'INSERT' THEN
           NEW.usr_insert = CURRENT_USER;
           NEW.fec_insert = CURRENT_TIMESTAMP;
           RAISE NOTICE '%', NEW.id_prod;  
           
            SELECT tab_prod.val_cosprom, tab_prod.val_stock, tab_prod.val_stockmin, tab_prod.val_stockmax INTO producto FROM tab_prod
            WHERE tab_prod.id_prod = NEW.id_prod AND tab_prod.ind_estado = TRUE;

            restastock = producto.val_stock - NEW.cant_prod;
            sumastock = NEW.cant_prod + producto.val_stock;

             SELECT SUM (val_prod) INTO suma_de_todos_cosprom FROM tab_kardex WHERE ind_tipomov='E' and val_consec=NEW.val_consec ;
             promedio_total = suma_de_todos_cosprom/sumastock; 

            IF NEW.ind_tipomov='E' THEN 
                UPDATE tab_prod SET val_cosprom = promedio_total, val_stock = sumastock
                WHERE id_prod = NEW.id_prod;
            END IF;
            IF  NEW.ind_tipomov='S' THEN
                UPDATE tab_prod SET val_cosprom = promedio_total
                WHERE id_prod = NEW.id_prod;
            END IF;
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