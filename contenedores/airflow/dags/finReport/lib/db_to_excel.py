import os
import psycopg2
from psycopg2 import sql
from datetime import datetime
from openpyxl import Workbook
from finReport.lib.db_config import PG_CONN
from finReport.lib.db_logger import get_logger


class MultiTableToExcelExporter:
    """
    Exporta múltiples tablas a un archivo Excel, donde cada hoja contiene
    los datos de una tabla. La primera fila incluye los nombres de columnas.

    """

    def __init__(self, conn_params: dict, name: str = "excel_exporter"):
        self.conn_params = conn_params
        self.logger = get_logger(dag_name=name, proc_name="", conn_params=conn_params)

    def exportar(
        self,
        tablas: list,  # lista de tuplas (schema, tabla)
        out_dir: str,  # directorio destino
        nombre_excel: str,  # nombre base del archivo sin extensión
    ):
        """
        Exporta varias tablas a un archivo Excel.

        'tablas' = [(schema, table), (schema, table), ...]

        """

        # Agregar fecha/hora/minuto/segundo al nombre del Excel
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        nombre_final = f"{nombre_excel}_{timestamp}.xlsx"
        ruta_excel = os.path.join(out_dir, nombre_final)

        wb = Workbook()
        wb.remove(wb.active)  # borrar hoja creada por defecto

        conn = None

        try:
            self.logger.info(f"Generando Excel en {ruta_excel}")

            conn = psycopg2.connect(**self.conn_params)
            cur = conn.cursor()

            for schema, tabla in tablas:
                self.logger.info(f"Exportando hoja desde {schema}.{tabla}")

                # Crear hoja con nombre de tabla
                hoja = wb.create_sheet(title=tabla)

                # Construir query
                query = sql.SQL("SELECT * FROM {}.{}").format(
                    sql.Identifier(schema), sql.Identifier(tabla)
                )

                cur.execute(query)

                # Obtener nombres de columnas
                colnames = [desc[0] for desc in cur.description]
                hoja.append(colnames)

                # Escribir datos
                for row in cur.fetchall():
                    hoja.append(list(row))

            # Guardar archivo Excel
            wb.save(ruta_excel)
            self.logger.info(f"Archivo Excel generado correctamente: {ruta_excel}")

        except Exception as e:
            self.logger.error(f"Error exportando tablas a Excel: {e}")
            raise

        finally:
            if conn:
                conn.close()
