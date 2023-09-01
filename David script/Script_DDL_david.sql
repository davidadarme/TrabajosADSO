/*
CREACION DE KARDEX
Fecha: 3 de Junio de 2023
Fecha ultima act: 20 de Junio de 2023
ADSO - SENA
*/

DROP VIEW IF EXISTS view_kardex;
DROP TABLE IF EXISTS tab_pmtros;
DROP TABLE IF EXISTS tab_sucurbode;
DROP TABLE IF EXISTS tab_bodegas;
DROP TABLE IF EXISTS tab_sucur;
DROP TABLE IF EXISTS tab_prodprov;
DROP TABLE IF EXISTS tab_acum_prod;
DROP TABLE IF EXISTS tab_kardex;
DROP TABLE IF EXISTS tab_prod;
DROP TABLE IF EXISTS tab_prov;
DROP TABLE IF EXISTS tab_ciudades;
DROP TABLE IF EXISTS tab_marcas;
DROP TABLE IF EXISTS tab_borrados;

CREATE TABLE tab_pmtros
(
    id_pmtro        INTEGER     NOT NULL,
    ind_metinv      VARCHAR     NOT NULL, -- indicador de tipo de método para inventario (PP)
    PRIMARY KEY(id_pmtro)
);

CREATE TABLE tab_ciudades
(
    id_ciudad       INTEGER     NOT NULL,
    nom_ciudad      VARCHAR     NOT NULL,
    usr_insert      VARCHAR     NOT NULL,
    fec_insert      TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    usr_update      VARCHAR,
    fec_update      TIMESTAMP WITHOUT TIME ZONE,
    PRIMARY KEY(id_ciudad)
);

CREATE TABLE tab_marcas
(
    id_marca        INTEGER     NOT NULL,
    nom_marca       VARCHAR     NOT NULL,
    usr_insert      VARCHAR     NOT NULL,
    fec_insert      TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    usr_update      VARCHAR,
    fec_update      TIMESTAMP WITHOUT TIME ZONE,
    PRIMARY KEY(id_marca)
);

CREATE TABLE tab_bodegas
(
    id_bodega       INTEGER     NOT NULL,
    nom_bodega      VARCHAR     NOT NULL,
    tel_bodega      BIGINT      NOT NULL,
    ind_estado      BOOLEAN     NOT NULL    DEFAULT TRUE, -- TRUE=Activa / FALSE= Inactiva
    usr_insert      VARCHAR     NOT NULL,
    fec_insert      TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    usr_update      VARCHAR,
    fec_update      TIMESTAMP WITHOUT TIME ZONE,    
    PRIMARY KEY(id_bodega)
);

CREATE TABLE tab_sucur
(
    id_sucur        INTEGER     NOT NULL,
    nom_sucur       VARCHAR     NOT NULL,
    tel_sucur       BIGINT     NOT NULL,
    dir_sucur       VARCHAR     NOT NULL,
    nom_encargado   VARCHAR     NOT NULL,
    usr_insert      VARCHAR     NOT NULL,
    fec_insert      TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    usr_update      VARCHAR,
    fec_update      TIMESTAMP WITHOUT TIME ZONE,    
    PRIMARY KEY(id_sucur)
);

CREATE TABLE tab_sucurbode
(
    id_sucur        INTEGER     NOT NULL,
    id_bodega       INTEGER     NOT NULL,
    PRIMARY KEY(id_sucur,id_bodega),
    FOREIGN KEY(id_sucur)   REFERENCES tab_sucur(id_sucur),
    FOREIGN KEY(id_bodega)  REFERENCES tab_bodegas(id_bodega)    
);

CREATE TABLE tab_prov
(
    id_prov         INTEGER     NOT NULL,
    nom_prov        VARCHAR     NOT NULL,
    tel_prov        BIGINT      NOT NULL,
    dir_prov        VARCHAR     NOT NULL,
    mail_prov       VARCHAR     NOT NULL,
    id_ciudad       INTEGER     NOT NULL,
    ind_estado      BOOLEAN     NOT NULL    DEFAULT TRUE, -- TRUE=Activo / FALSE=Inactivo
    usr_insert      VARCHAR     NOT NULL,
    fec_insert      TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    usr_update      VARCHAR,
    fec_update      TIMESTAMP WITHOUT TIME ZONE,    
    PRIMARY KEY(id_prov),
    FOREIGN KEY(id_ciudad)  REFERENCES tab_ciudades(id_ciudad)
);

