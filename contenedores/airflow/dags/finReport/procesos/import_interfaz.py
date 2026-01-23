from airflow.utils.task_group import TaskGroup
from airflow.providers.standard.operators.python import PythonOperator
from psycopg2 import sql
from finReport.lib.db_logger import get_logger
from finReport.lib.db_config import PG_CONN
import pandas as pd
import psycopg2
import os
from psycopg2.extras import execute_values
from datetime import datetime
from decimal import Decimal, InvalidOperation
import time

# ==============================
# CONFIGURACIÓN
# ==============================

GROUP_NAME = "import_interfaz"
INTERFACE_DIR = "/opt/airflow/finReport/interface"

logger = get_logger(GROUP_NAME, "", PG_CONN)
logger.info("Iniciando carga de interfaces")

# ==============================
# FUNCIONES AUXILIARES
# ==============================

def consulta_sql(schema, table, where=None, params=None):
    conn = None
    full_name = f"{schema}.{table}"
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
    except (InvalidOperation, ValueError):
        logger.error(f"Error convirtiendo campo '{col}' a Decimal. Valor: '{x}'")
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

    except Exception:
        logger.error(f"Error convirtiendo campo '{col}' a date. Valor: '{x}'")
        return DEFAULT


def safe_string(x, col):
    try:
        if pd.isnull(x):
            return ""
        return str(x)
    except Exception:
        logger.error(f"Error convirtiendo campo '{col}' a string. Valor: '{x}'")
        return ""


# ==============================
# FUNCIÓN PRINCIPAL
# ==============================

def load_interfaz(**context):
    schema = "interno"
    schema_destino = "interface"
    tabla = "interfaz"
    tabla_rel = "interfaz_rel"

    # Obtener fecha de proceso desde parametros_generales (cod='3')
    try:
        df_param = consulta_sql(schema, "parametros_generales", "cod = '3'")
        if df_param.empty:
            logger.error("No existe parametro interno.parametros_generales con cod='3'")
            return
        fecha_proceso = str(df_param.iloc[0]["valor"]).strip()
        if not fecha_proceso:
            logger.error("El parametro cod='3' no tiene valor de fecha_proceso")
            return
        logger.info(f"Fecha de proceso obtenida: {fecha_proceso}")
    except Exception as e:
        logger.error(f"Error obteniendo fecha de proceso desde interno.parametros_generales: {e}")
        return

    logger.info(f"Buscando archivos .txt en {INTERFACE_DIR}")
    all_files = [f for f in os.listdir(INTERFACE_DIR) if f.lower().endswith('.txt')]

    # Filtrar por fecha de proceso contenida en el nombre del archivo
    files = [f for f in all_files if fecha_proceso in f]
    logger.info(f"Archivos que entrarán al loop (files): {files}")

    if not files:
        logger.warning(f"No se encontraron archivos .txt en {INTERFACE_DIR} que contengan fecha {fecha_proceso}")
        return

    for file in files:
        start_time = time.time()
        file_path = os.path.join(INTERFACE_DIR, file)
        cod = os.path.basename(file_path)[:3]
        logger.info(f"Procesando archivo {file} con cod={cod}")

        try:
            # Leer archivo
            try:
                df_txt = pd.read_csv(file_path, sep=";", encoding="utf-8", dtype=str, header=None)
                logger.info(f"Archivo leído correctamente: {len(df_txt)} filas")
            except Exception as e:
                logger.error(f"Error leyendo archivo {file}: {e}")
                continue

            # Buscar configuración
            try:
                df_interfaz = consulta_sql(schema, tabla, f"cod = '{cod}'")
                if df_interfaz.empty:
                    raise Exception(f"No existe configuración para cod={cod}")
                table_destino = df_interfaz.iloc[0][tabla]
                logger.info(f"Tabla destino: {table_destino}")
            except Exception as e:
                logger.error(f"Error consultando {schema}.{tabla}: {e}")
                continue

            # Obtener estructura
            try:
                df_campos = consulta_sql(schema, tabla_rel, f"cod = '{cod}'")
                if df_campos.empty:
                    raise Exception(f"No hay campos definidos para cod={cod}")
                columnas = df_campos["campo"].tolist()
                tipos = df_campos["tipo_dato"].tolist()
                logger.info(f"Campos definidos: {len(columnas)}")
            except Exception as e:
                logger.error(f"Error consultando {schema}.{tabla_rel}: {e}")
                continue

            # Validar columnas
            if len(df_txt.columns) != len(columnas):
                logger.error(
                    f"Cantidad de columnas no coincide. Archivo={len(df_txt.columns)}, Definición={len(columnas)}"
                )
                continue

            # Conversión de tipos
            try:
                df_txt.columns = columnas
                for col, tipo in zip(columnas, tipos):
                    if tipo == "numeric":
                        df_txt[col] = df_txt[col].apply(lambda x: safe_decimal(x, col))
                    elif tipo == "date":
                        df_txt[col] = df_txt[col].apply(lambda x: safe_date(x, col))
                    else:
                        df_txt[col] = df_txt[col].apply(lambda x: safe_string(x, col))
                logger.info("Conversión de tipos completada")
            except Exception as e:
                logger.error(f"Error convirtiendo tipos en {file}: {e}")
                continue

            # Inserción en tabla destino
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

            duracion = round(time.time() - start_time, 2)
            logger.info(f"Archivo {file} procesado en {duracion} segundos")

        except Exception as e:
            logger.error(f"Error inesperado procesando archivo {file}: {e}")
            continue
        
        finally:        
       
            # Borrar archivo una vez importado correctamente
            try:
                logger.info(f"Intentando eliminar: {file_path}")
                os.remove(file_path)
                logger.info(f"Archivo eliminado post-import: {file}")
            except Exception as e:
                logger.error(f"No se pudo eliminar el archivo {file}: {e}")


# ==============================
# TASK GROUP BUILDER
# ==============================

def build_group(dag):
    with TaskGroup(group_id=GROUP_NAME, dag=dag) as group:

        PythonOperator(
            task_id="run_import_interfaz",
            python_callable=load_interfaz
        )

    return group
