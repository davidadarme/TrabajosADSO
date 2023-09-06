-- *****************************************************
-- * DOCUMENTO DDL para la base de datos db_ventasadso *
-- * Autor: ADSO 2500680                               *
-- * Fecha: Mayo 23 de 2023                            *
-- *****************************************************

DROP TABLE IF EXISTS tab_det_fact; -- Borrando la tabla de detalle de la factura
DROP TABLE IF EXISTS tab_enc_fact; -- Borrando la tabla de encabezado de la factura
DROP TABLE IF EXISTS tab_clientes;
DROP TABLE IF EXISTS tab_ciudades;
DROP TABLE IF EXISTS tab_prod;
DROP TABLE IF EXISTS tab_pmtros;
DROP TABLE IF EXISTS tab_marcas;
DROP TABLE IF EXISTS tab_lineas;

CREATE TABLE tab_pmtros
(
    id_empresa          SMALLINT        NOT NULL,
    por_iva             DECIMAL(2,0)    NOT NULL,
    por_desc            DECIMAL(3,0)    NOT NULL,
    num_factura         INTEGER         NOT NULL,
    base_fid            DECIMAL(4,0)    NOT NULL,
    PRIMARY KEY(id_empresa)
);

CREATE TABLE tab_ciudades
(
    id_ciudad           SMALLINT        NOT NULL,
    nom_ciudad          VARCHAR         NOT NULL,
    usr_insert          VARCHAR         NOT NULL,
    fec_insert          TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    usr_update          VARCHAR,
    fec_update          TIMESTAMP WITHOUT TIME ZONE,    
    PRIMARY KEY(id_ciudad)
);

CREATE TABLE tab_marcas
(
    id_marca            SMALLINT        NOT NULL,
    nom_marca           VARCHAR         NOT NULL,
    usr_insert          VARCHAR         NOT NULL,
    fec_insert          TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    usr_update          VARCHAR,
    fec_update          TIMESTAMP WITHOUT TIME ZONE,   
    PRIMARY KEY(id_marca)
);

CREATE TABLE tab_lineas
(
    id_linea            SMALLINT        NOT NULL,
    nom_linea           VARCHAR         NOT NULL,
    PRIMARY KEY(id_linea)
);

CREATE TABLE tab_prod
(
    id_prod             INTEGER         NOT NULL,
    nom_prod            VARCHAR         NOT NULL,
    val_preciovta       INTEGER         NOT NULL,
    id_marca            SMALLINT        NOT NULL,
    id_linea            SMALLINT        NOT NULL,
    ind_promocion       BOOLEAN         NOT NULL,
    ind_iva             BOOLEAN         NOT NULL,
    por_desc            DECIMAL(3,0)    NOT NULL,
    val_stock           INTEGER         NOT NULL,
    PRIMARY KEY(id_prod),
    FOREIGN KEY(id_marca)   REFERENCES tab_marcas(id_marca),
    FOREIGN KEY(id_linea)   REFERENCES tab_lineas(id_linea)
);

CREATE TABLE tab_clientes
(
    id_cliente	        BIGINT          NOT NULL,
    nom_cliente	        VARCHAR         NOT NULL,
    tel_cliente         VARCHAR         NOT NULL,
    mail_cliente        VARCHAR         NOT NULL,
    ind_fidel	        BOOLEAN         NOT NULL,
    dir_cliente         VARCHAR         NOT NULL,
    id_ciudad	        SMALLINT        NOT NULL,
    num_puntos	        INTEGER         NOT NULL,
    PRIMARY KEY(id_cliente),
    FOREIGN KEY(id_ciudad)  REFERENCES tab_ciudades(id_ciudad)
);

CREATE TABLE tab_enc_fact
(
    id_fact	            INTEGER         NOT NULL,
    id_cliente	        BIGINT          NOT NULL,
    fec_fact	        DATE            NOT NULL,
    id_ciudad	        SMALLINT        NOT NULL,
    for_pago	        DECIMAL(1,0)    NOT NULL,
    val_total	        BIGINT          NOT NULL,
    PRIMARY KEY(id_fact),
    FOREIGN KEY(id_ciudad)  REFERENCES tab_ciudades(id_ciudad),
    FOREIGN KEY(id_cliente) REFERENCES tab_clientes(id_cliente)
);

CREATE TABLE tab_det_fact
(
    id_fact	            INTEGER         NOT NULL,
    id_prod             INTEGER         NOT NULL,
    cant_prod           SMALLINT        NOT NULL,
    val_iva	            BIGINT          NOT NULL,
    val_desc	        BIGINT          NOT NULL,
    val_bruto	        BIGINT          NOT NULL,
    val_neto	        BIGINT          NOT NULL,
    PRIMARY KEY(id_fact,id_prod),
    FOREIGN KEY(id_fact)    REFERENCES tab_enc_fact(id_fact),
    FOREIGN KEY(id_prod)    REFERENCES tab_prod(id_prod)  
);

CREATE OR REPLACE FUNCTION fun_act_tabla() RETURNS "trigger" AS
$$
    BEGIN
        IF TG_OP = 'INSERT' THEN
            NEW.usr_insert = CURRENT_USER;
            NEW.fec_insert = NOW();
            RETURN NEW;
        END IF;
        IF TG_OP = 'UPDATE' THEN
            NEW.usr_update = CURRENT_USER;
            NEW.fec_update = NOW();
            RETURN NEW;
        END IF;
    END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER tri_act_tabla
BEFORE INSERT OR UPDATE on tab_ciudades FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla();

CREATE OR REPLACE TRIGGER tri_act_tabla
BEFORE INSERT OR UPDATE on tab_marcas FOR EACH ROW EXECUTE PROCEDURE fun_act_tabla(); 