from airflow import DAG
from datetime import datetime

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
)

with DAG(
    dag_id="orquestador_redec",
    start_date=datetime(1970, 1, 1),
    schedule=None,
    catchup=False,
    is_paused_upon_creation=False,
    tags=["orquestador", "finReport", "redec"],
) as dag:

    g1 = limpia_tablas.build_group(dag)
    g2 = import_mantenedores.build_group(dag)
    g3 = import_interfaz.build_group(dag)
    g4 = valida_interfaces.build_group(dag)
    g5 = ejecuta_reportes.build_group(dag)
    g6 = exporta_tabla_a_txt.build_group(dag)
    g7 = exporta_reportes_excel.build_group(dag)
    g8 = historico_log.build_group(dag)
    g9 = exporta_logs.build_group(dag)

    g1 >> g2 >> g3 >> g4 >> g5 >> g6 >> g7 >> g8 >> g9
