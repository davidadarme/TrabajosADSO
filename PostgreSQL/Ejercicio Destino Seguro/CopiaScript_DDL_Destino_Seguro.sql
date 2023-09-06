/*
DROP TABLE tab_empresas_contratantes;
DROP TABLE tab_departamentos;
DROP TABLE tab_ciudades;
DROP TABLE tab_tipos_de_puntos;
DROP TABLE tab_puntos;
DROP TABLE tab_acompañantes;
DROP TABLE tab_alarmas;
DROP TABLE tab_cabezotes;
DROP TABLE tab_camioneros
DROP TABLE tab_camioneros;
DROP TABLE tab_cargas;
DROP TABLE tab_ciudades;
DROP TABLE tab_clasificaciones_de_cargas;
DROP TABLE tab_departamentos;
DROP TABLE tab_clasificaciones_de_cargas
DROP TABLE tab_dispositivos;
DROP TABLE tab_empresas_contratantes;
DROP TABLE tab_escoltas;
DROP TABLE tab_manifiesto_de_viaje_inicial;
DROP TABLE tab_manifiestos_de_viajes_final;
DROP TABLE tab_manifiestos_de_viajes_inicial;
DROP TABLE tab_novedades;
DROP TABLE tab_polizas;
DROP TABLE tab_puntos;
DROP TABLE tab_rutas;
DROP TABLE tab_siniestros;
DROP TABLE tab_tecnicos;
DROP TABLE tab_tipos_de_alarmas;
DROP TABLE tab_tipos_de_cargas;
DROP TABLE tab_tipos_de_dispositivos;
DROP TABLE tab_tipos_de_novedades;
DROP TABLE tab_tipos_de_puntos;
DROP TABLE tab_tipos_de_siniestros;
DROP TABLE tab_tipos_de_trabajadores;
*/

CREATE TABLE tab_empresas_contratantes(
    id_empresa_contratante SMALLINT NOT NULL,
    nombre_empresa_contratante VARCHAR NOT NULL,
    PRIMARY KEY(id_empresa_contratante)
);

CREATE TABLE tab_departamentos(
    id_departamento SMALLINT NOT NULL,
    nombre_departamento VARCHAR NOT NULL,
    PRIMARY KEY(id_departamento)
);

CREATE TABLE tab_ciudades(
    id_ciudad SMALLINT NOT NULL,
    id_departamento SMALLINT NOT NULL,
    nombre_ciudad VARCHAR NOT NULL,
    PRIMARY KEY(id_ciudad),
    FOREIGN KEY(id_departamento) REFERENCES tab_departamentos(id_departamento)
);

CREATE TABLE tab_tipos_de_puntos(
    id_tipo_de_punto SMALLINT NOT NULL,
    nombre_tipo_de_punto VARCHAR NOT NULL,
    PRIMARY KEY(id_tipo_de_punto)
);

CREATE TABLE tab_puntos(
    id_punto SMALLINT NOT NULL,
    id_tipo_de_punto SMALLINT NOT NULL,
    nombre_punto VARCHAR NOT NULL,
    id_ciudad SMALLINT NOT NULL,
    id_departamento SMALLINT NOT NULL,
    hora_apertura VARCHAR NOT NULL,
    hora_de_cierre VARCHAR NOT NULL,
    capacidad_de_vehiculos DECIMAL(2,0) NOT NULL,
    PRIMARY KEY(id_punto),
    FOREIGN KEY(id_ciudad) REFERENCES tab_ciudades(id_ciudad),
    FOREIGN KEY(id_tipo_de_punto) REFERENCES tab_tipos_de_puntos(id_tipo_de_punto),
    FOREIGN KEY(id_departamento) REFERENCES tab_departamentos(id_departamento)
);

CREATE TABLE tab_tipos_de_trabajadores(
    id_tipo_de_trabajador SMALLINT NOT NULL,
    nombre_tipo_de_trabajador VARCHAR NOT NULL,
    PRIMARY KEY(id_tipo_de_trabajador)
);

