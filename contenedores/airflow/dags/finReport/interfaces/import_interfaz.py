from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator
from datetime import datetime
from psycopg2 import sql
from finReport.lib.db_logger import get_logger
from finReport.lib.db_config import PG_CONN
import pandas as pd
import psycopg2
import os
from psycopg2.extras import execute_values
from decimal import Decimal, InvalidOperation
import time

# ==============================
# CONFIGURACIÓN
# ==============================
INTERFACE_DIR = "/opt/airflow/finReport/interface"
dag_name = "import_interfaz"
proc_name = None
logger = get_logger(dag_name, proc_name, PG_CONN)
logger.info("Iniciando carga de interfaces")

# ==============================
# FUNCIONES AUXILIARES
# ==============================
def consulta_sql(schema, table, where=None, params=None):
    """Ejecuta SELECT y devuelve DataFrame."""
    full_name = f"{schema}.{table}"
    conn = None
    try:
        conn = psycopg2.connect(**PG_CONN)
        query = sql.SQL("SELECT * FROM {}.{}").format(
            sql.Identifier(schema),
            sql.Identifier(table)
        )
        if where:
            query += sql.SQL(" WHERE ") + sql.SQL(where)
        df = pd.read_sql(query.as_string(conn), conn, params=params)
        logger.info(f"Datos leídos de {full_name}")
        return df
    except Exception as e:
        logger.error(f"Error leyendo {full_name}: {e}")
        raise
    finally:
        if conn is not None:
            conn.close()
            
def safe_decimal(x, col):
    try:
        if pd.notnull(x):
            return Decimal(str(x)).quantize(Decimal("0.0001"))
        else:
            return Decimal("0.0000")
    except (InvalidOperation, ValueError) as e:
        logger.error(f"Error convirtiendo el campo '{col}' de tipo numeric con valor '{x}' a Decimal: {e}")
        return Decimal("0.0000")            
    
def safe_date(x, col):
    DEFAULT = datetime.strptime("19000101", "%Y%m%d").date()

    try:
        if x is None:
            return DEFAULT

        value = str(x).strip()

        if value == "" or value.lower() == "nan":
            return DEFAULT

        return datetime.strptime(value, "%Y%m%d").date()

    except Exception as e:
        logger.error(
            f"Error convirtiendo el campo '{col}' de tipo date con valor '{x}' a fecha: {e}"
        )
        return DEFAULT
def safe_string(x, col):
    try:
        if pd.isnull(x):
            return ""
        return str(x)
    except Exception as e:
        logger.error(f"Error convirtiendo el campo '{col}' de tipo string con valor '{x}' a string: {e}")
        return ""    

# ==============================
# FUNCIÓN PRINCIPAL
# ==============================
def load_interfaz():
    schema = "interno"
    schema_destino = "interface"
    tabla = "interfaz"
    tabla_rel = "interfaz_rel"
    logger.info(f"Buscando archivos .txt en {INTERFACE_DIR}")
    files = [f for f in os.listdir(INTERFACE_DIR) if f.lower().endswith('.txt')]

    if not files:
        logger.warning(f"No se encontraron archivos .txt en {INTERFACE_DIR}")
        return

    for file in files:
        start_time = time.time()
        file_path = os.path.join(INTERFACE_DIR, file)
        cod = os.path.basename(file_path)[:3]
        logger.info(f"Iniciando procesamiento de {file} (cod={cod})")

        try:
            # 1) Leer archivo
            try:
                df_txt = pd.read_csv(file_path, sep=";", encoding="utf-8", dtype=str)
                logger.info(f"Archivo leído correctamente ({len(df_txt)} filas)")
            except Exception as e:
                logger.error(f"Error leyendo archivo {file}: {e}")
                continue

            # 2) Obtener tabla destino
            try:
                df_interfaz = consulta_sql(schema, tabla, f"cod = '{cod}'")
                if df_interfaz.empty:
                    raise Exception(f"No existe configuración para cod={cod}")
                table_destino = df_interfaz.iloc[0][tabla]
                logger.info(f"Tabla destino: {table_destino}")
            except Exception as e:
                logger.error(f"Error consultando {schema}.{tabla}: {e}")
                continue

            # 3) Obtener estructura
            try:
                df_campos = consulta_sql(schema, tabla_rel, f"cod = '{cod}'")
                if df_campos.empty:
                    raise Exception(f"No hay campos definidos en {schema}.{tabla_rel} para cod={cod}")
                columnas = df_campos["campo"].tolist()
                tipos = df_campos["tipo_dato"].tolist()
                logger.info(f"Campos definidos: {len(columnas)}")
            except Exception as e:
                logger.error(f"Error consultando {schema}.{tabla_rel}: {e}")
                continue

            # 4) Validar columnas
            if len(df_txt.columns) != len(columnas):
                logger.error(f"Columnas no coinciden para {file} (archivo={len(df_txt.columns)}, definición={len(columnas)})")
                continue

            # 5) Conversión de tipos
            try:
                df_txt.columns = columnas
                for col, tipo in zip(columnas, tipos):
                    if tipo == "numeric":
                        df_txt[col] = df_txt[col].apply(lambda x: safe_decimal(x, col))                            

                    elif tipo == "date":
                        df_txt[col] = df_txt[col].apply(lambda x: safe_date(x, col))
                    else:
                        df_txt[col] = df_txt[col].apply(lambda x: safe_string(x, col))
                logger.info(f"Tipos aplicados: {dict(zip(columnas, tipos))}")
            except Exception as e:
                logger.error(f"Error convirtiendo tipos en {file}: {e}")
                continue

            # 6) Inserción en tabla destino
            conn = None
            try:                
                conn = psycopg2.connect(**PG_CONN)
                cur = conn.cursor()
                insert_query = sql.SQL("INSERT INTO {}.{} ({}) VALUES %s").format(
                    sql.Identifier(schema_destino),
                    sql.Identifier(table_destino),
                    sql.SQL(", ").join(map(sql.Identifier, columnas))
                )
                values = [tuple(row) for row in df_txt.itertuples(index=False, name=None)]
                execute_values(cur, insert_query.as_string(conn), values)
                conn.commit()

                logger.info(f"{len(values)} filas insertadas en {schema_destino}.{table_destino}")
            except Exception as e:
                if conn:
                    conn.rollback()
                logger.error(f"Error insertando en {schema_destino}.{table_destino}: {e}")
                continue
            finally:
                if conn:
                    conn.close()

            # 7) Fin exitoso
            duracion = round(time.time() - start_time, 2)
            logger.info(f"Finalizado archivo {file} en {duracion} segundos")

        except Exception as e:
            logger.error(f"Error inesperado procesando {file}: {e}")
            continue

# ==============================
# DAG
# ==============================
with DAG(
    dag_id=dag_name,
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False,
    tags=["import", "interfaz"],
) as dag:

    import_task = PythonOperator(
        task_id=dag_name,
        python_callable=load_interfaz
    )

    import_task
