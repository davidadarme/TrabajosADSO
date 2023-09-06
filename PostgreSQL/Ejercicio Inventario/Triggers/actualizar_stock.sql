/* Trigger para actualizar el stock 
Actualizar la cantidad de producto que exista en tab_prod, en caso de que el valor sea 0 o negativo. Para ello, ale Analista ADSO se basará en los valores de stock mínimo y máximo. La meta es que Ningún producto quede con existencia negativa o valor de venta (cosprom) negativo.

1. Actualizar el precio promedio del producto, teniendo en cuenta:

a.	La cantidad de producto existente en el Kardex

b.	El costo de compra de cada producto en el Kardex

Esto se obtiene teniendo en cuenta:

•	Ejecutar el SP de actualización de kardex para obtener la existencia actual

•	Una vez ejecutado el actualizador, verificar cuáles productos están por debajo del stock mínimo (tab_prod)

•	Si el valor del stock no cumple, realizar una inserción en tab_kardex, de Entrada si el stock del producto es < que el mínimo, y de salida si el stock del producto es > que el máximo.

•	Ejecutar el actualizador del Kardex para normalizar la tabla de productos en su stock.
*/

-- SELECT id_prod, val_stock, val_stockmin
-- FROM tab_prod
-- WHERE val_stock < val_stockmin;

CREATE OR REPLACE FUNCTION actualizar_stock() RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.val_stock <= 0 OR NEW.val_cosprom <= 0 THEN
        NEW.val_stock = GREATEST(NEW.val_stock, NEW.val_cosprom);
        NEW.val_cosprom = GREATEST(NEW.val_cosprom, 0);
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE PLPGSQL;

CREATE TRIGGER trigger_actualizar_stock BEFORE INSERT OR UPDATE ON tab_prod
FOR EACH ROW EXECUTE FUNCTION actualizar_stock();