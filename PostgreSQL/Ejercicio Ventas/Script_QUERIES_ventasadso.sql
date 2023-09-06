--SELECT a.id_cliente,a.nom_cliente FROM tab_clientes AS a
--WHERE a.id_cliente BETWEEN 1 AND 3;
SELECT * FROM tab_ciudades;
UPDATE tab_ciudades SET nom_ciudad = 'Bogotá D.C.'
WHERE id_ciudad = 1;
UPDATE tab_ciudades SET nom_ciudad = 'Pereira'
WHERE id_ciudad = 5;

SELECT 
    (SELECT nom_prod FROM tab_productos WHERE val_preciovta = (SELECT MIN(val_preciovta) FROM tab_productos)) AS producto_minimo,
    (SELECT val_preciovta FROM tab_productos WHERE nom_prod = (SELECT nom_prod FROM tab_productos WHERE val_preciovta = (SELECT MIN(val_preciovta) FROM tab_productos))) AS precio_minimo,
    (SELECT nom_prod FROM tab_productos WHERE val_preciovta = (SELECT MAX(val_preciovta) FROM tab_productos)) AS producto_maximo,
    (SELECT val_preciovta FROM tab_productos WHERE nom_prod = (SELECT nom_prod FROM tab_productos WHERE val_preciovta = (SELECT MAX(val_preciovta) FROM tab_productos))) AS precio_maximo;
