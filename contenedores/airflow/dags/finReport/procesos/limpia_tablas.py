from airflow.utils.task_group import TaskGroup
from airflow.providers.standard.operators.python import PythonOperator
from finReport.lib.db_procedures import ProcedureExecutor
from finReport.lib.db_config import PG_CONN

# ==============================
# CONFIGURACIÓN
# ==============================

GROUP_NAME = "limpia_tablas"

# Procedimientos de este módulo
PROCEDIMIENTOS = [
    ("proceso", "trunca_tablas")
]

# Executor con logger asociado
executor = ProcedureExecutor(PG_CONN, name=GROUP_NAME)

# ==============================
# DEFINICIÓN DEL TASK GROUP
# ==============================

def build_group(dag):
    """
    Construye y retorna el TaskGroup con la lógica de limpia_tablas.
    Este TaskGroup se usa dentro del DAG orquestador.
    """

    with TaskGroup(group_id=GROUP_NAME, dag=dag) as group:

        for schema, proc in PROCEDIMIENTOS:
            PythonOperator(
                task_id=f"call_{schema}_{proc}",
                python_callable=executor.ejecutar,
                op_kwargs={"schema": schema, "procedimiento": proc},
            )

    return group
