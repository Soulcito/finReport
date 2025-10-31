#!/bin/bash

# ================================
# CONFIGURACIÓN
# ================================
IMAGE_NAME="airflow-3.1.0"
CONTAINER_NAME="airflow"
PORT_HOST="8181"
SERVER_HOST="localhost"

# Directorios locales para persistencia
DAGS_DIR="$(pwd)/dags"
LOGS_DIR="$(pwd)/logs"
PLUGINS_DIR="$(pwd)/plugins"

# ================================
# CREAR DIRECTORIOS SI NO EXISTEN
# ================================
mkdir -p "$DAGS_DIR" "$LOGS_DIR" "$PLUGINS_DIR"

echo "================================"
echo "  Verificando imagen: $IMAGE_NAME"
echo "================================"

REBUILD_IMAGE=0

# Verificar si la imagen existe
if docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "La imagen '$IMAGE_NAME' ya existe."
    read -p "¿Desea reconstruirla desde el Dockerfile y reiniciar el contenedor? (s/N): " recreate
    recreate=${recreate:-N}
    if [[ "$recreate" =~ ^[sS]$ ]]; then
        REBUILD_IMAGE=1
    else
        echo "Se mantiene la imagen existente."
    fi
else
    echo "Imagen no encontrada. Construyendo nueva..."
    docker build -t "$IMAGE_NAME" .
fi

# ================================
# SI EL USUARIO QUIERE RECREAR, ELIMINAMOS EL CONTENEDOR
# ================================
if [[ $REBUILD_IMAGE -eq 1 ]]; then
    echo
    echo "Verificando si existe el contenedor $CONTAINER_NAME..."
    if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo "Deteniendo y eliminando contenedor anterior..."
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1
    fi
    echo "Reconstruyendo imagen..."
    docker build -t "$IMAGE_NAME" .
fi

echo
echo "================================"
echo "  Verificando contenedor: $CONTAINER_NAME"
echo "================================"

# Verificar si el contenedor existe
if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
    # Verificar si está corriendo
    if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo "El contenedor '$CONTAINER_NAME' está corriendo."
        read -p "¿Desea reiniciarlo? (s/N): " restart
        restart=${restart:-N}
        if [[ "$restart" =~ ^[sS]$ ]]; then
            echo "Reiniciando contenedor..."
            docker restart "$CONTAINER_NAME"
        else
            echo "No se reiniciará el contenedor."
        fi
    else
        echo "El contenedor existe pero está detenido."
        read -p "¿Desea iniciarlo? (s/N): " startit
        startit=${startit:-N}
        if [[ "$startit" =~ ^[sS]$ ]]; then
            docker start "$CONTAINER_NAME"
        else
            echo "No se iniciará el contenedor."
        fi
    fi
else
    echo "Creando nuevo contenedor con persistencia..."
    docker run -d --name "$CONTAINER_NAME" \
      -p "$PORT_HOST":8080 \
      -v "$DAGS_DIR":/opt/airflow/dags \
      -v "$LOGS_DIR":/opt/airflow/logs \
      -v "$PLUGINS_DIR":/opt/airflow/plugins \
      "$IMAGE_NAME"
fi

echo
echo "Airflow disponible en: http://$SERVER_HOST:$PORT_HOST"
