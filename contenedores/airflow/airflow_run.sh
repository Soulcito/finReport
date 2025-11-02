#!/bin/bash
set -e

# ==========================================
# CONFIGURACIÓN
# ==========================================
IMAGE_NAME="airflow-3.1.0"
CONTAINER_NAME="airflow"
PORT_HOST=8181
SERVER_HOST="localhost"

# Directorios locales para persistencia
DAGS_DIR="$(pwd)/dags"
LOGS_DIR="$(pwd)/logs"
PLUGINS_DIR="$(pwd)/plugins"

# Directorios para finReport
FINREPORT_DIR="$(pwd)/finReport"
INTERFACE="$FINREPORT_DIR/interface"
REPORTS="$FINREPORT_DIR/reports"
LOGS_FINREPORT="$FINREPORT_DIR/logs"
MANTENEDORES="$FINREPORT_DIR/mantenedores"

# ==========================================
# CREAR DIRECTORIOS SI NO EXISTEN
# ==========================================
echo "Verificando estructura de directorios..."
mkdir -p "$DAGS_DIR" "$LOGS_DIR" "$PLUGINS_DIR" \
         "$INTERFACE" "$REPORTS" "$LOGS_FINREPORT" "$MANTENEDORES"

# ==========================================
# MOVER CONTENIDO DE ./mantenedores → ./finReport/mantenedores
# ==========================================
if [ -d "$(pwd)/mantenedores" ]; then
  echo "Moviendo contenido desde ./mantenedores hacia $MANTENEDORES..."
  cp -r "$(pwd)/mantenedores/"* "$MANTENEDORES/" 2>/dev/null || true
  echo "Eliminando carpeta raíz ./mantenedores..."
  rm -rf "$(pwd)/mantenedores"
fi

# ==========================================
# VERIFICAR IMAGEN
# ==========================================
if docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  echo "Imagen $IMAGE_NAME encontrada."
  read -p "¿Deseas reconstruir la imagen desde el Dockerfile y reiniciar el contenedor? (s/N): " REBUILD
  if [[ "$REBUILD" == "s" || "$REBUILD" == "S" ]]; then
    REBUILD_IMAGE=1
  else
    REBUILD_IMAGE=0
    echo "Manteniendo imagen existente."
  fi
else
  echo "Imagen no encontrada. Construyendo nueva..."
  docker build -t "$IMAGE_NAME" .
  REBUILD_IMAGE=0
fi

# ==========================================
# SI SE DEBE RECREAR LA IMAGEN
# ==========================================
if [ "$REBUILD_IMAGE" -eq 1 ] 2>/dev/null; then
  echo "Verificando contenedor existente..."
  if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}$"; then
    echo "Deteniendo y eliminando contenedor previo..."
    docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
    docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
  fi
  echo "Reconstruyendo imagen..."
  docker build -t "$IMAGE_NAME" .
fi

# ==========================================
# VERIFICAR SI EXISTE CONTENEDOR
# ==========================================
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}$"; then
  if docker ps --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}$"; then
    echo "El contenedor $CONTAINER_NAME está corriendo."
    read -p "¿Deseas reiniciarlo? (s/N): " RESTART
    if [[ "$RESTART" == "s" || "$RESTART" == "S" ]]; then
      docker restart "$CONTAINER_NAME"
    else
      echo "No se reiniciará el contenedor."
    fi
  else
    echo "El contenedor existe pero está detenido."
    read -p "¿Deseas iniciarlo? (s/N): " STARTIT
    if [[ "$STARTIT" == "s" || "$STARTIT" == "S" ]]; then
      docker start "$CONTAINER_NAME"
    else
      echo "No se iniciará el contenedor."
    fi
  fi
else
  echo "Creando nuevo contenedor con persistencia..."
  docker run -d \
    --name "$CONTAINER_NAME" \
    -p "$PORT_HOST":8080 \
    -v "$DAGS_DIR":/opt/airflow/dags \
    -v "$LOGS_DIR":/opt/airflow/logs \
    -v "$PLUGINS_DIR":/opt/airflow/plugins \
    -v "$INTERFACE":/opt/airflow/finReport/interface \
    -v "$REPORTS":/opt/airflow/finReport/reports \
    -v "$LOGS_FINREPORT":/opt/airflow/finReport/logs \
    -v "$MANTENEDORES":/opt/airflow/finReport/mantenedores \
    "$IMAGE_NAME"
fi

echo
echo "Airflow disponible en: http://$SERVER_HOST:$PORT_HOST"
