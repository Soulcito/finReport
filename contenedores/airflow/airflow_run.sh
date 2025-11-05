#!/bin/bash
set -e

cd "$(dirname "$0")"

# ================================
# CONFIGURACIÓN
# ================================
IMAGE_NAME="airflow-3.1.0"
CONTAINER_NAME="airflow"
PORT_HOST=8181
SERVER_HOST="localhost"
NETWORK_NAME="finreport-net"

# Directorios locales para persistencia de Airflow
DAGS_DIR="$(pwd)/dags"
LOGS_DIR="$(pwd)/logs"
PLUGINS_DIR="$(pwd)/plugins"

# Directorios locales para finReport
FINREPORT_DIR="$(pwd)/finReport"
INTERFACE="$FINREPORT_DIR/interface"
REPORTS="$FINREPORT_DIR/reports"
LOGS_FINREPORT="$FINREPORT_DIR/logs"
MANTENEDORES="$FINREPORT_DIR/mantenedores"

# ================================
# CREAR DIRECTORIOS SI NO EXISTEN
# ================================
mkdir -p "$DAGS_DIR" "$LOGS_DIR" "$PLUGINS_DIR" \
         "$INTERFACE" "$REPORTS" "$LOGS_FINREPORT" "$MANTENEDORES"

# ================================
# MOVER CONTENIDO DE ./mantenedores → ./finReport/mantenedores
# ================================
if [ -d "$(pwd)/mantenedores" ]; then
  echo "Moviendo contenido desde ./mantenedores hacia $MANTENEDORES..."
  cp -r "$(pwd)/mantenedores/"* "$MANTENEDORES/" 2>/dev/null || true
  echo "Eliminando carpeta raíz ./mantenedores..."
  rm -rf "$(pwd)/mantenedores"
fi

# ================================
# VERIFICAR / CREAR RED
# ================================
echo "==============================="
echo "  Verificando red Docker: $NETWORK_NAME"
echo "==============================="
if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
  echo "La red no existe. Creando red $NETWORK_NAME..."
  docker network create "$NETWORK_NAME"
else
  echo "Red $NETWORK_NAME ya existe."
fi

# ================================
# VERIFICAR IMAGEN
# ================================
if docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  echo "Imagen $IMAGE_NAME encontrada."
  read -p "¿Deseas reconstruir la imagen? (s/N): " REBUILD
  if [[ "$REBUILD" =~ ^[sS]$ ]]; then
    docker build -t "$IMAGE_NAME" .
  else
    echo "Manteniendo imagen existente."
  fi
else
  echo "Imagen no encontrada. Construyendo nueva..."
  docker build -t "$IMAGE_NAME" .
fi

# ================================
# RECREAR CONTENEDOR SI EXISTE
# ================================
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}$"; then
  echo "Contenedor $CONTAINER_NAME encontrado."
  echo "Deteniendo y eliminando contenedor previo..."
  docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
  docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
fi

# ================================
# CREAR CONTENEDOR NUEVO
# ================================
echo "================================"
echo "Iniciando nuevo contenedor"
echo "================================"
docker run -d \
  --name "$CONTAINER_NAME" \
  --network "$NETWORK_NAME" \
  -p "$PORT_HOST":8080 \
  -v "$DAGS_DIR":/opt/airflow/dags \
  -v "$LOGS_DIR":/opt/airflow/logs \
  -v "$PLUGINS_DIR":/opt/airflow/plugins \
  -v "$INTERFACE":/opt/airflow/finReport/interface \
  -v "$REPORTS":/opt/airflow/finReport/reports \
  -v "$LOGS_FINREPORT":/opt/airflow/finReport/logs \
  -v "$MANTENEDORES":/opt/airflow/finReport/mantenedores \
  "$IMAGE_NAME"

echo
echo "Esperando a que Airflow inicialice..."
sleep 20

echo
echo "================================"
echo "Airflow disponible en: http://$SERVER_HOST:$PORT_HOST"
echo "================================"
echo "Para obtener las credenciales del usuario admin generado automáticamente:"
echo "  docker logs $CONTAINER_NAME | grep 'user'"
echo
