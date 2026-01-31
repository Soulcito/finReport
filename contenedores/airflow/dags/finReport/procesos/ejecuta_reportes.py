from airflow.utils.task_group import TaskGroup
from airflow.providers.standard.operators.python import PythonOperator
from finReport.lib.db_procedures import ProcedureExecutor
from finReport.lib.db_config import PG_CONN

# ==============================
# CONFIGURACIÓN
# ==============================

GROUP_NAME = "ejecuta_reportes"

PROCEDIMIENTOS = [
    ("proceso", "genera_rdc01"),
    ("proceso", "genera_rdc20"),   
    ("proceso", "genera_rdc22"),
]

executor = ProcedureExecutor(PG_CONN, name=GROUP_NAME)

# ==============================
# TASK GROUP BUILDER (Ejecución secuencial)
# ==============================


def build_group(dag):

    with TaskGroup(group_id=GROUP_NAME, dag=dag) as group:

        prev_task = None

        for schema, proc in PROCEDIMIENTOS:
            tarea = PythonOperator(
                task_id=f"call_{schema}_{proc}",
                python_callable=executor.ejecutar,
                op_kwargs={"schema": schema, "procedimiento": proc},
            )

            # Si existe una tarea previa → encadenar
            if prev_task:
                prev_task >> tarea

            prev_task = tarea  # actualizar referencia

    return group
