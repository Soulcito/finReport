import psycopg2
from psycopg2 import sql
from finReport.lib.db_config import PG_CONN
from finReport.lib.db_logger import get_logger

class ProcedureExecutor:
    """
     Clase encargada de ejecutar procedimientos almacenados en PostgreSQL.
     Usa el logger estándar finReport para registrar eventos en consola y base.
    """


    def __init__(self, conn_params: dict, name: str = "proc_executor"):
        """
        conn_params: parámetros de conexión PostgreSQL (PG_CONN)
        name: nombre del logger (para identificar en log.log_eventos)
        """
        self.conn_params = conn_params
        self.logger = get_logger(dag_name=name, proc_name="", conn_params=conn_params)

    def ejecutar(self, schema: str, procedimiento: str):
        conn = None
        try:
            self.logger.info(f"Ejecutando {schema}.{procedimiento}()")

            conn = psycopg2.connect(**self.conn_params)
            cur = conn.cursor()

            query = sql.SQL("CALL {}.{}()").format(
                sql.Identifier(schema),
                sql.Identifier(procedimiento)
            )

            cur.execute(query)
            conn.commit()

            self.logger.info(f"Procedimiento {schema}.{procedimiento}() ejecutado OK")
            cur.close()

        except Exception as e:
            self.logger.error(f"Error ejecutando {schema}.{procedimiento}: {e}")
            raise

        finally:
            if conn:
                conn.close()
