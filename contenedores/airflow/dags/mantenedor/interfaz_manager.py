from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator
from datetime import datetime
import os
import pandas as pd
import psycopg2

# ==============================
# CONFIGURACIÓN
# ==============================
EXCEL_DIR = "/opt/airflow/finReport/mantenedores"  # Carpeta donde estarán los excels
PG_CONN = {
    "host": "finreport",
    "port": "25433",
    "dbname": "finreport_db",
    "user": "finreport_user",
    "password": "Finr3p0rt@2025"
}

# ==============================
# FUNCIONES
# ==============================
def load_excel_to_postgres():
    # Buscar archivos Excel en el directorio
    files = [f for f in os.listdir(EXCEL_DIR) if f.endswith('.xlsx')]
    if not files:
        raise Exception(f"No se encontraron archivos .xlsx en {EXCEL_DIR}")

    for file in files:
        file_path = os.path.join(EXCEL_DIR, file)
        table_name = os.path.splitext(file)[0]  # nombre del archivo sin extensión

        print(f"Procesando archivo: {file_path} -> Tabla destino: {table_name}")

        # Leer Excel
        df = pd.read_excel(file_path)

        # Conectar a PostgreSQL
        conn = psycopg2.connect(**PG_CONN)
        cur = conn.cursor()

        # Borrar contenido existente
        cur.execute(f"TRUNCATE TABLE {table_name} RESTART IDENTITY;")
        conn.commit()

        # Cargar datos
        cols = ",".join(df.columns)
        values = [tuple(x) for x in df.to_numpy()]
        placeholders = ",".join(["%s"] * len(df.columns))
        insert_query = f"INSERT INTO {table_name} ({cols}) VALUES ({placeholders})"

        for row in values:
            cur.execute(insert_query, row)

        conn.commit()
        cur.close()
        conn.close()

        print(f"✅ Archivo {file} cargado correctamente en {table_name}")

# ==============================
# DAG
# ==============================
with DAG(
    dag_id="excel_to_postgres_dag",
    start_date=datetime(2025, 10, 31),
    schedule=None,
    catchup=False,
    tags=["import", "postgres", "excel"]
) as dag:

    import_task = PythonOperator(
        task_id="load_excel_to_postgres",
        python_callable=load_excel_to_postgres
    )

    import_task
