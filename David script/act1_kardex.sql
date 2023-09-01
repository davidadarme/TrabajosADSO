--SELECT SUM(a.cant_prod) as tot_ent FROM tab_kardex a
--                                    WHERE a.ind_tipomov = 'E' AND a.id_prod = 1 UNION
--                                    SELECT SUM(b.cant_prod) as tot_sal FROM tab_kardex b
--                                    WHERE b.ind_tipomov = 'S' AND b.id_prod = 1;

--SELECT act_kardex();
--SELECT a.cant_prod FROM tab_kardex a
--WHERE a.id_prod = 1;
--SELECT SUM(a.cant_prod) FROM tab_kardex a
--WHERE a.id_prod = 1 AND a.ind_tipomov = 'S';
--SELECT * FROM tab_prod;
--SELECT * FROM tab_kardex;
--SELECT prueba();


CREATE OR REPLACE FUNCTION act_kardex() RETURNS BOOLEAN AS
$$
	DECLARE reg_prod RECORD;
	DECLARE cur_prod REFCURSOR;
	DECLARE resu_prueba INTEGER;
    DECLARE wtot_ent    INTEGER;
    DECLARE wtot_sal    INTEGER;
	BEGIN
		OPEN cur_prod FOR SELECT a.id_prod FROM tab_prod a;
			FETCH cur_prod INTO reg_prod;
			WHILE FOUND LOOP
              	resu_prueba=0;
				SELECT SUM(a.cant_prod) INTO wtot_ent FROM tab_kardex a
                WHERE a.ind_tipomov = 'E' AND a.id_prod = reg_prod.id_prod;
                IF wtot_ent IS NULL THEN
                    wtot_ent = 0;
                END IF;
                SELECT SUM(b.cant_prod) INTO wtot_sal FROM tab_kardex b
                WHERE b.ind_tipomov = 'S' AND b.id_prod = reg_prod.id_prod;
                IF wtot_sal IS NULL THEN
                    wtot_sal = 0;
                END IF;
                resu_prueba = wtot_ent - wtot_sal;
                RAISE NOTICE 'Saldo para producto % es %',reg_prod.id_prod,resu_prueba;
				UPDATE tab_prod SET val_stock=resu_prueba WHERE id_prod=reg_prod.id_prod;
				FETCH cur_prod INTO reg_prod;
			END LOOP;
		CLOSE cur_prod;
	RETURN TRUE;
	END
$$
LANGUAGE PLPGSQL;