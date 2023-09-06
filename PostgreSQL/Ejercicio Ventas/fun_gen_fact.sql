CREATE OR REPLACE fun_gen_fact(wid_cliente tab_clientes.id_cliente%TYPE,wprod1 tab_prod.id_prod%TYPE,wcan1 tab_prod.val_stock%TYPE,
                               wforpago tab_enc_fact.for_pago%TYPE,wprod2 tab_prod.id_prod%TYPE,wcan2 tab_prod.val_stock%TYPE,
                               wprod3 tab_prod.id_prod%TYPE,wcan3 tab_prod.val_stock%TYPE) RETURNS BOOLEAN AS
$$
    DECLARE wval_bruto tab_prod.val_bruto%TYPE;
    BEGIN

    END;
$$
LANGUAGE PLPGSQL;