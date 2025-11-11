from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator
from datetime import datetime
from psycopg2 import sql
from finReport.lib.db_logger import get_logger
from finReport.lib.db_config import PG_CONN
import pandas as pd
import psycopg2
import os

# ==============================
# CONFIGURACIÓN
# ==============================

EXCEL_DIR = "/opt/airflow/finReport/mantenedores"

# ==============================
# CONFIGURACIÓN DE LOGGING
# ==============================
dag_name = "import_mantenedores"
proc_name = None
logger = get_logger(dag_name, proc_name , PG_CONN)
logger.info("Iniciando carga de mantenedores")

# ==============================
# FUNCIONES PRINCIPALES
# ==============================
def load_excel_with_relations():
    logger.info(f"🔍 Buscando archivos .xlsx en {EXCEL_DIR}")
    files = [f for f in os.listdir(EXCEL_DIR) if f.lower().endswith('.xlsx')]
    if not files:
        raise Exception(f"No se encontraron archivos .xlsx en {EXCEL_DIR}")

    for file in files:
        file_path = os.path.join(EXCEL_DIR, file)
        logger.info(f"📂 Procesando archivo: {file_path}")

        xls = pd.ExcelFile(file_path)
        sheet_names = xls.sheet_names
        logger.info(f"📄 Hojas encontradas: {sheet_names}")

        conn = psycopg2.connect(**PG_CONN)
        cur = conn.cursor()

        try:
            logger.info("🔁 Iniciando fase de borrado...")
            for sheet in reversed(sheet_names):
                process_sheet(xls, sheet, cur, conn, delete_only=True)

            logger.info("⬆️ Iniciando fase de inserción...")
            for sheet in sheet_names:
                process_sheet(xls, sheet, cur, conn, delete_only=False)

        except Exception as e:
            logger.error(f"❌ Error procesando {file}: {e}")
            raise

        finally:
            cur.close()
            conn.close()

def process_sheet(xls, sheet_name, cur, conn, delete_only=False):
    schema, table = "interno", sheet_name.strip()
    full_name = f"{schema}.{table}"
    logger.info(f"{'🗑️' if delete_only else '⬆️'} Procesando hoja: {full_name}")

    cur.execute("SELECT to_regclass(%s)", (f'"{schema}"."{table}"',))
    if cur.fetchone()[0] is None:
        logger.warning(f"⚠️ La tabla {full_name} no existe en la base de datos, se omite.")
        return    

    if delete_only:
        cur.execute(sql.SQL("DELETE FROM {}.{}").format(
            sql.Identifier(schema),
            sql.Identifier(table)
        ))
        conn.commit()
        logger.info(f"✅ Datos eliminados de {full_name}")
        return

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
    logger.info(f"✅ {len(df)} registros insertados en {full_name}")

# ==============================
# DAG
# ==============================
with DAG(
    dag_id=dag_name,
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False,
    tags=["mantenedor"],
) as dag:

    import_task = PythonOperator(
        task_id=dag_name,
        python_callable=load_excel_with_relations
    )

    import_task
