from airflow.utils.task_group import TaskGroup
from airflow.providers.standard.operators.python import PythonOperator
from psycopg2 import sql
from finReport.lib.db_logger import get_logger
from finReport.lib.db_config import PG_CONN
from datetime import datetime
import pandas as pd
import psycopg2
import os

# ==============================
# CONFIGURACIÓN
# ==============================

GROUP_NAME = "import_mantenedores"
EXCEL_DIR = "/opt/airflow/finReport/mantenedores"

# ==============================
# CONFIGURACIÓN DE LOGGING
# ==============================

logger = get_logger(GROUP_NAME, "", PG_CONN)
logger.info("Iniciando carga de mantenedores")

# ==============================
# FUNCIONES PRINCIPALES
# ==============================

def load_excel_with_relations(**context):
    logger.info(f"Buscando archivos .xlsx en {EXCEL_DIR}")
    files = [f for f in os.listdir(EXCEL_DIR) if f.lower().endswith('.xlsx')]
    if not files:
        raise Exception(f"No se encontraron archivos .xlsx en {EXCEL_DIR}")

    for file in files:
        file_path = os.path.join(EXCEL_DIR, file)
        logger.info(f"Procesando archivo: {file_path}")

        xls = pd.ExcelFile(file_path)
        sheet_names = xls.sheet_names
        logger.info(f"Hojas encontradas: {sheet_names}")

        conn = psycopg2.connect(**PG_CONN)
        cur = conn.cursor()

        try:
            logger.info("Iniciando fase de borrado de datos")
            for sheet in reversed(sheet_names):
                process_sheet(xls, sheet, cur, conn, delete_only=True)

            logger.info("Iniciando fase de inserción de datos")
            for sheet in sheet_names:
                process_sheet(xls, sheet, cur, conn, delete_only=False)

        except Exception as e:
            logger.error(f"Error procesando {file}: {e}")
            raise

        finally:
            cur.close()
            conn.close()


def process_sheet(xls, sheet_name, cur, conn, delete_only=False):
    schema, table = "interno", sheet_name.strip()
    full_name = f"{schema}.{table}"
    logger.info(f"Procesando hoja: {full_name} (delete_only={delete_only})")

    # Validar existencia tabla
    cur.execute("SELECT to_regclass(%s)", (f'"{schema}"."{table}"',))
    if cur.fetchone()[0] is None:
        logger.warning(f"La tabla {full_name} no existe en la base de datos. Se omite.")
        return

    # Borrado
    if delete_only:
        cur.execute(sql.SQL("DELETE FROM {}.{}").format(
            sql.Identifier(schema),
            sql.Identifier(table)
        ))
        conn.commit()
        logger.info(f"Datos eliminados de {full_name}")
        return

    # Inserción
    df = pd.read_excel(xls, sheet_name=sheet_name, dtype=str).fillna("")
    cols = [sql.Identifier(c.strip()) for c in df.columns]

    insert_query = sql.SQL("INSERT INTO {}.{} ({}) VALUES ({})").format(
        sql.Identifier(schema),
        sql.Identifier(table),
        sql.SQL(", ").join(cols),
        sql.SQL(", ").join(sql.Placeholder() * len(df.columns))
    )

    cur.executemany(insert_query, df.itertuples(index=False, name=None))
    conn.commit()
    logger.info(f"{len(df)} registros insertados en {full_name}")


# ==============================
# TASK GROUP BUILDER
# ==============================

def build_group(dag):
    """
    Construye el TaskGroup con la lógica de importación de mantenedores.
    """

    with TaskGroup(group_id=GROUP_NAME, dag=dag) as group:

        PythonOperator(
            task_id="run_import_mantenedores",
            python_callable=load_excel_with_relations
        )

    return group
