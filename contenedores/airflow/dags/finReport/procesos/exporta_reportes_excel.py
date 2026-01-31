from airflow.utils.task_group import TaskGroup
from airflow.providers.standard.operators.python import PythonOperator

from finReport.lib.db_to_excel import MultiTableToExcelExporter
from finReport.lib.db_config import PG_CONN


# ==============================
# CONFIGURACIÓN REPORTES
# ==============================

GROUP_NAME_REPORTE = "exporta_reportes_excel"
EXCEL_DIR = "/opt/airflow/finReport/reports"
NOMBRE_EXCEL_REPORTE = "Reportes"

# Lista de tablas a exportar:
# Cada item = (schema, tabla)

TABLAS_EXCEL_REPORTE = [
    ("reporte", "rdc01_final"),
    ("reporte", "rdc01_caratula"),
    ("reporte", "rdc20_final_1"),
    ("reporte", "rdc20_final_2"),
    ("reporte", "rdc20_final_3"),
    ("reporte", "rdc20_final_4"),
    ("reporte", "rdc20_caratula"),
    ("reporte", "rdc22_final"),
    ("reporte", "rdc22_caratula")
]

# ==============================
# CONFIGURACIÓN DETALLE REPORTE
# ==============================

GROUP_NAME_DETALLE = "exporta_detalle_excel"
NOMBRE_EXCEL_DETALLE = "Reportes_detalle"

# Lista de tablas a exportar:
# Cada item = (schema, tabla)

TABLAS_EXCEL_DETALLE = [
    ("reporte", "rdc01_detalle"),
    ("reporte", "rdc20_detalle_1"),
    ("reporte", "rdc20_detalle_2"),
    ("reporte", "rdc20_detalle_3"),
    ("reporte", "rdc20_detalle_4"),
    ("reporte", "rdc22_detalle")
]


# ==============================
# TASK GROUP BUILDER (reutilizable)
# ==============================


def _build_excel_group(group_name, tablas, out_dir, nombre_excel):
    """
    TaskGroup para exportar múltiples tablas a un archivo Excel con multiples hojas.

    Parámetros:
        group_name    → para poder generar grupos ID distintos y generar mas de un excel 
        tablas        → lista de tuplas (schema, tabla)
        out_dir       → directorio destino del archivo
        nombre_excel  → nombre base del archivo Excel

    """
    
    # Instancia única del exportador
    exporter = MultiTableToExcelExporter(conn_params=PG_CONN, name=group_name)

    with TaskGroup(group_id=group_name) as group:

        PythonOperator(
            task_id="exporta_excel",
            python_callable=exporter.exportar,
            op_kwargs={
                "tablas": tablas,
                "out_dir": out_dir,
                "nombre_excel": nombre_excel,
            },
        )

    return group


# ==============================================
# GENERACION DE EXCEL PARA REPORTES Y DETALLES
# ==============================================


def build_group(dag):
    """
    Builder estándar para el orquestador REDEC.
    Retorna un único TaskGroup "contenedor".
    """

    with TaskGroup(group_id="exporta_excels", dag=dag) as main_group:

        grupo_reporte = _build_excel_group(
            GROUP_NAME_REPORTE,
            TABLAS_EXCEL_REPORTE,
            EXCEL_DIR,
            "Reportes"
        )

        grupo_detalle = _build_excel_group(
            GROUP_NAME_DETALLE,
            TABLAS_EXCEL_DETALLE,
            EXCEL_DIR,
            "Reportes_detalle"
        )

        grupo_reporte >> grupo_detalle

    return main_group

