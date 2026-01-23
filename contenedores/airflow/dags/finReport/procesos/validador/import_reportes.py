from airflow.utils.task_group import TaskGroup
from airflow.providers.standard.operators.python import PythonOperator
from psycopg2 import sql
from finReport.lib.db_logger import get_logger
from finReport.lib.db_config import PG_CONN
import psycopg2
import os

# ==============================
# CONFIGURACIÓN
# ==============================

GROUP_NAME = "import_validador_txt"
TXT_DIR = "/opt/airflow/finReport/validador"
SCHEMA = "validador"

# ==============================
# CONFIGURACIÓN DE LOGGING
# ==============================

logger = get_logger(GROUP_NAME, "", PG_CONN)
logger.info("Iniciando carga de archivos TXT para validador")

# ==============================
# FUNCIONES PRINCIPALES
# ==============================

def load_txt_files(**context):
    logger.info(f"Buscando archivos .txt en {TXT_DIR}")
    files = [f for f in os.listdir(TXT_DIR) if f.lower().endswith(".txt")]

    if not files:
        raise Exception(f"No se encontraron archivos .txt en {TXT_DIR}")

    conn = psycopg2.connect(**PG_CONN)
    cur = conn.cursor()

    try:
        for file in files:
            file_path = os.path.join(TXT_DIR, file)

            # Nombre de tabla
            base_name = file[:5].lower()
            table = f"{base_name}_texto"
            full_name = f"{SCHEMA}.{table}"

            logger.info(f"Procesando archivo {file} → tabla {full_name}")

            # Validar existencia de la tabla
            cur.execute(
                "SELECT to_regclass(%s)",
                (f'"{SCHEMA}"."{table}"',)
            )

            if cur.fetchone()[0] is None:
                logger.warning(f"La tabla {full_name} no existe. Se omite el archivo.")
                continue

            insert_query = sql.SQL("""
                INSERT INTO {}.{} (linea, registro)
                VALUES (%s, %s)
            """).format(
                sql.Identifier(SCHEMA),
                sql.Identifier(table)
            )

            with open(file_path, "r", encoding="utf-8") as f:
                data = [
                    (idx, line.rstrip("\n"))
                    for idx, line in enumerate(f, start=1)
                ]

            if data:
                cur.executemany(insert_query, data)
                conn.commit()
                logger.info(f"{len(data)} registros insertados en {full_name}")
            else:
                logger.warning(f"El archivo {file} está vacío")
                
                
            # Borrar reporte una vez importado
            try:
                logger.info(f"Intentando eliminar reporte: {file_path}")
                os.remove(file_path)
                logger.info(f"Reporte eliminado post-import: {file}")
            except Exception as e:
                logger.error(f"No se pudo eliminar el reporte {file}: {e}")                
                

    except Exception as e:
        conn.rollback()
        logger.error(f"Error procesando archivos TXT: {e}")
        raise

    finally:
        cur.close()
        conn.close()

# ==============================
# TASK GROUP BUILDER
# ==============================

def build_group(dag):
    """
    TaskGroup para importar archivos TXT al esquema validador.
    """

    with TaskGroup(group_id=GROUP_NAME, dag=dag) as group:

        PythonOperator(
            task_id="run_import_validador_txt",
            python_callable=load_txt_files
        )

    return group
