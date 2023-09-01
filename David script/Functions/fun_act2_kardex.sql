CREATE OR REPLACE fun_act2_kardex() RETURNS BOOLEAN AS
$$
DECLARE wcur_prod   REFCURSOR;
DECLARE wreg_prod   RECORD;
DECLARE wreg_kardex RECORD;
DECLARE wid_consec  INTEGER;
BEGIN
    CREATE TEMP tmp_tot_kardex
    (
        id_consec INTEGER       NOT NULL,
        id_prod   INTEGER       NOT NULL,
        ind_tipmov  VARCHAR     NOT NULL,
        val_ent   INTEGER       NOT NULL,
        val_sal   INTEGER       NOT NULL,
        PRIMARY KEY(id_consec)
    );
    OPEN wcur_prod FOR SELECT a.id_prod FROM tab_prod a;
        wid_consec = 1;
		FETCH cur_prod INTO reg_prod;
		WHILE FOUND LOOP
            SELECT a.id_prod,a.ind_tipomov,SUM(a.cant_prod) AS stock INTO wreg_kardex FROM tab_kardex a
            GROUP BY 1,2
            ORDER BY 1
            CASE wreg_ind_tipomov
                WHEN 'E' THEN
                    
                    INSERT INTO tmp_tot_kardex VALUES(wid_consec,wreg_kardex.id_prod,wreg_kardex.ind_tipmov)
                WHEN 'S' THEN
            END;
       		FETCH cur_prod INTO reg_prod;
        END LOOP;
    CLOSE wcur_prod;
    RETURN TRUE;
END;