CREATE TABLE tab_trabajadores(
    id_trabajador  INTEGER NOT NULL,
    id_tipo_de_trabajador SMALLINT NOT NULL,
    nombre_trabajador VARCHAR NOT NULL,
    apellido_trabajador VARCHAR NOT NULL,
    telefono_trabajador INTEGER NOT NULL,
    mail_trabajador VARCHAR NOT NULL,
    edad_trabajador DECIMAL(2,0) NOT NULL CHECK(edad_trabajador > 17),
    PRIMARY KEY(id_trabajador),
    FOREIGN KEY(id_tipo_de_trabajador) REFERENCES tab_tipos_de_trabajadores(id_tipo_de_trabajador)
);

CREATE TABLE tab_cabezotes(
    id_cabezote INTEGER NOT NULL,
    id_dueño_del_cabezote INTEGER NOT NULL,
    nombre_dueño_del_cabezote VARCHAR NOT NULL,
    apellido_dueño_del_cabezote VARCHAR NOT NULL,
    potencia_cabezote VARCHAR NOT NULL,
    numero_de_ejes DECIMAL(1,0) NOT NULL,
    PRIMARY KEY(id_cabezote)
);

CREATE TABLE tab_tipos_de_trailers(
    id_tipo_de_trailer SMALLINT NOT NULL,
    nombre_tipo_de_trailer VARCHAR NOT NULL,
    PRIMARY KEY(id_tipo_de_trailer)
);

CREATE TABLE tab_trailers(
    id_trailer VARCHAR NOT NULL,
    id_tipo_de_trailer SMALLINT NOT NULL,
    id_dueño_del_trailer INTEGER NOT NULL,
    nombre_dueño_del_trailer VARCHAR NOT NULL,
    apellido_dueño_del_trailer VARCHAR NOT NULL,
    capacidad_de_trailer VARCHAR NOT NULL,
    PRIMARY KEY(id_trailer),
    FOREIGN KEY(id_tipo_de_trailer) REFERENCES tab_tipos_de_trailers(id_tipo_de_trailer)
);

CREATE TABLE tab_clasificaciones_de_cargas(
    id_clasificacion_de_carga SMALLINT NOT NULL,
    nombre_clasificacion_de_carga VARCHAR NOT NULL,
    PRIMARY KEY(id_clasificacion_de_carga)
);

CREATE TABLE tab_tipos_de_cargas(
    id_tipo_de_carga SMALLINT NOT NULL,
    id_clasificacion_de_carga SMALLINT NOT NULL,
    nombre_tipo_de_carga VARCHAR NOT NULL,
    peligrosidad_tipo_de_carga DECIMAL(2,0) NOT NULL,
    PRIMARY KEY(id_tipo_de_carga),
    FOREIGN KEY(id_clasificacion_de_carga) REFERENCES tab_clasificaciones_de_cargas(id_clasificacion_de_carga)
);

CREATE TABLE tab_cargas(
    id_carga INTEGER NOT NULL,
    id_clasificacion_de_carga SMALLINT NOT NULL,
    id_tipo_de_carga INTEGER NOT NULL, 
    id_empresa_contratante SMALLINT NOT NULL,
    cantidad_de_carga VARCHAR NOT NULL,
    PRIMARY KEY(id_carga),
    FOREIGN KEY(id_tipo_de_carga) REFERENCES tab_tipos_de_cargas(id_tipo_de_carga),
    FOREIGN KEY(id_clasificacion_de_carga) REFERENCES tab_clasificaciones_de_cargas(id_clasificacion_de_carga),
    FOREIGN KEY(id_empresa_contratante) REFERENCES tab_empresas_contratantes(id_empresa_contratante)
);

CREATE TABLE tab_polizas(
    id_poliza INTEGER NOT NULL,
    id_carga INTEGER NOT NULL,
    monto_de_aseguramiento INTEGER NOT NULL,
    valor_de_poliza INTEGER NOT NULL,
    inicio_de_la_poliza DATE NOT NULL,
    fin_de_la_poliza DATE NOT NULL,
    PRIMARY KEY(id_poliza),
    FOREIGN KEY(id_carga) REFERENCES tab_cargas(id_carga) 
);