CREATE TABLE tab_prod
(
    id_prod         INTEGER     NOT NULL,
    nom_prod        VARCHAR     NOT NULL,  
    ref_prod        VARCHAR     NOT NULL,
    val_cosprom     INTEGER     NOT NULL    CHECK(val_cosprom >=0),
    val_stock       INTEGER     NOT NULL,
    val_stockmin    INTEGER     NOT NULL,
    val_stockmax    INTEGER     NOT NULL,
    val_reorden     INTEGER     NOT NULL,
    id_marca        INTEGER     NOT NULL,
    fec_compra      DATE        NOT NULL,
    fec_vence       DATE        NOT NULL,
    ind_estado      BOOLEAN     NOT NULL    DEFAULT TRUE, --TRUE=Activo / FALSE=Inactivo
    usr_insert      VARCHAR     NOT NULL,
    fec_insert      TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    usr_update      VARCHAR,
    fec_update      TIMESTAMP WITHOUT TIME ZONE,
    PRIMARY KEY(id_prod),
    FOREIGN KEY(id_marca)   REFERENCES tab_marcas(id_marca)
);

CREATE UNIQUE INDEX idx_ref_prod ON tab_prod(ref_prod);

CREATE TABLE tab_prodprov
(
    id_prov         INTEGER     NOT NULL,
    id_prod         INTEGER     NOT NULL,
    val_costo       INTEGER     NOT NULL,
    val_stock       INTEGER     NOT NULL,
    PRIMARY KEY(id_prov,id_prod),
    FOREIGN KEY(id_prov)    REFERENCES tab_prov(id_prov),
    FOREIGN KEY(id_prod)    REFERENCES tab_prod(id_prod)
);

CREATE TABLE tab_kardex
(
    val_consec      INTEGER     NOT NULL    CHECK(val_consec>0),
    fec_movim       TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    ind_tipomov     VARCHAR     NOT NULL CHECK(ind_tipomov = 'E' OR ind_tipomov = 'S'),
    id_prod         INTEGER     NOT NULL,
    val_prod        INTEGER     NOT NULL,
    cant_prod       INTEGER     NOT NULL, 
    val_total       BIGINT      NOT NULL,
    val_observa     TEXT,
    usr_insert      VARCHAR     NOT NULL, /*PENDIENTE POR REVISION POR SI ES NECESARIO EL REGISTRO DEL UPDATE*/
    fec_insert      TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    usr_update      VARCHAR,
    fec_update      TIMESTAMP WITHOUT TIME ZONE,
    PRIMARY KEY(val_consec),
    FOREIGN KEY(id_prod)    REFERENCES tab_prod(id_prod)
);

CREATE TABLE tab_acum_prod
(
    id_prod         INTEGER     NOT NULL,
    val_inv         BIGINT      NOT NULL,
    PRIMARY KEY(id_prod),
    FOREIGN KEY(id_prod)    REFERENCES tab_prod(id_prod)      
);

CREATE TABLE tab_borrados -- ELIMINADOS (LLEVA EL REGISTRO EN UNA TABLA)
(
    id_consec       INTEGER     NOT NULL,
    nom_tabla       VARCHAR     NOT NULL,
    usr_delete      VARCHAR     NOT NULL,
    fec_delete      TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    PRIMARY KEY(id_consec)
);

CREATE OR REPLACE VIEW view_kardex AS SELECT a.id_prod,a.ind_tipomov,b.nom_prod,SUM(a.cant_prod) AS total FROM tab_kardex a, tab_prod b
WHERE a.id_prod = b.id_prod
GROUP BY 1,2,3
ORDER BY 1;

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

CREATE OR REPLACE  TRIGGER tri_INSERTKARDEX_tabla AFTER INSERT  ON tab_kardex
FOR EACH ROW EXECUTE PROCEDURE fun_del_tablasKARDEX();

CREATE OR REPLACE  TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON tab_kardex
FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

/* -- trigger para actualizar stock 
1.	Actualizar la cantidad de producto que exista en tab_prod, en caso de que el valor sea 0 o negativo. 

Para ello, ale Analista ADSO se basará en los valores de stock mínimo y máximo. 
La meta es que Ningún producto quede con val_stock negativo o val_cosprom negativo.
*/

CREATE OR REPLACE FUNCTION actualizar_stock() RETURNS "trigger" AS
$$
    DECLARE
    BEGIN
        IF NEW.val_stock <= 0 OR NEW.val_cosprom <=0
            THEN NEW.val_stock GREATEST(NEW.val_stock, NEW.val_cosprom)
        	    
        END IF;
        RETURN NEW;
    END
$$
LANGUAGE PLPGSQL;

CREATE TRIGGER trigger_actualizar_stock BEFORE INSERT OR UPDATE ON tab_prod
FOR EACH ROW EXECUTE FUNCTION actualizar_stock();

/* --