from airflow import DAG
from datetime import datetime

from finReport.procesos.validador import (
    limpia_tablas,
    import_mantenedores,
    import_reportes,
)

with DAG(
    dag_id="orquestador_validador",
    start_date=datetime(1970, 1, 1),
    schedule=None,
    catchup=False,
    is_paused_upon_creation=False,
    tags=["orquestador", "finReport", "validador"],
) as dag:

    g1 = limpia_tablas.build_group(dag)
    g2 = import_mantenedores.build_group(dag)
    g3 = import_reportes.build_group(dag)

    g1 >> g2 >> g3
