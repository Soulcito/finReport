from airflow.utils.task_group import TaskGroup
from airflow.providers.standard.operators.python import PythonOperator
from finReport.lib.db_procedures import ProcedureExecutor
from finReport.lib.db_config import PG_CONN

# ==============================
# CONFIGURACIÓN
# ==============================

GROUP_NAME = "valida_interfaces"

PROCEDIMIENTOS = [
    ("proceso", "val_interfaz_a01"),
    ("proceso", "val_interfaz_b01"),
    ("proceso", "val_interfaz_c01"),
    ("proceso", "val_interfaz_e01"),
]

executor = ProcedureExecutor(PG_CONN, name=GROUP_NAME)

# ==============================
# TASK GROUP BUILDER
# ==============================

def build_group(dag):
    """
    TaskGroup para ejecutar validaciones de interfaces en paralelo.
    """

    with TaskGroup(group_id=GROUP_NAME, dag=dag) as group:

        for schema, proc in PROCEDIMIENTOS:
            PythonOperator(
                task_id=f"call_{schema}_{proc}",
                python_callable=executor.ejecutar,
                op_kwargs={"schema": schema, "procedimiento": proc},
            )


    return group


# ==============================
# EJECUCIÓN DIRECTA DEL MÓDULO
# ==============================

def run():
    """
    Ejecuta las validaciones de interfaces en forma directa,
    para uso desde el orquestador secuencial.
    """
    for schema, proc in PROCEDIMIENTOS:
        executor.ejecutar(schema=schema, procedimiento=proc)