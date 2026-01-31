from airflow.utils.task_group import TaskGroup
from airflow.providers.standard.operators.python import PythonOperator

from finReport.lib.db_to_excel_validador import MultiTableToExcelExporter
from finReport.lib.db_config import PG_CONN


# ==============================
# CONFIGURACIÓN REPORTES
# ==============================

EXCEL_DIR = "/opt/airflow/finReport/validador/resultado"

GROUP_NAME_RDC01 = "exporta_validadores_rdc01"
NOMBRE_RDC01 = "RDC01"

# Lista de tablas a exportar:
# Cada item = (schema, tabla)

TABLAS_RDC01 = [
    ("validador", "rdc01_detalle"),
    ("validador", "rdc01_resultado"),    
]

# ==============================
# CONFIGURACIÓN DETALLE REPORTE
# ==============================

GROUP_NAME_RDC20 = "exporta_validadores_rdc20"
NOMBRE_RDC20 = "RDC20"

# Lista de tablas a exportar:
# Cada item = (schema, tabla)

TABLAS_RDC20 = [
    ("validador", "rdc20_detalle_1"),
    ("validador", "rdc20_detalle_2"),
    ("validador", "rdc20_detalle_3"),
    ("validador", "rdc20_detalle_4"),
    ("validador", "rdc20_resultado")    
]

# ==============================
# CONFIGURACIÓN DETALLE REPORTE
# ==============================

GROUP_NAME_RDC22 = "exporta_validadores_rdc22"
NOMBRE_RDC22 = "RDC22"

# Lista de tablas a exportar:
# Cada item = (schema, tabla)

TABLAS_RDC22 = [
    ("validador", "rdc22_detalle"),
    ("validador", "rdc22_resultado")    
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

        grupo_rdc01 = _build_excel_group(
            GROUP_NAME_RDC01,
            TABLAS_RDC01,
            EXCEL_DIR,
            NOMBRE_RDC01
        )

        grupo_rdc20 = _build_excel_group(
            GROUP_NAME_RDC20,
            TABLAS_RDC20,
            EXCEL_DIR,
            NOMBRE_RDC20
        )
        
        grupo_rdc22 = _build_excel_group(
            GROUP_NAME_RDC22,
            TABLAS_RDC22,
            EXCEL_DIR,
            NOMBRE_RDC22
        )        

        grupo_rdc01 >> grupo_rdc20 >> grupo_rdc22

    return main_group

