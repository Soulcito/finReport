#!/bin/bash
set -e

# ==========================================
# CONFIGURACIÓN
# ==========================================
IMAGE_NAME="finreport"
CONTAINER_NAME="finreport"
PORT_HOST="25433"
SERVER_HOST="localhost"
NETWORK_NAME="finreport-net"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/pgdata"

# ==========================================
# CARGA DE VARIABLES DESDE postgres.env
# ==========================================
ENV_FILE="postgres.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: Archivo $ENV_FILE no encontrado"
  exit 1
fi

set -a
source "$ENV_FILE"
set +a


# ==========================================
# CREAR DIRECTORIOS SI NO EXISTEN
# ==========================================
if [ ! -d "$DATA_DIR" ]; then
    echo "Creando directorio de datos..."
    mkdir -p "$DATA_DIR"
fi

echo "==============================="
echo "  Verificando imagen: $IMAGE_NAME"
echo "==============================="

REBUILD_IMAGE=0

# Verificar si existe la imagen
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "Imagen no encontrada. Construyendo nueva..."
    docker build -t "$IMAGE_NAME" .
else
    echo "La imagen '$IMAGE_NAME' ya existe."
    read -p "¿Desea reconstruirla desde el Dockerfile y reiniciar el contenedor? (s/N): " recreate
    if [[ "${recreate,,}" == "s" ]]; then
        REBUILD_IMAGE=1
    else
        echo "Se mantiene la imagen existente."
    fi
fi

# ==========================================
# SI EL USUARIO QUIERE RECREAR, ELIMINAMOS EL CONTENEDOR
# ==========================================
if [ "$REBUILD_IMAGE" -eq 1 ]; then
    echo
    echo "Verificando si existe el contenedor $CONTAINER_NAME..."
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Deteniendo y eliminando contenedor anterior..."
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
    fi
    echo "Reconstruyendo imagen..."
    docker build -t "$IMAGE_NAME" .
fi

# ==========================================
# VERIFICAR RED DOCKER
# ==========================================
echo
echo "==============================="
echo "  Verificando red Docker: $NETWORK_NAME"
echo "==============================="
if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo "La red no existe. Creando red $NETWORK_NAME..."
    if docker network create "$NETWORK_NAME"; then
        echo "Red $NETWORK_NAME creada correctamente."
    else
        echo "Error al crear la red $NETWORK_NAME."
        exit 1
    fi
else
    echo "Red $NETWORK_NAME ya existe."
fi

# ==========================================
# VERIFICAR CONTENEDOR
# ==========================================
echo
echo "==============================="
echo "  Verificando contenedor: $CONTAINER_NAME"
echo "==============================="

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "El contenedor $CONTAINER_NAME está corriendo."
        read -p "¿Desea reiniciarlo? (s/N): " restart
        if [[ "${restart,,}" == "s" ]]; then
            echo "Reiniciando contenedor..."
            docker restart "$CONTAINER_NAME"
        else
            echo "No se reiniciará el contenedor."
        fi
    else
        echo "El contenedor existe pero está detenido."
        read -p "¿Desea iniciarlo? (s/N): " startit
        if [[ "${startit,,}" == "s" ]]; then
            docker start "$CONTAINER_NAME"
        else
            echo "No se iniciará el contenedor."
        fi
    fi
else
    echo "Creando nuevo contenedor con persistencia..."
    docker run -d \
        --name "$CONTAINER_NAME" \
        --network "$NETWORK_NAME" \
        -e POSTGRES_DB="$POSTGRES_DB" \
        -e POSTGRES_USER="$POSTGRES_USER" \
        -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
        -p "$PORT_HOST:5432" \
        -v "$DATA_DIR:/var/lib/postgresql" \
        "$IMAGE_NAME"
fi

echo
echo "==============================="
echo "Contenedor PostgreSQL listo"
echo "==============================="
docker ps | grep "$CONTAINER_NAME"

echo
read -p "Presione Enter para salir..."
