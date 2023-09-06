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
    usr_insert      VARCHAR,
    fec_insert      TIMESTAMP WITHOUT TIME ZONE,
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
    usr_insert      VARCHAR,
    fec_insert      TIMESTAMP WITHOUT TIME ZONE,
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
    id_prod         INTEGER,
    nom_prod        VARCHAR,  
    ref_prod        VARCHAR,
    val_cosprom     INTEGER     CHECK(val_cosprom >=0),
    val_stock       INTEGER,
    val_stockmin    INTEGER,
    val_stockmax    INTEGER,
    val_reorden     INTEGER,
    id_marca        INTEGER,
    fec_compra      DATE   ,
    fec_vence       DATE   ,
    ind_estado      BOOLEAN    DEFAULT TRUE, --TRUE=Activo / FALSE=Inactivo
    usr_insert      VARCHAR,
    fec_insert      TIMESTAMP WITHOUT TIME ZONE,
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
    usr_insert      VARCHAR, /*PENDIENTE POR REVISION POR SI ES NECESARIO EL REGISTRO DEL UPDATE*/
    fec_insert      TIMESTAMP WITHOUT TIME ZONE,
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