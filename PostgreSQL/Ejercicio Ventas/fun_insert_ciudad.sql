--SELECT * FROM tab_ciudades;
--SELECT fun_insert_ciud('21','Tira pal Norte');
CREATE OR REPLACE FUNCTION fun_insert_ciud(wid_ciudad  tab_ciudades.id_ciudad%TYPE,
                                           wnom_ciudad tab_ciudades.nom_ciudad%TYPE) RETURNS BOOLEAN AS
$$
    BEGIN
        INSERT INTO tab_ciudades VALUES(wid_ciudad, wnom_ciudad);
        IF FOUND THEN
            RAISE NOTICE 'Registro insertado exitosamente';
            RETURN TRUE;
        END IF;
        EXCEPTION
            WHEN division_by_zero THEN
                RAISE NOTICE 'caught division_by_zero';
                RETURN FALSE;
            WHEN SQLSTATE '23505' THEN
                RAISE NOTICE 'Registro ya existe...';
                RETURN FALSE;
            WHEN OTHERS THEN
                RAISE NOTICE '% %', SQLERRM, SQLSTATE;
                RETURN FALSE;
    END;
$$
LANGUAGE PLPGSQL