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
from decimal import Decimal
import time

# ==============================
# CONFIGURACIÓN
# ==============================
INTERFACE_DIR = "/opt/airflow/finReport/interface"
logger = get_logger("import_interfaz", PG_CONN)
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
        logger.info(f"Datos leídos de {full_name}", extra={"procedimiento": full_name})
        return df
    except Exception as e:
        logger.error(f"Error leyendo {full_name}: {e}", extra={"procedimiento": full_name})
        raise
    finally:
        if conn is not None:
            conn.close()

# ==============================
# FUNCIÓN PRINCIPAL
# ==============================
def load_interfaz():
    logger.info(f"Buscando archivos .txt en {INTERFACE_DIR}")
    files = [f for f in os.listdir(INTERFACE_DIR) if f.lower().endswith('.txt')]

    if not files:
        logger.warning(f"No se encontraron archivos .txt en {INTERFACE_DIR}", extra={"procedimiento": "inicio"})
        return

    for file in files:
        start_time = time.time()
        file_path = os.path.join(INTERFACE_DIR, file)
        cod = os.path.basename(file_path)[:3]
        logger.info(f"Iniciando procesamiento de {file} (cod={cod})", extra={"procedimiento": "inicio"})

        try:
            # 1) Leer archivo
            try:
                df_txt = pd.read_csv(file_path, sep=";", encoding="utf-8")
                logger.info(f"Archivo leído correctamente ({len(df_txt)} filas)", extra={"procedimiento": "lectura"})
            except Exception as e:
                logger.error(f"Error leyendo archivo {file}: {e}", extra={"procedimiento": "lectura"})
                continue

            # 2) Obtener tabla destino
            try:
                df_interfaz = consulta_sql("interno", "interfaz", f"cod = '{cod}'")
                if df_interfaz.empty:
                    raise Exception(f"No existe configuración para cod={cod}")
                table_destino = df_interfaz.iloc[0]["interfaz"]
                logger.info(f"Tabla destino: {table_destino}", extra={"procedimiento": "consulta_interfaz"})
            except Exception as e:
                logger.error(f"Error consultando interno.interfaz: {e}", extra={"procedimiento": "consulta_interfaz"})
                continue

            # 3) Obtener estructura
            try:
                df_campos = consulta_sql("interno", "interfaz_rel", f"cod = '{cod}'")
                if df_campos.empty:
                    raise Exception(f"No hay campos definidos en interno.interfaz_rel para cod={cod}")
                columnas = df_campos["campo"].tolist()
                tipos = df_campos["tipo_dato"].tolist()
                logger.info(f"Campos definidos: {len(columnas)}", extra={"procedimiento": "consulta_interfaz_rel"})
            except Exception as e:
                logger.error(f"Error consultando interno.interfaz_rel: {e}", extra={"procedimiento": "consulta_interfaz_rel"})
                continue

            # 4) Validar columnas
            if len(df_txt.columns) != len(columnas):
                logger.error(
                    f"Columnas no coinciden para {file} (archivo={len(df_txt.columns)}, definición={len(columnas)})",
                    extra={"procedimiento": "validacion_columnas"}
                )
                continue

            # 5) Conversión de tipos
            try:
                df_txt.columns = columnas
                for col, tipo in zip(columnas, tipos):
                    if tipo == "numeric":
                        df_txt[col] = df_txt[col].apply(
                            lambda x: Decimal(str(x)).quantize(Decimal("0.0001")) if pd.notnull(x) else None
                        )
                    elif tipo == "date":
                        df_txt[col] = pd.to_datetime(df_txt[col], format="%Y%m%d", errors="coerce").dt.date
                    else:
                        df_txt[col] = df_txt[col].astype(str)
                logger.info(f"Tipos aplicados: {dict(zip(columnas, tipos))}", extra={"procedimiento": "conversion_tipos"})
            except Exception as e:
                logger.error(f"Error convirtiendo tipos en {file}: {e}", extra={"procedimiento": "conversion_tipos"})
                continue

            # 6) Inserción en tabla destino
            conn = None
            try:
                conn = psycopg2.connect(**PG_CONN)
                cur = conn.cursor()
                insert_query = sql.SQL("INSERT INTO {}.{} ({}) VALUES %s").format(
                    sql.Identifier("interno"),
                    sql.Identifier(table_destino),
                    sql.SQL(", ").join(map(sql.Identifier, columnas))
                )
                values = [tuple(row) for row in df_txt.itertuples(index=False, name=None)]
                execute_values(cur, insert_query.as_string(conn), values)
                conn.commit()

                logger.info(
                    f"{len(values)} filas insertadas en interno.{table_destino}",
                    extra={"procedimiento": "insercion_datos"}
                )
            except Exception as e:
                if conn:
                    conn.rollback()
                logger.error(f"Error insertando en {table_destino}: {e}", extra={"procedimiento": "insercion_datos"})
                continue
            finally:
                if conn:
                    conn.close()

            # 7) Fin exitoso
            duracion = round(time.time() - start_time, 2)
            logger.info(f"Finalizado archivo {file} en {duracion} segundos", extra={"procedimiento": "fin"})

        except Exception as e:
            logger.error(f"Error inesperado procesando {file}: {e}", extra={"procedimiento": "general"})
            continue

# ==============================
# DAG
# ==============================
with DAG(
    dag_id="import_interfaz",
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False,
    tags=["import", "interfaz"],
) as dag:

    import_task = PythonOperator(
        task_id="import_interfaz",
        python_callable=load_interfaz
    )

    import_task
