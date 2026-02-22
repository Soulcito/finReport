-- =================================================
-- init.sql - Script orquestador de inicialización
-- =================================================

-- Ejecutar scripts de la carpeta interfaces
\echo '=== Ejecutando scripts de INTERFACES ==='
\ir /docker-entrypoint-initdb.d/interfaces/1-schemas.sql
\ir /docker-entrypoint-initdb.d/interfaces/2-cartera_operaciones.sql
\ir /docker-entrypoint-initdb.d/interfaces/3-cuadro_operaciones.sql
\ir /docker-entrypoint-initdb.d/interfaces/4-tipo_cambio.sql
\ir /docker-entrypoint-initdb.d/interfaces/5-cuadro_rectificaciones.sql
\ir /docker-entrypoint-initdb.d/interfaces/6-cartera_garantias.sql
\ir /docker-entrypoint-initdb.d/interfaces/7-variacion_stock.sql
\ir /docker-entrypoint-initdb.d/interfaces/8-registro_consentimientos.sql
\ir /docker-entrypoint-initdb.d/interfaces/9-acceso_consentimientos.sql

-- Ejecutar scripts de la carpeta tablas_internas
\echo '=== Ejecutando scripts de TABLAS INTERNAS ==='
\ir /docker-entrypoint-initdb.d/tablas_internas/1-schemas.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/2-tipo_persona.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/3-operacion_titulo.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/4-tipo_deudor.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/5-tabla_banco_126.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/6-interfaz_manager.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/7-parametros_generales.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/8-tipo_flujo.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/9-exclusion_morosidad.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/10-calendario_rdc20.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/11-diccionario_validador.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/12-medio_consentimiento.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/13-finalidad_consentimiento.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/14-objetivo_consentimiento.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/15-feriados.sql


-- Ejecutar scripts de la carpeta logs
\echo '=== Ejecutando scripts de LOGS ==='
\ir /docker-entrypoint-initdb.d/logss/1-log_eventos.sql

-- Ejecutar scripts de la carpeta procesos
\echo '=== Ejecutando scripts de PROCESOS ==='
\ir /docker-entrypoint-initdb.d/procesos/1-schema.sql
\ir /docker-entrypoint-initdb.d/procesos/2-proceso.val_interfaz_a01.sql
\ir /docker-entrypoint-initdb.d/procesos/3-proceso.val_interfaz_b01.sql
\ir /docker-entrypoint-initdb.d/procesos/4-proceso.trunca_tablas.sql
\ir /docker-entrypoint-initdb.d/procesos/5-proceso.val_interfaz_c01.sql
\ir /docker-entrypoint-initdb.d/procesos/6-proceso.val_interfaz_e01.sql
\ir /docker-entrypoint-initdb.d/procesos/7-proceso.genera_hist_log.sql
\ir /docker-entrypoint-initdb.d/procesos/8-proceso.excluir_por_morosidad.sql
\ir /docker-entrypoint-initdb.d/procesos/9-proceso.calculo_calendario_rdc20.sql
\ir /docker-entrypoint-initdb.d/procesos/10-proceso.genera_hist_interface.sql
\ir /docker-entrypoint-initdb.d/procesos/11-proceso.trunca_tablas_validador.sql


-- Ejecutar scripts de la carpeta reportes
\echo '=== Ejecutando scripts de REPORTES ==='
\ir /docker-entrypoint-initdb.d/reportes/1-schema.sql
\ir /docker-entrypoint-initdb.d/reportes/2-rdc01.sql
\ir /docker-entrypoint-initdb.d/reportes/3-proceso.genera_rdc01.sql
\ir /docker-entrypoint-initdb.d/reportes/4-rdc20.sql
\ir /docker-entrypoint-initdb.d/reportes/5-proceso.genera_rdc20.sql
\ir /docker-entrypoint-initdb.d/reportes/6-rdc22.sql
\ir /docker-entrypoint-initdb.d/reportes/7-proceso.genera_rdc22.sql
\ir /docker-entrypoint-initdb.d/reportes/8-rdc30.sql
\ir /docker-entrypoint-initdb.d/reportes/9-proceso.genera_rdc30.sql
\ir /docker-entrypoint-initdb.d/reportes/10-rdc31.sql
\ir /docker-entrypoint-initdb.d/reportes/11-proceso.genera_rdc31.sql


-- Ejecutar scripts de la carpeta validadores
\echo '=== Ejecutando scripts de VALIDADORES ==='
\ir /docker-entrypoint-initdb.d/validadores/1-schema.sql
\ir /docker-entrypoint-initdb.d/validadores/2-rdc01.sql
\ir /docker-entrypoint-initdb.d/validadores/3-proceso.val_num_1.sql
\ir /docker-entrypoint-initdb.d/validadores/4-proceso.val_num_2.sql
\ir /docker-entrypoint-initdb.d/validadores/5-proceso.val_num_3.sql
\ir /docker-entrypoint-initdb.d/validadores/6-proceso.val_num_4.sql
\ir /docker-entrypoint-initdb.d/validadores/7-proceso.val_codigo_tabla.sql
\ir /docker-entrypoint-initdb.d/validadores/8-proceso.val_num_9.sql
\ir /docker-entrypoint-initdb.d/validadores/9-proceso.val_num_10.sql
\ir /docker-entrypoint-initdb.d/validadores/10-proceso.val_num_11.sql
\ir /docker-entrypoint-initdb.d/validadores/11-proceso.val_en_dominio.sql
\ir /docker-entrypoint-initdb.d/validadores/12-proceso.val_reporte_rdc01.sql
\ir /docker-entrypoint-initdb.d/validadores/13-rdc20.sql
\ir /docker-entrypoint-initdb.d/validadores/14-proceso.val_reporte_rdc20.sql
\ir /docker-entrypoint-initdb.d/validadores/15-proceso.val_num_16.sql
\ir /docker-entrypoint-initdb.d/validadores/16-rdc22.sql
\ir /docker-entrypoint-initdb.d/validadores/17-proceso.val_reporte_rdc22.sql


\echo '=== Inicialización completada ==='
