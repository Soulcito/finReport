# Imagen base oficial de Airflow 3.1.0
FROM apache/airflow:3.1.0-python3.12

# ==========================================
# CONFIGURACIÓN DE ENTORNO
# ==========================================

ENV AIRFLOW_HOME=/opt/airflow \
    AIRFLOW__CORE__LOAD_EXAMPLES=False \
    AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=True \
    AIRFLOW__CORE__LOAD_DEFAULT_CONNECTIONS=False \
    AIRFLOW__CORE__EXECUTOR=LocalExecutor

# ==========================================
# CONFIGURACIÓN DE ZONA HORARIA (CHILE)
# ==========================================

ENV TZ=America/Santiago
USER root
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# ==========================================
# INSTALACIÓN DE UTILIDADES DEL SISTEMA
# ==========================================

RUN apt-get update && apt-get install -y --no-install-recommends \
        vim nano curl netcat-openbsd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ==========================================
# ESTRUCTURA Y PERMISOS
# ==========================================
RUN mkdir -p ${AIRFLOW_HOME}/dags ${AIRFLOW_HOME}/logs ${AIRFLOW_HOME}/plugins \
    && chown -R airflow: ${AIRFLOW_HOME}

# ==========================================
# DEPENDENCIAS PYTHON
# ==========================================
COPY requirements.txt ${AIRFLOW_HOME}/requirements.txt
USER airflow
RUN pip install --no-cache-dir --upgrade pip \
    && if [ -f "${AIRFLOW_HOME}/requirements.txt" ]; then \
         pip install --no-cache-dir -r ${AIRFLOW_HOME}/requirements.txt; \
       fi

# ==========================================
# INICIALIZAR DB Y CREAR USUARIO ADMIN
# ==========================================

RUN airflow db migrate

# ==========================================
# COMANDO POR DEFECTO
# ==========================================
CMD ["bash", "-c", "airflow standalone"]
EXPOSE 8080
