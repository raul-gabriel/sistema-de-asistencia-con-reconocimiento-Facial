import mysql.connector
from mysql.connector import pooling
import os
from dotenv import load_dotenv

load_dotenv()

class ConfigBaseDatos:
    def __init__(self):
        self.config = {
            'host': os.getenv('DB_HOST', 'localhost'),
            'port': int(os.getenv('DB_PORT', 3306)),
            'user': os.getenv('DB_USER', 'root'),
            'password': os.getenv('DB_PASSWORD', ''),
            'database': os.getenv('DB_NAME', 'db_asistencia'),
            'pool_name': 'pool_facial',
            'pool_size': 20,
            'pool_reset_session': True
        }
        self.pool = None

    def crear_pool(self):
        """Crea el pool de conexiones a MySQL"""
        try:
            self.pool = pooling.MySQLConnectionPool(**self.config)
            return True
        except Exception as e:
            print(f"Error creando pool: {e}")
            return False

    def obtener_conexion(self):
        """Obtiene una conexión del pool"""
        try:
            return self.pool.get_connection()
        except Exception as e:
            print(f"Error obteniendo conexión: {e}")
            return None