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

-- Ejecutar scripts de la carpeta tablas_internas
\echo '=== Ejecutando scripts de TABLAS INTERNAS ==='
\ir /docker-entrypoint-initdb.d/tablas_internas/1-schemas.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/2-tipo_persona.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/3-operacion_titulo.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/4-tipo_deudor.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/5-tabla_banco_126.sql
\ir /docker-entrypoint-initdb.d/tablas_internas/6-interfaz_manager.sql

-- Ejecutar scripts de la carpeta logs
\echo '=== Ejecutando scripts de LOGS ==='
\ir /docker-entrypoint-initdb.d/logss/1-log_eventos.sql

-- Ejecutar scripts de la carpeta procesos
\echo '=== Ejecutando scripts de PROCESOS ==='
\ir /docker-entrypoint-initdb.d/procesos/1-schema.sql
\ir /docker-entrypoint-initdb.d/procesos/2-proceso.val_interfaz_A01.sql
\ir /docker-entrypoint-initdb.d/procesos/3-proceso.val_interfaz_B01.sql


\echo '=== Inicialización completada ==='
