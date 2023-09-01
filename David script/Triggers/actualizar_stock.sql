
/* -- trigger para actualizar stock 
Actualizar la cantidad de producto que exista en tab_prod, en caso de que el valor sea 0 o negativo. Para ello, ale Analista ADSO se basará en los valores de stock mínimo y máximo. La meta es que Ningún producto quede con existencia negativa o valor de venta (cosprom) negativo.
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