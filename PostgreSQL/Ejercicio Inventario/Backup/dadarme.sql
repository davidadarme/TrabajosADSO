PGDMP     %    "                {            dadarme    15.2    15.2 M    x           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            y           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            z           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            {           1262    16669    dadarme    DATABASE     }   CREATE DATABASE dadarme WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Colombia.1252';
    DROP DATABASE dadarme;
                postgres    false            �            1255    16800    act_kardex()    FUNCTION     �  CREATE FUNCTION public.act_kardex() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
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
$$;
 #   DROP FUNCTION public.act_kardex();
       public          postgres    false            �            1255    16820    actualizar_stock()    FUNCTION     5  CREATE FUNCTION public.actualizar_stock() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.val_stock <= 0 OR NEW.val_cosprom <= 0 THEN
        NEW.val_stock = GREATEST(NEW.val_stock, NEW.val_cosprom);
        NEW.val_cosprom = GREATEST(NEW.val_cosprom, 0);
    END IF;
    RETURN NEW;
END;
$$;
 )   DROP FUNCTION public.actualizar_stock();
       public          postgres    false            �            1255    16801 "   actualizar_stock_precio_promedio()    FUNCTION     d  CREATE FUNCTION public.actualizar_stock_precio_promedio() RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;
 9   DROP FUNCTION public.actualizar_stock_precio_promedio();
       public          postgres    false            �            1255    16802    fun_act2_kardex()    FUNCTION       CREATE FUNCTION public.fun_act2_kardex() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE 
    cur_prod   CURSOR FOR SELECT a.id_prod FROM tab_prod a;
    reg_prod   RECORD;
    wreg_kardex RECORD;
    wid_consec  INTEGER = 1;
BEGIN
    -- Crear una tabla temporal para almacenar los totales del Kardex
    CREATE TEMPORARY TABLE tmp_tot_kardex
    (
        id_consec INTEGER NOT NULL,
        id_prod   INTEGER NOT NULL,
        ind_tipmov VARCHAR NOT NULL,
        val_ent   INTEGER NOT NULL DEFAULT 0,
        val_sal   INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY(id_consec)
    );

    -- Recorrer los productos en tab_prod
    OPEN cur_prod;
    LOOP
        FETCH cur_prod INTO reg_prod;
        EXIT WHEN NOT FOUND;

        -- Calcular el saldo total del Kardex para el producto actual
        FOR wreg_kardex IN (SELECT id_prod, ind_tipomov, SUM(cant_prod) AS stock
                            FROM tab_kardex
                            WHERE id_prod = reg_prod.id_prod
                            GROUP BY 1, 2) 
        LOOP
            -- Insertar los totales en la tabla temporal
            IF wreg_kardex.ind_tipomov = 'E' THEN
                INSERT INTO tmp_tot_kardex (id_consec, id_prod, ind_tipmov, val_ent)
                VALUES (wid_consec, wreg_kardex.id_prod, wreg_kardex.ind_tipomov, wreg_kardex.stock);
            ELSIF wreg_kardex.ind_tipomov = 'S' THEN
                UPDATE tmp_tot_kardex
                SET val_sal = wreg_kardex.stock
                WHERE id_prod = wreg_kardex.id_prod AND ind_tipmov = 'E' AND val_ent > wreg_kardex.stock;
            END IF;
        END LOOP;
        
        wid_consec = wid_consec + 1;
    END LOOP;
    
    -- Cerrar el cursor
    CLOSE cur_prod;

    -- Devolver TRUE al finalizar el proceso
    RETURN TRUE;
