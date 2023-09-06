-- FUNCTION: public.fun_factorial(integer)

-- DROP FUNCTION IF EXISTS public.fun_factorial(integer);

CREATE OR REPLACE FUNCTION public.fun_factorial(
	wnum integer)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
    DECLARE wres    INTEGER;
    DECLARE wind    INTEGER;
    BEGIN
        wres = 1;
        FOR wind IN 1..wnum LOOP
            wres = wres * wind;
        END LOOP;
        RAISE NOTICE 'El resultado del factorial de %, es %',wnum,wres;
        RETURN 'Se acabó esta función';
    END;
$BODY$;

ALTER FUNCTION public.fun_factorial(integer)
    OWNER TO postgres;
