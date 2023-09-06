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


CREATE OR REPLACE TRIGGER tri_del_tabla AFTER DELETE ON tab_ciudades
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON tab_ciudades
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_del_tabla AFTER DELETE ON tab_marcas
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON tab_marcas
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_del_tabla AFTER DELETE ON tab_prod
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON tab_prod
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_del_tabla AFTER DELETE ON tab_prov
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON tab_prov
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_del_tabla AFTER DELETE ON tab_sucur
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON tab_sucur
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_del_tabla AFTER DELETE ON tab_bodegas
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON tab_bodegas
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

/* trigger para KARDEX*/ 
CREATE OR REPLACE TRIGGER tri_del_tabla AFTER DELETE ON tab_kardex
FOR EACH ROW EXECUTE PROCEDURE fun_del_tablasKARDEX();

CREATE OR REPLACE TRIGGER tri_INSERTKARDEX_tabla AFTER INSERT  ON tab_kardex
FOR EACH ROW EXECUTE PROCEDURE fun_del_tablasKARDEX();

CREATE OR REPLACE  TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON tab_kardex
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();