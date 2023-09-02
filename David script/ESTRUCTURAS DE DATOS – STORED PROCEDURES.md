SERVICIO NACIONAL DE APRENDIZAJE

1. Actualizar la cantidad de producto que exista en tab_prod, en caso de que el valor sea 0 o negativo. Para ello, ale Analista ADSO se basará en los valores de stock mínimo y máximo. La meta es que Ningún producto quede con existencia negativa o valor de venta (cosprom) negativo.
2. Actualizar el precio promedio del producto, teniendo en cuenta:

a.	La cantidad de producto existente en el Kardex

b.	El costo de compra de cada producto en el Kardex

Esto se obtiene teniendo en cuenta:

•	Ejecutar el SP de actualización de kardex para obtener la existencia actual

•	Una vez ejecutado el actualizador, verificar cuáles productos están por debajo del stock mínimo (tab_prod)

•	Si el valor del stock no cumple, realizar una inserción en tab_kardex, de Entrada si el stock del producto es < que el mínimo, y de salida si el stock del producto es > que el máximo.

•	Ejecutar el actualizador del Kardex para normalizar la tabla de productos en su stock.