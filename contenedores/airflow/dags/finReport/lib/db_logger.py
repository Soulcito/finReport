# /opt/airflow/finReport/lib/db_logger.py

import logging
from datetime import datetime
import psycopg2

class PostgresLogHandler(logging.Handler):
    """Handler que guarda logs en la tabla log.log_eventos."""
    def __init__(self, conn_params, dag_name=""):
        super().__init__()
        self.conn_params = conn_params
        self.dag_name = dag_name

    def emit(self, record):
        log_entry = self.format(record)
        conn = None
        try:
            conn = psycopg2.connect(**self.conn_params)
            cur = conn.cursor()
            cur.execute("""
                INSERT INTO log.log_eventos (fecha, nivel, dag, procedimiento, mensaje)
                VALUES (%s, %s, %s, %s, %s)
            """, (
                datetime.now(),
                record.levelname,
                self.dag_name,
                getattr(record, "procedimiento", ""),
                log_entry
            ))
            conn.commit()
            cur.close()
        except Exception as e:
            print(f"[db_logger] Error guardando log en PostgreSQL: {e}")
        finally:
            if conn:
                conn.close()


def get_logger(dag_name: str, conn_params: dict):
    """
    Retorna un logger configurado para escribir tanto en consola como en PostgreSQL.
    """
    formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

    logger = logging.getLogger(dag_name)
    logger.setLevel(logging.INFO)

    # Evitar duplicados
    if not logger.handlers:
         # Consola -> stdout (para que Airflow no lo marque como error)
        import sys
        console_handler = logging.StreamHandler(sys.stdout) 
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)

        # PostgreSQL
        db_handler = PostgresLogHandler(conn_params, dag_name)
        db_handler.setFormatter(formatter)
        logger.addHandler(db_handler)

    return logger
