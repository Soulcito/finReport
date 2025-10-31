#!/bin/bash
set -e

# ==========================================
# CONFIGURACIÓN
# ==========================================
IMAGE_NAME="finreport"
CONTAINER_NAME="finreport"
PORT_HOST=25433

POSTGRES_DB="finreport_db"
POSTGRES_USER="finreport_user"
POSTGRES_PASSWORD="Finr3p0rt@2025"

DATA_DIR="$(pwd)/pgdata"

# ==========================================
# CREAR DIRECTORIOS SI NO EXISTEN
# ==========================================
if [ ! -d "$DATA_DIR" ]; then
  echo "Creando directorio de datos..."
  mkdir -p "$DATA_DIR"
fi

# ==========================================
# VERIFICAR IMAGEN
# ==========================================
if docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  echo " Imagen $IMAGE_NAME encontrada."
  read -p "¿Deseas reconstruir la imagen? (s/n): " REBUILD
  if [[ "$REBUILD" == "s" || "$REBUILD" == "S" ]]; then
    echo "Eliminando imagen existente..."
    docker rmi -f "$IMAGE_NAME"
    echo "Reconstruyendo imagen..."
    docker build -t "$IMAGE_NAME" .
  else
    echo "Manteniendo imagen existente."
  fi
else
  echo "Imagen no encontrada. Construyendo nueva..."
  docker build -t "$IMAGE_NAME" .
fi

# ==========================================
# VERIFICAR CONTENEDOR EXISTENTE
# ==========================================
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}$"; then
  echo "Contenedor $CONTAINER_NAME encontrado."
  echo "Deteniendo y eliminando contenedor previo..."
  docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
  docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
fi

# ==========================================
# CREAR NUEVO CONTENEDOR
# ==========================================
echo "================================"
echo "Iniciando nuevo contenedor"
echo "================================"

docker run -d \
  --name "$CONTAINER_NAME" \
  -e POSTGRES_DB="$POSTGRES_DB" \
  -e POSTGRES_USER="$POSTGRES_USER" \
  -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  -p "$PORT_HOST":5432 \
  -v "$DATA_DIR":/var/lib/postgresql/data \
  "$IMAGE_NAME"

if [ $? -ne 0 ]; then
  echo "Error al iniciar el contenedor."
  exit 1
fi

echo "================================"
echo "Contenedor PostgreSQL listo"
echo "================================"
docker ps | grep "$CONTAINER_NAME"
