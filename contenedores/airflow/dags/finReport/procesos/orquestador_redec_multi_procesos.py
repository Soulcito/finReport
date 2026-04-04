from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
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

def obtener_fechas_interfaces():
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

    return fechas_ordenadas


# ============================================
# CAMBIA LA FECHA DE PROCESO EN BASE DE DATOS
# ============================================

def marca_inicio_fecha(fecha):
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


# ============================================
# PROCESA TODAS LAS FECHAS EN FORMA SECUENCIAL
# ============================================

def procesa_fechas():
    fechas = obtener_fechas_interfaces()

    if not fechas:
        print("No se encontraron fechas válidas en las interfaces")
        return

    print(f"Fechas encontradas: {fechas}")

    for fecha in fechas:
        print(f"=== INICIO FECHA {fecha} ===")

        # 1. Cambia fecha de proceso
        marca_inicio_fecha(fecha)

        # 2. Limpia tablas
        limpia_tablas.run()

        # 3. Importa interfaz
        import_interfaz.run()

        # 4. Valida interfaces
        valida_interfaces.run()

        # 5. Otros procesos
        otros_procesos.run()

        # 6. Ejecuta reportes
        ejecuta_reportes.run()

        # 7. Exporta TXT
        exporta_tabla_a_txt.run()

        # 8. Exporta Excel reportes
        exporta_reportes_excel.run()

        # 9. Histórico log
        historico_log.run()

        # 10. Exporta logs
        exporta_logs.run()

        print(f"=== FIN FECHA {fecha} ===")


with DAG(
    dag_id="orquestador_redec_multi_procesos",
    start_date=datetime(1970, 1, 1),
    schedule=None,
    catchup=False,
    is_paused_upon_creation=False,
    tags=["orquestador", "finReport", "redec"],
) as dag:

    g2 = import_mantenedores.build_group(dag)

    procesa_fechas_task = PythonOperator(
        task_id="procesa_fechas",
        python_callable=procesa_fechas,
        dag=dag,
    )

    g2 >> procesa_fechas_task