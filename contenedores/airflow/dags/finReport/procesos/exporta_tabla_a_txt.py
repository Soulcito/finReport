from airflow.utils.task_group import TaskGroup
from airflow.providers.standard.operators.python import PythonOperator

from finReport.lib.db_exporter import TableToTextExporter
from finReport.lib.db_config import PG_CONN


# ==============================
# CONFIGURACIÓN
# ==============================

GROUP_NAME = "exporta_reportes"
REPORT_DIR = "/opt/airflow/finReport/reports"

# Lista de reportes configurables
# Cada item = (schema, tabla, out_dir, pos_nombre, largo_nombre)

REPORTES = [
    ("reporte", "rdc01_texto", REPORT_DIR, 10, 13),
    ("reporte", "rdc20_texto", REPORT_DIR, 10, 13),
]


# Instancia única del exportador
exporter = TableToTextExporter(conn_params=PG_CONN, name=GROUP_NAME)


# ==============================
# TASK GROUP BUILDER (reutilizable)
# ==============================


def build_group(dag, reportes=REPORTES):
    """
    TaskGroup reutilizable para exportar múltiples tablas a TXT.

    Parámetros:
        dag        → instancia del DAG padre
        reportes   → lista de tuplas (schema, tabla, out_dir, pos, largo)
    """

    with TaskGroup(group_id=GROUP_NAME, dag=dag) as group:

        tareas = []
        for schema, tabla, out_dir, pos, largo in reportes:

            tarea = PythonOperator(
                task_id=f"exporta_{schema}_{tabla}",
                python_callable=exporter.exportar,
                op_kwargs={
                    "schema": schema,
                    "tabla": tabla,
                    "out_dir": out_dir,
                    "pos_nombre": pos,
                    "largo_nombre": largo,
                },
            )

            tareas.append(tarea)

        tareas  # ejecución en paralelo

    return group
