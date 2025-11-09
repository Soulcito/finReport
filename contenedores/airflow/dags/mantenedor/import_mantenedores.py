from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator
from datetime import datetime
from psycopg2 import sql
import pandas as pd
import psycopg2
import os
import logging

# ==============================
# CONFIGURACIÓN
# ==============================
EXCEL_DIR = "/opt/airflow/finReport/mantenedores"
PG_CONN = {
    "host": "finreport",
    "port": "5432",
    "dbname": "finreport_db",
    "user": "finreport_user",
    "password": "Finr3p0rt@2025"
}

# ==============================
# HANDLER PERSONALIZADO
# ==============================
class PostgresLogHandler(logging.Handler):
    """Handler que guarda los logs en la tabla log_eventos de PostgreSQL."""
    def __init__(self, conn_params):
        super().__init__()
        self.conn_params = conn_params

    def emit(self, record):
        log_entry = self.format(record)
        conn = None
        try:
            conn = psycopg2.connect(**self.conn_params)
            cur = conn.cursor()
            cur.execute("""
                INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
                VALUES (%s, %s, %s, %s, %s)
            """, (datetime.now(), record.levelname, "import_mantenedores", "", log_entry))
            conn.commit()
            cur.close()
        except Exception as e:
            print(f"Error guardando log en PostgreSQL: {e}")
        finally:
            if conn:
                conn.close()

# ==============================
# CONFIGURACIÓN DE LOGGING
# ==============================
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

logger = logging.getLogger()
logger.setLevel(logging.INFO)

console_handler = logging.StreamHandler()
console_handler.setFormatter(formatter)
logger.addHandler(console_handler)

db_handler = PostgresLogHandler(PG_CONN)
db_handler.setFormatter(formatter)
logger.addHandler(db_handler)

# ==============================
# FUNCIONES PRINCIPALES
# ==============================
def load_excel_with_relations():
    logging.info(f"🔍 Buscando archivos .xlsx en {EXCEL_DIR}")
    files = [f for f in os.listdir(EXCEL_DIR) if f.endswith('.xlsx')]
    if not files:
        raise Exception(f"No se encontraron archivos .xlsx en {EXCEL_DIR}")

    for file in files:
        file_path = os.path.join(EXCEL_DIR, file)
        logging.info(f"📂 Procesando archivo: {file_path}")

        xls = pd.ExcelFile(file_path)
        sheet_names = xls.sheet_names
        logging.info(f"📄 Hojas encontradas: {sheet_names}")

        conn = psycopg2.connect(**PG_CONN)
        cur = conn.cursor()

        try:
            logging.info("🔁 Iniciando fase de borrado...")
            for sheet in reversed(sheet_names):
                process_sheet(xls, sheet, cur, conn, delete_only=True)

            logging.info("⬆️ Iniciando fase de inserción...")
            for sheet in sheet_names:
                process_sheet(xls, sheet, cur, conn, delete_only=False)

        except Exception as e:
            logging.error(f"❌ Error procesando {file}: {e}")
            raise

        finally:
            cur.close()
            conn.close()

def process_sheet(xls, sheet_name, cur, conn, delete_only=False):
    schema, table = "interno", sheet_name.strip()
    full_name = f"{schema}.{table}"
    logging.info(f"{'🗑️' if delete_only else '⬆️'} Procesando hoja: {full_name}")

    cur.execute("SELECT to_regclass(%s)", (f'"{schema}"."{table}"',))
    if cur.fetchone()[0] is None:
        logging.warning(f"⚠️ La tabla {full_name} no existe en la base de datos, se omite.")
        return    

    if delete_only:
        cur.execute(sql.SQL("DELETE FROM {}.{}").format(
            sql.Identifier(schema),
            sql.Identifier(table)
        ))
        conn.commit()
        logging.info(f"✅ Datos eliminados de {full_name}")
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
    logging.info(f"✅ {len(df)} registros insertados en {full_name}")

# ==============================
# DAG
# ==============================
with DAG(
    dag_id="import_mantenedores",
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False,
    tags=["mantenedor"],
) as dag:

    import_task = PythonOperator(
        task_id="import_mantenedores",
        python_callable=load_excel_with_relations
    )

    import_task
