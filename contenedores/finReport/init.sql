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

-- Ejecutar scripts de la carpeta tablas_internas
\echo '=== Ejecutando scripts de TABLAS INTERNAS ==='
\ir /docker-entrypoint-initdb.d/tablas_internas/1-schemas.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/2-tipo_persona.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/3-operacion_titulo.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/4-tipo_deudor.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/5-tabla_banco_126.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/6-interfaz_manager.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/7-parametros_generales.sql

-- Ejecutar scripts de la carpeta logs
\echo '=== Ejecutando scripts de LOGS ==='
\ir /docker-entrypoint-initdb.d/logss/1-log_eventos.sql

-- Ejecutar scripts de la carpeta procesos
\echo '=== Ejecutando scripts de PROCESOS ==='
\ir /docker-entrypoint-initdb.d/procesos/1-schema.sql
\ir /docker-entrypoint-initdb.d/procesos/2-proceso.val_interfaz_a01.sql
\ir /docker-entrypoint-initdb.d/procesos/3-proceso.val_interfaz_b01.sql
\ir /docker-entrypoint-initdb.d/procesos/4-proceso.trunca_tablas.sql

-- Ejecutar scripts de la carpeta reportes
\echo '=== Ejecutando scripts de REPORTES ==='
\ir /docker-entrypoint-initdb.d/reportes/1-schema.sql
\ir /docker-entrypoint-initdb.d/reportes/2-rdc01.sql
\ir /docker-entrypoint-initdb.d/reportes/3-proceso.genera_rdc01.sql


\echo '=== Inicialización completada ==='
