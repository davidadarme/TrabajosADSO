-- *************************************************
-- * DOCUMENTO DML para poblar las tablas de la BD *
-- * Autor: ADSO 2500680                           *
-- * Fecha: Mayo 23 de 2023                        *
-- *************************************************

INSERT INTO tab_pmtros VALUES(123,19,10,5000,1000);

INSERT INTO tab_ciudades VALUES(1,'Bogotá D.C.');
INSERT INTO tab_ciudades VALUES(2,'Medellín');
INSERT INTO tab_ciudades VALUES(3,'Bucaramanga');
INSERT INTO tab_ciudades VALUES(4,'Cali');
INSERT INTO tab_ciudades VALUES(5,'Pereira');
INSERT INTO tab_ciudades VALUES(6,'Manizales');
INSERT INTO tab_ciudades VALUES(7,'Ibagué');
INSERT INTO tab_ciudades VALUES(8,'Cartagena');
INSERT INTO tab_ciudades VALUES(9,'Cúcita');
INSERT INTO tab_ciudades VALUES(10,'Barrancabermeja');

INSERT INTO tab_marcas VALUES(1,'mARCA 1');
INSERT INTO tab_marcas VALUES(2,'Marca 2');
INSERT INTO tab_marcas VALUES(3,'Marca 3');
INSERT INTO tab_marcas VALUES(4,'Marca 4');
INSERT INTO tab_marcas VALUES(5,'Marca 5');

INSERT INTO tab_lineas VALUES(1,'Línea 1');
INSERT INTO tab_lineas VALUES(2,'Línea 2');
INSERT INTO tab_lineas VALUES(3,'Línea 3');

INSERT INTO tab_prod VALUES(2,'Producto 2',15000,2,1,TRUE,TRUE,10,1000);
INSERT INTO tab_prod VALUES(3,'Producto 3',12000,1,3,FALSE,TRUE,0,1500);
INSERT INTO tab_prod VALUES(1,'Producto 1',10000,1,2,FALSE,TRUE,0,500);
INSERT INTO tab_prod VALUES(4,'Producto 4',20000,3,3,FALSE,TRUE,0,500);
INSERT INTO tab_prod VALUES(5,'Producto 5',25000,1,2,FALSE,TRUE,0,3000);
INSERT INTO tab_prod VALUES(6,'Producto 6',18000,5,3,TRUE,TRUE,0,4000);
INSERT INTO tab_prod VALUES(7,'Producto 7',20000,4,1,TRUE,TRUE,0,2500);

INSERT INTO tab_clientes VALUES(1,'Carlos Eduardo Perez Rueda','350-3421739','ceperez@perezrueda.com',TRUE,'Calle 1 Carrera 2',3,1000);
INSERT INTO tab_clientes VALUES(2,'Laura Juliana Perez Barrera','310-1111111','ljperez@perezrueda.com',TRUE,'Calle 2 Carrera 3',1,5000);
INSERT INTO tab_clientes VALUES(3,'María Camila Perez Barrera','310-2222222','mcperez@perezrueda.com',TRUE,'Calle 3 Carrera 4',1,1500);
INSERT INTO tab_clientes VALUES(4,'Paula Sofía Perez Barrera','310-3333333','psperezr@perezrueda.com',FALSE,'Calle 4 Carrera 5',3,500);
INSERT INTO tab_clientes VALUES(5,'Evila Rueda Navas','310-4444444','erueda@perezrueda.com',FALSE,'Calle 5 Carrera 6',3,2500);