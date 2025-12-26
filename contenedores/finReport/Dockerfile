# ============================================
# Dockerfile - PostgreSQL 18 
# ============================================
FROM postgres:18

# Copiar configuración y scripts
COPY ./conf/postgresql.conf /etc/postgresql/postgresql.conf
COPY ./init.sql /docker-entrypoint-initdb.d/init.sql
COPY ./interfaces /docker-entrypoint-initdb.d/interfaces
COPY ./tablas_internas /docker-entrypoint-initdb.d/tablas_internas
COPY ./data /docker-entrypoint-initdb.d/data
COPY ./logss /docker-entrypoint-initdb.d/logss
COPY ./procesos /docker-entrypoint-initdb.d/procesos
COPY ./reportes /docker-entrypoint-initdb.d/reportes
COPY ./validadores /docker-entrypoint-initdb.d/validadores

RUN chown -R postgres:postgres /etc/postgresql && \
    chmod 640 /etc/postgresql/postgresql.conf

EXPOSE 5432

CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