CREATE TABLE tab_vias(
    id_via SMALLINT NOT NULL,
    nombre_via VARCHAR NOT NULL,
    id_ciudad SMALLINT NOT NULL,
    id_departamento SMALLINT NOT NULL,
    PRIMARY KEY(id_via),
    FOREIGN KEY(id_ciudad) REFERENCES tab_ciudades(id_ciudad),
    FOREIGN KEY(id_departamento) REFERENCES tab_departamentos(id_departamento)
);

CREATE TABLE tab_zonas(
    id_zona SMALLINT NOT NULL,
    nombre_zona VARCHAR NOT NULL,
    peligrosidad_de_zona DECIMAL(1,0) NOT NULL,
    PRIMARY KEY(id_zona)
);

CREATE TABLE tipos_de_puntos_de_control(
    id_tipo_de_control SMALLINT NOT NULL,
    nombre_tipo_de_control VARCHAR NOT NULL,
    PRIMARY KEY(id_tipo_de_control)
);

CREATE TABLE tab_rutas(
    id_ruta SMALLINT NOT NULL,
    nombre_ruta VARCHAR NOT NULL,
    id_ciudad_de_origen SMALLINT NOT NULL,
    id_ciudad_de_llegada SMALLINT NOT NULL,
    id_zona SMALLINT NOT NULL,
    id_vias_transitadas SMALLINT NOT NULL,
    cantidad_de_puntos_de_control_en_ruta DECIMAL(3,0) NOT NULL,
    id_punto_de_control SMALLINT NOT NULL,
    PRIMARY KEY(id_ruta),
    FOREIGN KEY(id_ciudad_de_origen) REFERENCES tab_ciudades(id_ciudad),
    FOREIGN KEY(id_ciudad_de_llegada) REFERENCES tab_ciudades(id_ciudad),
    FOREIGN KEY(id_zona) REFERENCES tab_zonas(id_zona),
    FOREIGN KEY(id_vias_transitadas) REFERENCES tab_vias(id_via)
);

CREATE TABLE tab_tipos_de_dispositivos(
    id_tipo_de_dispositivo SMALLINT NOT NULL,
    nombre_tipo_de_dispositivo VARCHAR NOT NULL,
    PRIMARY KEY(id_tipo_de_dispositivo)
);

CREATE TABLE tab_dispositivos(
    id_dispositivo SMALLINT NOT NULL,
    id_tipo_de_dispositivo SMALLINT NOT NULL,
    id_responsable_dispositivo INTEGER NOT NULL,
    id_zona SMALLINT NOT NULL,
    id_via SMALLINT NOT NULL,
    ubicación_exacta_del_dispositivo VARCHAR NOT NULL,
    PRIMARY KEY(id_dispositivo),
    FOREIGN KEY(id_responsable_dispositivo) REFERENCES tab_trabajadores(id_trabajador),
    FOREIGN KEY(id_tipo_de_dispositivo) REFERENCES tab_tipos_de_dispositivos(id_tipo_de_dispositivo),
    FOREIGN KEY(id_zona) REFERENCES tab_zonas(id_zona),
    FOREIGN KEY(id_via) REFERENCES tab_vias(id_via)
);

CREATE TABLE tab_tecnicos(
    id_trabajador INTEGER NOT NULL,
    id_tipo_de_trabajador SMALLINT NOT NULL,
    id_dispositivo_instalado SMALLINT NOT NULL,
    PRIMARY KEY(id_trabajador,id_tipo_de_trabajador),
    FOREIGN KEY(id_dispositivo_instalado) REFERENCES tab_dispositivos(id_dispositivo)
);

