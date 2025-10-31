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

-- Ejecutar scripts de la carpeta data
\echo '=== Ejecutando scripts de DATA ==='
\ir /docker-entrypoint-initdb.d/data/1-tipo_persona.sql
\ir /docker-entrypoint-initdb.d/data/2-operacion_titulo.sql
\ir /docker-entrypoint-initdb.d/data/3-tipo_deudor.sql
\ir /docker-entrypoint-initdb.d/data/4-tabla_banco_126.sql

\echo '=== Inicialización completada ==='
