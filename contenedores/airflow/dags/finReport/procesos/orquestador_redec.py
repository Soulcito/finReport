from airflow import DAG
from datetime import datetime
from airflow.operators.python import PythonOperator
import os
import re
import psycopg2
from finReport.lib.db_config import PG_CONN

from finReport.procesos import (
    limpia_tablas,
    import_mantenedores,
    import_interfaz,
    valida_interfaces,
    historico_log,
    ejecuta_reportes,
    exporta_tabla_a_txt,
    exporta_reportes_excel,
    exporta_logs,
    otros_procesos,
)

# ==============================
# CONFIGURACIÓN
# ==============================

INTERFACE_DIR = "/opt/airflow/finReport/interface"

# ==============================
# OBTIENE FECHAS DE PROCESO
# ==============================

def obtener_fecha_minima_interfaces():
    fechas_validas = set()

    for nombre in os.listdir(INTERFACE_DIR):
        ruta = os.path.join(INTERFACE_DIR, nombre)

        if not os.path.isfile(ruta):
            continue

        match = re.match(r"^.{3}(\d{8})(?:\.(txt|xlsx))?$", nombre, re.IGNORECASE)
        if not match:
            continue

        fecha = match.group(1)

        try:
            datetime.strptime(fecha, "%Y%m%d")
            fechas_validas.add(fecha)
        except ValueError:
            continue

    fechas_ordenadas = sorted(fechas_validas)
    
    if not fechas_ordenadas:
        raise ValueError(f"No se encontraron fechas válidas en {INTERFACE_DIR}")

    return fechas_ordenadas[0]

# ============================================
# CAMBIA LA FECHA DE PROCESO EN BASE DE DATOS
# ============================================

def marca_inicio_fecha():    
    fecha = obtener_fecha_minima_interfaces()
    
    with psycopg2.connect(**PG_CONN) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                update interno.parametros_generales
                set valor = %s
                where cod = '3'
                """,
                (fecha,)
            )


with DAG(
    dag_id="orquestador_redec",
    start_date=datetime(1970, 1, 1),
    schedule=None,
    catchup=False,
    is_paused_upon_creation=False,
    tags=["orquestador", "finReport", "redec"],
) as dag:
    
    t0 = PythonOperator(
        task_id="setea_fecha_minima",
        python_callable=marca_inicio_fecha,
    )    

    g1 = limpia_tablas.build_group(dag)
    g2 = import_mantenedores.build_group(dag)
    g3 = import_interfaz.build_group(dag)
    g4 = valida_interfaces.build_group(dag)
    g5 = otros_procesos.build_group(dag)
    g6 = ejecuta_reportes.build_group(dag)
    g7 = exporta_tabla_a_txt.build_group(dag)
    g8 = exporta_reportes_excel.build_group(dag)
    g9 = historico_log.build_group(dag)
    g10 = exporta_logs.build_group(dag)

    g1 >> g2 >> t0 >> g3 >> g4 >> g5 >> g6 >> g7 >> g8 >> g9 >> g10