CREATE TABLE puntos_de_control(
    id_punto_de_control SMALLINT NOT NULL,
    id_dispositivo SMALLINT NOT NULL,
    nombre_punto_de_control VARCHAR NOT NULL,
    id_encargado_del_punto_de_control INTEGER NOT NULL,
    id_zona SMALLINT NOT NULL,
    id_via SMALLINT NOT NULL,
    hora_de_apertura_punto_de_control TIME NOT NULL,
    hora_de_cierre_punto_de_control TIME NOT NULL,
    PRIMARY KEY(id_punto_de_control),
    FOREIGN KEY(id_dispositivo) REFERENCES tab_dispositivos(id_dispositivo),
    FOREIGN KEY(id_zona) REFERENCES tab_zonas(id_zona),
    FOREIGN KEY(id_via) REFERENCES tab_vias(id_via)
);

CREATE TABLE tab_camioneros(
    id_camionero INTEGER NOT NULL,
    nombre_camionero VARCHAR NOT NULL,
    apellido_camionero VARCHAR NOT NULL,
    teléfono_camionero INTEGER NOT NULL,
    PRIMARY KEY(id_camionero)
);

CREATE TABLE tab_acompañantes(
    id_acompañante INTEGER NOT NULL,
    nombre_acompañante VARCHAR NOT NULL,
    apellido_acompañante VARCHAR NOT NULL,
    teléfono_acompañante INTEGER NOT NULL,
    PRIMARY KEY(id_acompañante)
);

CREATE TABLE tab_manifiestos_de_viajes_inicial(
    id_manifiesto_de_viaje_inicial SMALLINT NOT NULL,
    id_poliza SMALLINT NOT NULL,
    id_cabezote INTEGER NOT NULL,
    id_trailer VARCHAR NOT NULL,
    id_carga INTEGER NOT NULL,
    id_empresa_contratante SMALLINT NOT NULL,
    id_camionero INTEGER NOT NULL,
    id_acompañante INTEGER NOT NULL,
    id_punto_de_carga SMALLINT NOT NULL,
    id_punto_de_descarga SMALLINT NOT NULL,
    id_ruta SMALLINT NOT NULL,
    id_dispositivo_en_carga SMALLINT NOT NULL,
    fecha_de_salida DATE NOT NULL,
    fecha_de_llegada DATE NOT NULL,
    hora_de_salida TIME NOT NULL,
    hora_de_llegada TIME NOT NULL,
    PRIMARY KEY(id_manifiesto_de_viaje_inicial),
    FOREIGN KEY(id_cabezote) REFERENCES tab_cabezotes(id_cabezote),
    FOREIGN KEY(id_dispositivo_en_carga) REFERENCES tab_dispositivos(id_dispositivo),
    FOREIGN KEY(id_trailer) REFERENCES tab_trailers(id_trailer),
    FOREIGN KEY(id_carga) REFERENCES tab_cargas(id_carga),
    FOREIGN KEY(id_empresa_contratante) REFERENCES tab_empresas_contratantes(id_empresa_contratante),
    FOREIGN KEY(id_camionero) REFERENCES tab_camioneros(id_camionero),
    FOREIGN KEY(id_punto_de_carga) REFERENCES tab_puntos(id_punto),
    FOREIGN KEY(id_punto_de_descarga) REFERENCES tab_puntos(id_punto),
    FOREIGN KEY(id_ruta) REFERENCES tab_rutas(id_ruta),
    FOREIGN KEY(id_poliza) REFERENCES tab_polizas(id_poliza)
);

CREATE TABLE tab_escoltas(
    id_trabajador INTEGER NOT NULL,
    id_tipo_de_trabajador SMALLINT NOT NULL,
    id_viaje SMALLINT NOT NULL,
    id_tipo_de_vehiculo_escolta SMALLINT NOT NULL,
    escolta_con_dotacion VARCHAR NOT NULL,
    PRIMARY KEY(id_trabajador,id_tipo_de_trabajador),
    FOREIGN KEY(id_viaje) REFERENCES tab_manifiestos_de_viaje_inicial(id_viaje),
    FOREIGN KEY(id_vehiculo_escolta) REFERENCES tab_vehiculos_escoltas(id_vehiculo_escolta)
);

CREATE TABLE tab_vehiculos_escoltas(
    id_vehiculo_escolta SMALLINT NOT NULL,
    capacidad_del_tanque DECIMAL(4,0) NOT NULL,
    modelo_vehiculo_escolta VARCHAR NOT NULL,
    PRIMARY KEY(id_tipo_de_vehiculo_escolta)
);

