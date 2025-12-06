from airflow.utils.task_group import TaskGroup
from airflow.providers.standard.operators.python import PythonOperator

from finReport.lib.db_to_excel import MultiTableToExcelExporter
from finReport.lib.db_config import PG_CONN


# ==============================
# CONFIGURACIÓN
# ==============================

GROUP_NAME = "exporta_logs"
EXCEL_DIR = "/opt/airflow/finReport/logs"
NOMBRE_EXCEL = "logs"

# Lista de tablas a exportar:
# Cada item = (schema, tabla)

TABLAS_EXCEL = [
    ("log", "log_eventos"),
    ("log", "cartera_operaciones"),
    ("log", "cuadro_operaciones"),
    ("log", "cuadro_rectificaciones"),
    ("log", "tipo_cambio"),
    ("log", "cartera_garantias"),
]


# Instancia única del exportador
exporter = MultiTableToExcelExporter(conn_params=PG_CONN, name=GROUP_NAME)


# ==============================
# TASK GROUP BUILDER (reutilizable)
# ==============================


def build_group(dag, tablas=TABLAS_EXCEL, out_dir=EXCEL_DIR, nombre_excel=NOMBRE_EXCEL):
    """
    TaskGroup para exportar múltiples tablas a un archivo Excel.

    Parámetros:
        dag           → instancia del DAG padre
        tablas        → lista de tuplas (schema, tabla)
        out_dir       → directorio destino del archivo
        nombre_excel  → nombre base del archivo Excel

    """

    with TaskGroup(group_id=GROUP_NAME, dag=dag) as group:

        tarea = PythonOperator(
            task_id="exporta_excel_multitablas",
            python_callable=exporter.exportar,
            op_kwargs={
                "tablas": tablas,
                "out_dir": out_dir,
                "nombre_excel": nombre_excel,
            },
        )

    return group
