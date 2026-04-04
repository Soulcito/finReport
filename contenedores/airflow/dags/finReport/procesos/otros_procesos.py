from airflow.utils.task_group import TaskGroup
from airflow.providers.standard.operators.python import PythonOperator
from finReport.lib.db_procedures import ProcedureExecutor
from finReport.lib.db_config import PG_CONN

# ==============================
# CONFIGURACIÓN
# ==============================

GROUP_NAME = "otros_procesos"

PROCEDIMIENTOS = [
    ("proceso", "excluir_por_morosidad"),
    ("proceso", "calculo_calendario_rdc20"),
    ("proceso", "genera_hist_interface"),
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
    Ejecuta los procesos adicionales en forma secuencial,
    para uso desde el orquestador.
    """
    for schema, proc in PROCEDIMIENTOS:
        executor.ejecutar(schema=schema, procedimiento=proc)