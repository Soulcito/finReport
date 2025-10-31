# Imagen base oficial de Airflow 3.1.0
FROM apache/airflow:3.1.0-python3.12

# Establecer variables de entorno principales
ENV AIRFLOW_HOME=/opt/airflow \
    AIRFLOW__CORE__LOAD_EXAMPLES=False \
    AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=True \
    AIRFLOW__CORE__LOAD_DEFAULT_CONNECTIONS=False \
    AIRFLOW__CORE__EXECUTOR=LocalExecutor

# Cambiar a root para instalar utilidades del sistema
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
        vim nano curl netcat-openbsd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Crear carpetas necesarias y asignar permisos
RUN mkdir -p ${AIRFLOW_HOME}/dags ${AIRFLOW_HOME}/logs ${AIRFLOW_HOME}/plugins \
    && chown -R airflow: ${AIRFLOW_HOME}

# Copiar dependencias Python (si tienes un requirements.txt)
COPY requirements.txt ${AIRFLOW_HOME}/requirements.txt

# Volver al usuario airflow
USER airflow

# Instalar dependencias adicionales de Python
RUN pip install --no-cache-dir --upgrade pip \
    && if [ -f "${AIRFLOW_HOME}/requirements.txt" ]; then \
         pip install --no-cache-dir -r ${AIRFLOW_HOME}/requirements.txt; \
       fi

# Comando por defecto: inicializa la DB y arranca el webserver + scheduler
CMD ["bash", "-c", "airflow db migrate && airflow standalone"]
EXPOSE 8080