END;
$$;
 (   DROP FUNCTION public.fun_act2_kardex();
       public          postgres    false            �            1255    16849 C   fun_act2_kardex(character varying, integer, integer, integer, text)    FUNCTION     -  CREATE FUNCTION public.fun_act2_kardex(wind_tipomov character varying, wid_prod integer, wval_prod integer, wcant_prod integer, wval_observa text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE 
    cur_prod   CURSOR FOR SELECT a.id_prod FROM tab_prod a;
    reg_prod   RECORD;
    wreg_kardex RECORD;
    wid_consec  INTEGER = 1;
BEGIN
    -- Crear una tabla temporal para almacenar los totales del Kardex
    CREATE TEMPORARY TABLE tmp_tot_kardex
    (
        id_consec INTEGER NOT NULL,
        id_prod   INTEGER NOT NULL,
        ind_tipmov VARCHAR NOT NULL,
        val_ent   INTEGER NOT NULL DEFAULT 0,
        val_sal   INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY(id_consec)
    );

    -- Recorrer los productos en tab_prod
    OPEN cur_prod;
    LOOP
        FETCH cur_prod INTO reg_prod;
        EXIT WHEN NOT FOUND;

        -- Calcular el saldo total del Kardex para el producto actual
        FOR wreg_kardex IN (SELECT id_prod, ind_tipomov, SUM(cant_prod) AS stock
                            FROM tab_kardex
                            WHERE id_prod = reg_prod.id_prod
                            GROUP BY 1, 2) 
        LOOP
            -- Insertar los totales en la tabla temporal
            IF wreg_kardex.ind_tipomov = 'E' THEN
                INSERT INTO tmp_tot_kardex (id_consec, id_prod, ind_tipmov, val_ent)
                VALUES (wid_consec, wreg_kardex.id_prod, wreg_kardex.ind_tipomov, wreg_kardex.stock);
            ELSIF wreg_kardex.ind_tipomov = 'S' THEN
                UPDATE tmp_tot_kardex
                SET val_sal = wreg_kardex.stock
                WHERE id_prod = wreg_kardex.id_prod AND ind_tipmov = 'E' AND val_ent > wreg_kardex.stock;
            END IF;
        END LOOP;
        
        wid_consec = wid_consec + 1;
    END LOOP;
    CLOSE cur_prod;
    RETURN TRUE;
END;
$$;
 �   DROP FUNCTION public.fun_act2_kardex(wind_tipomov character varying, wid_prod integer, wval_prod integer, wcant_prod integer, wval_observa text);
       public          postgres    false            �            1255    16822    fun_act_tabla()    FUNCTION     r  CREATE FUNCTION public.fun_act_tabla() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;
 &   DROP FUNCTION public.fun_act_tabla();
       public          postgres    false            �            1255    16803    fun_acum_prod()    FUNCTION     �  CREATE FUNCTION public.fun_acum_prod() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
    DECLARE wreg_acum_prod  RECORD;
    DECLARE wcur_acum_prod  REFCURSOR;
    DECLARE wval_total      BIGINT;
    BEGIN
        TRUNCATE tab_acum_prod;
        OPEN wcur_acum_prod FOR SELECT a.id_prod,SUM(a.val_stock) AS wval_total FROM tab_prodprov a
                                GROUP BY 1
                                ORDER BY 1;
            FETCH wcur_acum_prod INTO wreg_acum_prod;
            WHILE FOUND LOOP
                INSERT INTO tab_acum_prod VALUES(wreg_acum_prod.id_prod,wreg_acum_prod.wval_total);
                FETCH wcur_acum_prod INTO wreg_acum_prod;
            END LOOP;
        CLOSE wcur_acum_prod;
        RETURN TRUE;
    END;
$$;
 &   DROP FUNCTION public.fun_acum_prod();
       public          postgres    false            �            1255    16819    fun_del_tablaskardex()    FUNCTION     �  CREATE FUNCTION public.fun_del_tablaskardex() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;
 -   DROP FUNCTION public.fun_del_tablaskardex();
       public          postgres    false            �            1255    16804 >   fun_kardex(character varying, integer, integer, integer, text)    FUNCTION     r  CREATE FUNCTION public.fun_kardex(wind_tipomov character varying, wid_prod integer, wval_prod integer, wcant_prod integer, wval_observa text) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    wreg_prod   RECORD;
    suma_stock  INTEGER;
    resta_stock INTEGER;
    prom_total  FLOAT;
    sumcosprom  BIGINT;
    val_total   BIGINT;
    cur      
    CURSOR FOR SELECT val_cosprom, val_stock, val_stockmin, val_stockmax, ind_estado FROM tab_prod WHERE id_prod = wid_prod AND ind_estado = TRUE;

BEGIN
    IF wind_tipomov <> 'E' AND wind_tipomov <> 'S' OR wind_tipomov IS NULL THEN
        RAISE NOTICE 'Escriba algo en el tipo de movimiento que sirva';
        RETURN 'Error en el tipo de movimiento';
    END IF;

    IF wid_prod IS NULL OR wid_prod <= 0 THEN
        RAISE NOTICE 'Escriba algo en el ID del producto que sirva';
        RETURN 'Error en el ID del producto';
    END IF;

    IF wval_prod IS NULL OR wval_prod <= 0 OR wval_prod > 100000000 THEN
        RAISE NOTICE 'Escriba algo en el valor del producto que sirva';
        RETURN 'Error en el valor del producto';
    END IF;

    IF wcant_prod IS NULL OR wcant_prod <= 0 OR wcant_prod > 1000 THEN
        RAISE NOTICE 'Escriba algo en la cantidad del producto que sirva';
        RETURN 'Error en la cantidad del producto';
    END IF;

    -- Abrir el cursor
    OPEN cur;
    FETCH cur INTO wreg_prod;

    IF FOUND THEN
        prom_total = wreg_prod.val_cosprom / wreg_prod.val_stock;

        CASE
            WHEN wind_tipomov = 'E' THEN
                suma_stock = wreg_prod.val_stock + wcant_prod;
                val_total = wcant_prod * wval_prod;

                -- ENTRADA DE PRODUCTOS
                IF wreg_prod.val_stock = 0 AND wcant_prod > 0 THEN -- Validación de creación del primer producto
                    RETURN 'Felicidades';
                ELSIF suma_stock > wreg_prod.val_stockmin AND suma_stock < wreg_prod.val_stockmax THEN -- Validación positiva de entrada de acuerdo al stock mínimo y stock máximo
                    RETURN 'Felicidades';
                ELSIF wcant_prod > wreg_prod.val_stockmax OR suma_stock > wreg_prod.val_stockmax THEN -- Validación de exceso de stock máximo
                    RETURN 'Error';
                END IF;

                UPDATE tab_prod SET val_cosprom = prom_total, val_stock = resta_stock WHERE id_prod = wid_prod;
                RETURN 'Se actualizó el producto';

            -- SALIDA DE PRODUCTOS
            WHEN wind_tipomov = 'S' THEN
                resta_stock = wreg_prod.val_stock - wcant_prod;

            IF wreg_prod.val_stock > wreg_prod.val_stockmin AND wreg_prod.val_stock < wreg_prod.val_stockmax THEN
                RETURN 'Felicidades';
            ELSIF wreg_prod.val_stock = 0 OR wcant_prod < wreg_prod.val_stockmin THEN
                RETURN 'Error';
            ELSE
                UPDATE tab_prod SET val_cosprom = prom_total, val_stock = resta_stock WHERE id_prod = wid_prod;
                RETURN 'Se actualizó el producto';
            END IF;
        END CASE;
    ELSE
        RETURN 'No se encontró el producto';
    END IF;

    -- Cerrar el cursor
    CLOSE cur;
END;
$$;
 �   DROP FUNCTION public.fun_kardex(wind_tipomov character varying, wid_prod integer, wval_prod integer, wcant_prod integer, wval_observa text);
       public          postgres    false            �            1255    16805    fun_listar_prod()    FUNCTION     �  CREATE FUNCTION public.fun_listar_prod() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
    DECLARE wreg_prod   RECORD;
    DECLARE wcur_prod   REFCURSOR;
    DECLARE wcont       INTEGER;
    BEGIN
        OPEN wcur_prod FOR SELECT a.id_prod,a.nom_prod,a.val_cosprom FROM tab_prod a;     
            FETCH wcur_prod INTO wreg_prod;
            WHILE FOUND LOOP
                RAISE NOTICE 'Producto: % Nombre: % Costo: %',wreg_prod.id_prod,wreg_prod.nom_prod,wreg_prod.val_cosprom;
                FETCH wcur_prod INTO wreg_prod;
            END LOOP;
        CLOSE wcur_prod;
        RETURN 'Esta vaina funcionó';        
    END;
$$;
 (   DROP FUNCTION public.fun_listar_prod();
       public          postgres    false            �            1255    16799    prueba()    FUNCTION     �  CREATE FUNCTION public.prueba() RETURNS boolean
    LANGUAGE plpgsql
    AS $$
	DECLARE reg_prod RECORD;
	DECLARE cur_prod REFCURSOR;
	DECLARE reg_kardex RECORD; 
	DECLARE cur_kardex REFCURSOR; 
	DECLARE resu_prueba INTEGER;
	BEGIN
		OPEN cur_prod FOR SELECT a.id_prod FROM tab_prod a;
			FETCH cur_prod INTO reg_prod;
			WHILE FOUND LOOP
              	resu_prueba=0;
				OPEN cur_kardex FOR SELECT a.id_prod,a.ind_tipomov,a.cant_prod FROM tab_kardex a
					WHERE reg_prod.id_prod=a.id_prod;
					FETCH cur_kardex INTO reg_kardex;
					WHILE FOUND LOOP
						IF reg_kardex.ind_tipomov='E' THEN
							resu_prueba=resu_prueba+reg_kardex.cant_prod;
						ELSE
							resu_prueba=resu_prueba-reg_kardex.cant_prod;
						END IF;
						FETCH cur_kardex INTO reg_kardex;
					END LOOP;
				CLOSE cur_kardex;
				UPDATE tab_prod SET val_stock=resu_prueba WHERE id_prod=reg_prod.id_prod;
				FETCH cur_prod INTO reg_prod;
			END LOOP;
		CLOSE cur_prod;
	RETURN TRUE;
	END
$$;
    DROP FUNCTION public.prueba();
       public          postgres    false            �            1259    16778    tab_acum_prod    TABLE     a   CREATE TABLE public.tab_acum_prod (
    id_prod integer NOT NULL,
    val_inv bigint NOT NULL
);
 !   DROP TABLE public.tab_acum_prod;
       public         heap    postgres    false            �            1259    16691    tab_bodegas    TABLE     Y  CREATE TABLE public.tab_bodegas (
    id_bodega integer NOT NULL,
    nom_bodega character varying NOT NULL,
    tel_bodega bigint NOT NULL,
    ind_estado boolean DEFAULT true NOT NULL,
    usr_insert character varying,
    fec_insert timestamp without time zone,
    usr_update character varying,
    fec_update timestamp without time zone
);
    DROP TABLE public.tab_bodegas;
       public         heap    postgres    false            �            1259    16788    tab_borrados    TABLE     �   CREATE TABLE public.tab_borrados (
    id_consec integer NOT NULL,
    nom_tabla character varying NOT NULL,
    usr_delete character varying NOT NULL,
    fec_delete timestamp without time zone NOT NULL
);
     DROP TABLE public.tab_borrados;
       public         heap    postgres    false            �            1259    16677    tab_ciudades    TABLE       CREATE TABLE public.tab_ciudades (
    id_ciudad integer NOT NULL,
    nom_ciudad character varying NOT NULL,
    usr_insert character varying,
    fec_insert timestamp without time zone,
    usr_update character varying,
    fec_update timestamp without time zone
);
     DROP TABLE public.tab_ciudades;
       public         heap    postgres    false            �            1259    16764 
   tab_kardex    TABLE     �  CREATE TABLE public.tab_kardex (
    val_consec integer NOT NULL,
    fec_movim timestamp without time zone NOT NULL,
    ind_tipomov character varying NOT NULL,
    id_prod integer NOT NULL,
    val_prod integer NOT NULL,
    cant_prod integer NOT NULL,
    val_total bigint NOT NULL,
    val_observa text,
    usr_insert character varying,
    fec_insert timestamp without time zone,
    usr_update character varying,
    fec_update timestamp without time zone,
    CONSTRAINT tab_kardex_ind_tipomov_check CHECK ((((ind_tipomov)::text = 'E'::text) OR ((ind_tipomov)::text = 'S'::text))),
    CONSTRAINT tab_kardex_val_consec_check CHECK ((val_consec > 0))
);
    DROP TABLE public.tab_kardex;
       public         heap    postgres    false            �            1259    16684 
   tab_marcas    TABLE       CREATE TABLE public.tab_marcas (
    id_marca integer NOT NULL,
    nom_marca character varying NOT NULL,
    usr_insert character varying NOT NULL,
    fec_insert timestamp without time zone NOT NULL,
    usr_update character varying,
    fec_update timestamp without time zone
);
    DROP TABLE public.tab_marcas;
       public         heap    postgres    false            �            1259    16670 
   tab_pmtros    TABLE     m   CREATE TABLE public.tab_pmtros (
    id_pmtro integer NOT NULL,
    ind_metinv character varying NOT NULL
);
    DROP TABLE public.tab_pmtros;
       public         heap    postgres    false            �            1259    16734    tab_prod    TABLE     B  CREATE TABLE public.tab_prod (
    id_prod integer NOT NULL,
    nom_prod character varying,
    ref_prod character varying,
    val_cosprom integer,
    val_stock integer,
    val_stockmin integer,
    val_stockmax integer,
    val_reorden integer,
    id_marca integer,
    fec_compra date,
    fec_vence date,
    ind_estado boolean DEFAULT true,
    usr_insert character varying,
    fec_insert timestamp without time zone,
    usr_update character varying,
    fec_update timestamp without time zone,
    CONSTRAINT tab_prod_val_cosprom_check CHECK ((val_cosprom >= 0))
);
    DROP TABLE public.tab_prod;
       public         heap    postgres    false            �            1259    16749    tab_prodprov    TABLE     �   CREATE TABLE public.tab_prodprov (
    id_prov integer NOT NULL,
    id_prod integer NOT NULL,
    val_costo integer NOT NULL,
    val_stock integer NOT NULL
);
     DROP TABLE public.tab_prodprov;
       public         heap    postgres    false            �            1259    16721    tab_prov    TABLE     �  CREATE TABLE public.tab_prov (
    id_prov integer NOT NULL,
    nom_prov character varying NOT NULL,
    tel_prov bigint NOT NULL,
    dir_prov character varying NOT NULL,
    mail_prov character varying NOT NULL,
    id_ciudad integer NOT NULL,
    ind_estado boolean DEFAULT true NOT NULL,
    usr_insert character varying NOT NULL,
    fec_insert timestamp without time zone NOT NULL,
    usr_update character varying,
    fec_update timestamp without time zone
);
    DROP TABLE public.tab_prov;
       public         heap    postgres    false            �            1259    16699 	   tab_sucur    TABLE     �  CREATE TABLE public.tab_sucur (
    id_sucur integer NOT NULL,
    nom_sucur character varying NOT NULL,
    tel_sucur bigint NOT NULL,
    dir_sucur character varying NOT NULL,
    nom_encargado character varying NOT NULL,
    usr_insert character varying NOT NULL,
    fec_insert timestamp without time zone NOT NULL,
    usr_update character varying,
    fec_update timestamp without time zone
);
    DROP TABLE public.tab_sucur;
       public         heap    postgres    false            �            1259    16706    tab_sucurbode    TABLE     e   CREATE TABLE public.tab_sucurbode (
    id_sucur integer NOT NULL,
    id_bodega integer NOT NULL
);
 !   DROP TABLE public.tab_sucurbode;
       public         heap    postgres    false            �            1259    16795    view_kardex    VIEW       CREATE VIEW public.view_kardex AS
 SELECT a.id_prod,
    a.ind_tipomov,
    b.nom_prod,
    sum(a.cant_prod) AS total
   FROM public.tab_kardex a,
    public.tab_prod b
  WHERE (a.id_prod = b.id_prod)
  GROUP BY a.id_prod, a.ind_tipomov, b.nom_prod
  ORDER BY a.id_prod;
    DROP VIEW public.view_kardex;
       public          postgres    false    223    225    225    225    223            t          0    16778    tab_acum_prod 
   TABLE DATA           9   COPY public.tab_acum_prod (id_prod, val_inv) FROM stdin;
    public          postgres    false    226   g�       m          0    16691    tab_bodegas 
   TABLE DATA           �   COPY public.tab_bodegas (id_bodega, nom_bodega, tel_bodega, ind_estado, usr_insert, fec_insert, usr_update, fec_update) FROM stdin;
    public          postgres    false    219   ��       u          0    16788    tab_borrados 
   TABLE DATA           T   COPY public.tab_borrados (id_consec, nom_tabla, usr_delete, fec_delete) FROM stdin;
    public          postgres    false    227   ��       k          0    16677    tab_ciudades 
   TABLE DATA           m   COPY public.tab_ciudades (id_ciudad, nom_ciudad, usr_insert, fec_insert, usr_update, fec_update) FROM stdin;
    public          postgres    false    217   �       s          0    16764 
   tab_kardex 
   TABLE DATA           �   COPY public.tab_kardex (val_consec, fec_movim, ind_tipomov, id_prod, val_prod, cant_prod, val_total, val_observa, usr_insert, fec_insert, usr_update, fec_update) FROM stdin;
    public          postgres    false    225   ��       l          0    16684 
   tab_marcas 
   TABLE DATA           i   COPY public.tab_marcas (id_marca, nom_marca, usr_insert, fec_insert, usr_update, fec_update) FROM stdin;
    public          postgres    false    218   ��       j          0    16670 
   tab_pmtros 
   TABLE DATA           :   COPY public.tab_pmtros (id_pmtro, ind_metinv) FROM stdin;
    public          postgres    false    216   ��       q          0    16734    tab_prod 
   TABLE DATA           �   COPY public.tab_prod (id_prod, nom_prod, ref_prod, val_cosprom, val_stock, val_stockmin, val_stockmax, val_reorden, id_marca, fec_compra, fec_vence, ind_estado, usr_insert, fec_insert, usr_update, fec_update) FROM stdin;
    public          postgres    false    223   �       r          0    16749    tab_prodprov 
   TABLE DATA           N   COPY public.tab_prodprov (id_prov, id_prod, val_costo, val_stock) FROM stdin;
    public          postgres    false    224   ,�       p          0    16721    tab_prov 
   TABLE DATA           �   COPY public.tab_prov (id_prov, nom_prov, tel_prov, dir_prov, mail_prov, id_ciudad, ind_estado, usr_insert, fec_insert, usr_update, fec_update) FROM stdin;
    public          postgres    false    222   ��       n          0    16699 	   tab_sucur 
   TABLE DATA           �   COPY public.tab_sucur (id_sucur, nom_sucur, tel_sucur, dir_sucur, nom_encargado, usr_insert, fec_insert, usr_update, fec_update) FROM stdin;
    public          postgres    false    220   ��       o          0    16706    tab_sucurbode 
   TABLE DATA           <   COPY public.tab_sucurbode (id_sucur, id_bodega) FROM stdin;
    public          postgres    false    221   E�       �           2606    16782     tab_acum_prod tab_acum_prod_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.tab_acum_prod
    ADD CONSTRAINT tab_acum_prod_pkey PRIMARY KEY (id_prod);
 J   ALTER TABLE ONLY public.tab_acum_prod DROP CONSTRAINT tab_acum_prod_pkey;
       public            postgres    false    226            �           2606    16698    tab_bodegas tab_bodegas_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.tab_bodegas
    ADD CONSTRAINT tab_bodegas_pkey PRIMARY KEY (id_bodega);
 F   ALTER TABLE ONLY public.tab_bodegas DROP CONSTRAINT tab_bodegas_pkey;
       public            postgres    false    219            �           2606    16794    tab_borrados tab_borrados_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.tab_borrados
    ADD CONSTRAINT tab_borrados_pkey PRIMARY KEY (id_consec);
 H   ALTER TABLE ONLY public.tab_borrados DROP CONSTRAINT tab_borrados_pkey;
       public            postgres    false    227            �           2606    16683    tab_ciudades tab_ciudades_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.tab_ciudades
    ADD CONSTRAINT tab_ciudades_pkey PRIMARY KEY (id_ciudad);
 H   ALTER TABLE ONLY public.tab_ciudades DROP CONSTRAINT tab_ciudades_pkey;
       public            postgres    false    217            �           2606    16772    tab_kardex tab_kardex_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.tab_kardex
    ADD CONSTRAINT tab_kardex_pkey PRIMARY KEY (val_consec);
 D   ALTER TABLE ONLY public.tab_kardex DROP CONSTRAINT tab_kardex_pkey;
       public            postgres    false    225            �           2606    16690    tab_marcas tab_marcas_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.tab_marcas
    ADD CONSTRAINT tab_marcas_pkey PRIMARY KEY (id_marca);
 D   ALTER TABLE ONLY public.tab_marcas DROP CONSTRAINT tab_marcas_pkey;
       public            postgres    false    218            �           2606    16676    tab_pmtros tab_pmtros_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.tab_pmtros
    ADD CONSTRAINT tab_pmtros_pkey PRIMARY KEY (id_pmtro);
 D   ALTER TABLE ONLY public.tab_pmtros DROP CONSTRAINT tab_pmtros_pkey;
       public            postgres    false    216            �           2606    16742    tab_prod tab_prod_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.tab_prod
    ADD CONSTRAINT tab_prod_pkey PRIMARY KEY (id_prod);
 @   ALTER TABLE ONLY public.tab_prod DROP CONSTRAINT tab_prod_pkey;
       public            postgres    false    223            �           2606    16753    tab_prodprov tab_prodprov_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.tab_prodprov
    ADD CONSTRAINT tab_prodprov_pkey PRIMARY KEY (id_prov, id_prod);
 H   ALTER TABLE ONLY public.tab_prodprov DROP CONSTRAINT tab_prodprov_pkey;
       public            postgres    false    224    224            �           2606    16728    tab_prov tab_prov_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.tab_prov
    ADD CONSTRAINT tab_prov_pkey PRIMARY KEY (id_prov);
 @   ALTER TABLE ONLY public.tab_prov DROP CONSTRAINT tab_prov_pkey;
       public            postgres    false    222            �           2606    16705    tab_sucur tab_sucur_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.tab_sucur
    ADD CONSTRAINT tab_sucur_pkey PRIMARY KEY (id_sucur);
 B   ALTER TABLE ONLY public.tab_sucur DROP CONSTRAINT tab_sucur_pkey;
       public            postgres    false    220            �           2606    16710     tab_sucurbode tab_sucurbode_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.tab_sucurbode
    ADD CONSTRAINT tab_sucurbode_pkey PRIMARY KEY (id_sucur, id_bodega);
 J   ALTER TABLE ONLY public.tab_sucurbode DROP CONSTRAINT tab_sucurbode_pkey;
       public            postgres    false    221    221            �           1259    16748    idx_ref_prod    INDEX     L   CREATE UNIQUE INDEX idx_ref_prod ON public.tab_prod USING btree (ref_prod);
     DROP INDEX public.idx_ref_prod;
       public            postgres    false    223            �           2620    16834    tab_bodegas tri_act_tabla    TRIGGER     �   CREATE TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON public.tab_bodegas FOR EACH ROW EXECUTE FUNCTION public.fun_act_tabla();
 2   DROP TRIGGER tri_act_tabla ON public.tab_bodegas;
       public          postgres    false    219    247            �           2620    16824    tab_ciudades tri_act_tabla    TRIGGER     �   CREATE TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON public.tab_ciudades FOR EACH ROW EXECUTE FUNCTION public.fun_act_tabla();
 3   DROP TRIGGER tri_act_tabla ON public.tab_ciudades;
       public          postgres    false    247    217            �           2620    16837    tab_kardex tri_act_tabla    TRIGGER     �   CREATE TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON public.tab_kardex FOR EACH ROW EXECUTE FUNCTION public.fun_act_tabla();
 1   DROP TRIGGER tri_act_tabla ON public.tab_kardex;
       public          postgres    false    225    247            �           2620    16826    tab_marcas tri_act_tabla    TRIGGER     �   CREATE TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON public.tab_marcas FOR EACH ROW EXECUTE FUNCTION public.fun_act_tabla();
 1   DROP TRIGGER tri_act_tabla ON public.tab_marcas;
       public          postgres    false    247    218            �           2620    16828    tab_prod tri_act_tabla    TRIGGER     ~   CREATE TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON public.tab_prod FOR EACH ROW EXECUTE FUNCTION public.fun_act_tabla();
 /   DROP TRIGGER tri_act_tabla ON public.tab_prod;
       public          postgres    false    247    223            �           2620    16830    tab_prov tri_act_tabla    TRIGGER     ~   CREATE TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON public.tab_prov FOR EACH ROW EXECUTE FUNCTION public.fun_act_tabla();
 /   DROP TRIGGER tri_act_tabla ON public.tab_prov;
       public          postgres    false    247    222            �           2620    16832    tab_sucur tri_act_tabla    TRIGGER        CREATE TRIGGER tri_act_tabla BEFORE INSERT OR UPDATE ON public.tab_sucur FOR EACH ROW EXECUTE FUNCTION public.fun_act_tabla();
 0   DROP TRIGGER tri_act_tabla ON public.tab_sucur;
       public          postgres    false    220    247            �           2620    16833    tab_bodegas tri_del_tabla    TRIGGER     v   CREATE TRIGGER tri_del_tabla AFTER DELETE ON public.tab_bodegas FOR EACH ROW EXECUTE FUNCTION public.fun_act_tabla();
 2   DROP TRIGGER tri_del_tabla ON public.tab_bodegas;
       public          postgres    false    247    219            �           2620    16823    tab_ciudades tri_del_tabla    TRIGGER     w   CREATE TRIGGER tri_del_tabla AFTER DELETE ON public.tab_ciudades FOR EACH ROW EXECUTE FUNCTION public.fun_act_tabla();
 3   DROP TRIGGER tri_del_tabla ON public.tab_ciudades;
       public          postgres    false    217    247            �           2620    16835    tab_kardex tri_del_tabla    TRIGGER     |   CREATE TRIGGER tri_del_tabla AFTER DELETE ON public.tab_kardex FOR EACH ROW EXECUTE FUNCTION public.fun_del_tablaskardex();
 1   DROP TRIGGER tri_del_tabla ON public.tab_kardex;
       public          postgres    false    225    249            �           2620    16825    tab_marcas tri_del_tabla    TRIGGER     u   CREATE TRIGGER tri_del_tabla AFTER DELETE ON public.tab_marcas FOR EACH ROW EXECUTE FUNCTION public.fun_act_tabla();
 1   DROP TRIGGER tri_del_tabla ON public.tab_marcas;
       public          postgres    false    247    218            �           2620    16827    tab_prod tri_del_tabla    TRIGGER     s   CREATE TRIGGER tri_del_tabla AFTER DELETE ON public.tab_prod FOR EACH ROW EXECUTE FUNCTION public.fun_act_tabla();
 /   DROP TRIGGER tri_del_tabla ON public.tab_prod;
       public          postgres    false    247    223            �           2620    16829    tab_prov tri_del_tabla    TRIGGER     s   CREATE TRIGGER tri_del_tabla AFTER DELETE ON public.tab_prov FOR EACH ROW EXECUTE FUNCTION public.fun_act_tabla();
 /   DROP TRIGGER tri_del_tabla ON public.tab_prov;
       public          postgres    false    247    222            �           2620    16831    tab_sucur tri_del_tabla    TRIGGER     t   CREATE TRIGGER tri_del_tabla AFTER DELETE ON public.tab_sucur FOR EACH ROW EXECUTE FUNCTION public.fun_act_tabla();
 0   DROP TRIGGER tri_del_tabla ON public.tab_sucur;
       public          postgres    false    247    220            �           2620    16836 !   tab_kardex tri_insertkardex_tabla    TRIGGER     �   CREATE TRIGGER tri_insertkardex_tabla AFTER INSERT ON public.tab_kardex FOR EACH ROW EXECUTE FUNCTION public.fun_del_tablaskardex();
 :   DROP TRIGGER tri_insertkardex_tabla ON public.tab_kardex;
       public          postgres    false    249    225            �           2620    16821 !   tab_prod trigger_actualizar_stock    TRIGGER     �   CREATE TRIGGER trigger_actualizar_stock BEFORE INSERT OR UPDATE ON public.tab_prod FOR EACH ROW EXECUTE FUNCTION public.actualizar_stock();
 :   DROP TRIGGER trigger_actualizar_stock ON public.tab_prod;
       public          postgres    false    246    223            �           2606    16783 (   tab_acum_prod tab_acum_prod_id_prod_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tab_acum_prod
    ADD CONSTRAINT tab_acum_prod_id_prod_fkey FOREIGN KEY (id_prod) REFERENCES public.tab_prod(id_prod);
 R   ALTER TABLE ONLY public.tab_acum_prod DROP CONSTRAINT tab_acum_prod_id_prod_fkey;
       public          postgres    false    3258    223    226            �           2606    16773 "   tab_kardex tab_kardex_id_prod_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tab_kardex
    ADD CONSTRAINT tab_kardex_id_prod_fkey FOREIGN KEY (id_prod) REFERENCES public.tab_prod(id_prod);
 L   ALTER TABLE ONLY public.tab_kardex DROP CONSTRAINT tab_kardex_id_prod_fkey;
       public          postgres    false    223    225    3258            �           2606    16743    tab_prod tab_prod_id_marca_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tab_prod
    ADD CONSTRAINT tab_prod_id_marca_fkey FOREIGN KEY (id_marca) REFERENCES public.tab_marcas(id_marca);
 I   ALTER TABLE ONLY public.tab_prod DROP CONSTRAINT tab_prod_id_marca_fkey;
       public          postgres    false    3247    218    223            �           2606    16759 &   tab_prodprov tab_prodprov_id_prod_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tab_prodprov
    ADD CONSTRAINT tab_prodprov_id_prod_fkey FOREIGN KEY (id_prod) REFERENCES public.tab_prod(id_prod);
 P   ALTER TABLE ONLY public.tab_prodprov DROP CONSTRAINT tab_prodprov_id_prod_fkey;
       public          postgres    false    223    224    3258            �           2606    16754 &   tab_prodprov tab_prodprov_id_prov_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tab_prodprov
    ADD CONSTRAINT tab_prodprov_id_prov_fkey FOREIGN KEY (id_prov) REFERENCES public.tab_prov(id_prov);
 P   ALTER TABLE ONLY public.tab_prodprov DROP CONSTRAINT tab_prodprov_id_prov_fkey;
       public          postgres    false    222    224    3255            �           2606    16729     tab_prov tab_prov_id_ciudad_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tab_prov
    ADD CONSTRAINT tab_prov_id_ciudad_fkey FOREIGN KEY (id_ciudad) REFERENCES public.tab_ciudades(id_ciudad);
 J   ALTER TABLE ONLY public.tab_prov DROP CONSTRAINT tab_prov_id_ciudad_fkey;
       public          postgres    false    217    222    3245            �           2606    16716 *   tab_sucurbode tab_sucurbode_id_bodega_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tab_sucurbode
    ADD CONSTRAINT tab_sucurbode_id_bodega_fkey FOREIGN KEY (id_bodega) REFERENCES public.tab_bodegas(id_bodega);
 T   ALTER TABLE ONLY public.tab_sucurbode DROP CONSTRAINT tab_sucurbode_id_bodega_fkey;
       public          postgres    false    221    219    3249            �           2606    16711 )   tab_sucurbode tab_sucurbode_id_sucur_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tab_sucurbode
    ADD CONSTRAINT tab_sucurbode_id_sucur_fkey FOREIGN KEY (id_sucur) REFERENCES public.tab_sucur(id_sucur);
 S   ALTER TABLE ONLY public.tab_sucurbode DROP CONSTRAINT tab_sucurbode_id_sucur_fkey;
       public          postgres    false    3251    221    220            t      x������ � �      m   `   x����	�0E���
0�{�7K�7���b�?�x��Y�#�{1(j��R>���Jkun�>��D�(�Zv�������/a�ι�.�      u      x������ � �      k   _   x�3�t�O�/9��%̙� ��$�(������X��R��P��������L�����М3����8}SSRsr2��I�e��T��X������H��=... y#+�      s   	  x����n�0�g�)�	x�:�g���kбE��Gu$�4X�b}�����tD> ���3h=	��m�.��u������7J�t`ZC\1��H$j�m��*{(CP�И�e�1u��C#������ �a>�ͫA��M��������ڒ�o�LO&���#PI٘SI��ޖ�ucNyҽ��V�T�'�'�B���n(tꉻ�8�j��S e�O�ᯟl���Zy$����JCk{��T)�yNu<S(~�6SB��wO-Jn�vZ��(�-      l   L   x�3��M,JNT0�,�/.I/J-�4202�5��50T02�21�25�3�0264��".#�#�C���'F��� �&8      j      x�3������� 	��      q     x����n�0 ���@���ob�8sۀc���G����j����/v�������̛��a�	�m�2�2�z���%�����r<�/- K��pr~�a�D�vr��SM@�4D����T�ń�JL�h�v��+Ef�eh���~rۏXR�$���7����;$+$��S*a�h���jL��Ƭ��0d���#C]A���(MAl�?�����u�V?\����+�*\U��A�o���W�>��n4�� -<'       r   z   x�M���0C��0��O����(%�a����cԑ	���vKg�~���nI��#E���X�3E��/\dJ�=������7�.�c1{����wq`�bo�{q���M���Sy>"�ø)I      p   �   x���;n�0��Y>�/C$�̔!s�d)\�0�ā�b9B.֪DA��ҠA�"��u�O���`-pf?��8��ǹ�7.g؝>��0.'�f.����NW�ic��B��u~�À		�9�����ED�.��("�$�����E�D��D�DWD��E'�k�}=W���UJE\]"�V1*11ru1�[Ť�T����$bj�Y������Y���F�z����`����<]�}�N�      n   ~   x�3�.M.-*N�Q0�4640� N��"=$)׼�Ģ�Ĕ|d�������bN##c]K]C#C+S+S3=##cCs�? �2BXc��Ь1�f�	�#�1Ych�c�Ƙkb���� �U�      o      x�3�4�2�4bc.# ��6�1z\\\ 49o     