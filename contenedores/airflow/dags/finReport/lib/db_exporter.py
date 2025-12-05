import os
import psycopg2
from psycopg2 import sql
from finReport.lib.db_config import PG_CONN
from finReport.lib.db_logger import get_logger


class TableToTextExporter:
    """
    Clase encargada de exportar el contenido de una tabla (columna única: registro TEXT)
    a un archivo .TXT en un directorio especificado.

    El nombre del archivo se obtiene tomando el primer registro y aplicando
    un substring según posición y largo definidos por parámetro.

    """

    def __init__(self, conn_params: dict, name: str = "table_exporter"):
        """
        conn_params: diccionario de conexión PostgreSQL (PG_CONN)
        name: nombre para el logger finReport

        """
        self.conn_params = conn_params
        self.logger = get_logger(dag_name=name, proc_name="", conn_params=conn_params)

    def exportar(
        self, schema: str, tabla: str, out_dir: str, pos_nombre: int, largo_nombre: int
    ):
        """
        Exporta el contenido de schema.tabla a un archivo TXT.

        Parámetros:
        schema      → esquema donde reside la tabla
        tabla       → nombre de la tabla a leer
        out_dir     → directorio donde guardar el archivo generado
        pos_nombre  → posición inicial (0-based) para substring del nombre archivo
        largo_nombre→ cantidad de caracteres a tomar para el nombre

        """
        conn = None
        try:
            self.logger.info(f"Exportando datos desde {schema}.{tabla}")

            conn = psycopg2.connect(**self.conn_params)
            cur = conn.cursor()

            # Consulta explícita de la columna 'registro'
            query = sql.SQL("SELECT registro FROM {}.{}").format(
                sql.Identifier(schema), sql.Identifier(tabla)
            )

            cur.execute(query)
            filas = cur.fetchall()

            if not filas:
                self.logger.warning(
                    f"La tabla {schema}.{tabla} está vacía. No se genera archivo."
                )
                return

            # Se obtiene el nombre del archivo desde el primer registro
            primer_registro = filas[0][0]

            nombre_extraido = primer_registro[pos_nombre : pos_nombre + largo_nombre]
            nombre_archivo = f"{nombre_extraido}.TXT"

            ruta_archivo = os.path.join(out_dir, nombre_archivo)

            self.logger.info(f"Nombre del archivo generado: {nombre_archivo}")

            # Escribir todas las filas en el archivo
            with open(ruta_archivo, "w", encoding="utf-8") as f:
                for fila in filas:
                    f.write(fila[0] + "\n")

            self.logger.info(f"Archivo generado correctamente en: {ruta_archivo}")

            cur.close()

        except Exception as e:
            self.logger.error(f"Error exportando {schema}.{tabla}: {e}")
            raise

        finally:
            if conn:
                conn.close()