CREATE TABLE tab_tipos_de_novedades(
    id_tipo_de_novedad SMALLINT NOT NULL,
    nombre_tipo_de_novedad VARCHAR NOT NULL,
    PRIMARY KEY(id_tipo_de_novedad)
);

CREATE TABLE tab_novedades(
    id_novedad INTEGER NOT NULL,
    id_tipo_de_novedad SMALLINT NOT NULL,
    id_dispositivo_genera_novedad SMALLINT NOT NULL,
    id_viaje SMALLINT NOT NULL,
    hora_novedad TIME NOT NULL,
    PRIMARY KEY(id_novedad),
    FOREIGN KEY(id_tipo_de_novedad) REFERENCES tab_tipos_de_novedades(id_tipo_de_novedad),
    FOREIGN KEY(id_dispositivo_genera_novedad) REFERENCES tab_dispositivos(id_dispositivo),
    FOREIGN KEY(id_viaje) REFERENCES tab_viajes(id_viaje)
);

CREATE TABLE tab_tipos_de_alarmas(
    id_tipo_de_alarma SMALLINT NOT NULL,
    nombre_tipo_de_alarma VARCHAR NOT NULL,
    PRIMARY KEY(id_tipo_de_alarma)
);

CREATE TABLE tab_alarmas(
    id_alarma SMALLINT NOT NULL,
    id_tipo_de_alarma SMALLINT NOT NULL,
    id_viaje SMALLINT NOT NULL,
    hora_alarma TIME NOT NULL,
    fecha_alarma DATE NOT NULL,
    PRIMARY KEY(id_alarma),
    FOREIGN KEY(id_tipo_de_alarma) REFERENCES tab_tipos_de_alarmas(id_tipo_de_alarma),
    FOREIGN KEY(id_viaje) REFERENCES tab_viajes(id_viaje)
);

CREATE TABLE tab_tipos_de_siniestros(
    id_tipo_de_siniestro SMALLINT NOT NULL,
    nombre_tipo_de_siniestro VARCHAR NOT NULL,
    PRIMARY KEY(id_tipo_de_siniestro)
);

CREATE TABLE tab_siniestros(
    id_siniestro SMALLINT NOT NULL,
    id_tipo_de_siniestro SMALLINT NOT NULL,
    id_viaje SMALLINT NOT NULL,
    hora_de_siniestro TIME NOT NULL,
    fecha_de_siniestro DATE NOT NULL,
    id_zona_siniestro SMALLINT NOT NULL,
    id_via_siniestro SMALLINT NOT NULL,
    PRIMARY KEY(id_siniestro),
    FOREIGN KEY(id_tipo_de_siniestro) REFERENCES tab_tipos_de_siniestros(id_tipo_de_siniestro),
    FOREIGN KEY(id_viaje) REFERENCES tab_manifiestos_de_viajes_inicial(id_viaje),
    FOREIGN KEY(id_zona_siniestro) REFERENCES tab_zonas(id_zona),
    FOREIGN KEY(id_via_siniestro) REFERENCES tab_vias(id_via)
);

CREATE TABLE tab_manifiestos_de_viajes_final(
    id_manifiesto_de_viaje_final SMALLINT NOT NULL,
    id_manifiesto_de_viaje_inicial SMALLINT NOT NULL,
    id_alarma SMALLINT NOT NULL,
    id_novedad SMALLINT NOT NULL,
    id_siniestro SMALLINT NOT NULL,
    PRIMARY KEY(id_manifiesto_de_viaje_final),
    FOREIGN KEY(id_manifiesto_de_viaje_final) REFERENCES tab_manifiestos_de_viajes_inicial(id_manifiesto_de_viaje_inicial),
    FOREIGN KEY(id_alarma) REFERENCES tab_alarmas(id_alarma),
    FOREIGN KEY(id_novedad) REFERENCES tab_novedades(id_novedad),
    FOREIGN KEY(id_siniestro) REFERENCES tab_siniestros(id_siniestro)
);