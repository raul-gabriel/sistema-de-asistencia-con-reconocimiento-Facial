import json

class RepositorioEstudiante:
    def __init__(self, config_db):
        self.config_db = config_db
    
    def obtener_embeddings(self):
        """Obtiene todos los embeddings de la BD"""
        conexion = self.config_db.obtener_conexion()
        if not conexion:
            return []
        
        try:
            cursor = conexion.cursor(dictionary=True)
            query = """
                SELECT ef.alumno_id, ef.vector_embedding
                FROM embeddings_faciales ef
                INNER JOIN alumno a ON ef.alumno_id = a.id
                WHERE a.estado = 'matriculado'
            """
            cursor.execute(query)
            resultados = cursor.fetchall()
            
            embeddings = []
            for row in resultados:
                vector = json.loads(row['vector_embedding'])
                embeddings.append({
                    'alumno_id': row['alumno_id'],
                    'vector': vector
                })
            
            return embeddings
            
        except Exception as e:
            print(f"Error obteniendo embeddings: {e}")
            return []
        finally:
            cursor.close()
            conexion.close()
    
    
    def registrar_asistencia(self, alumno_id: int): 
        """Llama al procedimiento almacenado para registrar asistencia""" 
        conexion = self.config_db.obtener_conexion() 
        if not conexion: 
            return {'estado': 'ERROR', 'mensaje': 'Error de conexión a BD'} 
        
        try: 
            cursor = conexion.cursor(dictionary=True) 
            cursor.callproc('registrar_asistencia', [alumno_id]) 
            
            print() 
            print("==========================================================================") 
            print(f"Ejecutando procedimiento para alumno_id: {alumno_id}") 
            
            # ERROR CORREGIDO: Inicializar la variable resultados
            resultados = []
            # Obtener todos los resultados 
            for resultado in cursor.stored_results(): 
                fila = resultado.fetchone() 
                if fila: 
                    resultados.append(fila) 
                    print(f"Resultado obtenido: {fila}") 
            
            # ¡IMPORTANTE! Hacer COMMIT para guardar los cambios 
            conexion.commit() 
            print("COMMIT ejecutado - cambios guardados en BD") 
            
            if resultados: 
                return resultados[0] 
            else: 
                print("No se obtuvieron resultados del procedimiento") 
                return {'estado': 'ERROR', 'mensaje': 'No se pudo procesar la asistencia'} 
                
        except Exception as e: 
            print(f"Error en procedimiento: {e}") 
            # ERROR CORREGIDO: Verificar si conexion existe antes del rollback
            if conexion:
                try:
                    conexion.rollback() 
                    print("ROLLBACK ejecutado - cambios deshechos") 
                except Exception as rollback_error:
                    print(f"Error en rollback: {rollback_error}")
            return {'estado': 'ERROR', 'mensaje': f'Error registrando asistencia: {str(e)}'} 
        finally: 
            # ERROR CORREGIDO: Cerrar cursor de forma segura
            try:
                if 'cursor' in locals() and cursor:
                    cursor.close()
            except Exception as cursor_error:
                print(f"Error cerrando cursor: {cursor_error}")
                
            # ERROR CORREGIDO: Cerrar conexión de forma segura  
            try:
                if conexion:
                    conexion.close()
            except Exception as conn_error:
                print(f"Error cerrando conexión: {conn_error}")




    #============================para actualzar los embedding =============================================

    def obtener_embeddings(self):
        """Obtiene todos los embeddings de la BD CON su ID"""
        conexion = self.config_db.obtener_conexion()
        if not conexion:
            return []
        
        try:
            cursor = conexion.cursor(dictionary=True)
            query = """
                SELECT ef.id as embedding_id, ef.alumno_id, ef.vector_embedding
                FROM embeddings_faciales ef
                INNER JOIN alumno a ON ef.alumno_id = a.id
                WHERE a.estado = 'matriculado'
            """
            cursor.execute(query)
            resultados = cursor.fetchall()
            
            embeddings = []
            for row in resultados:
                vector = json.loads(row['vector_embedding'])
                embeddings.append({
                    'embedding_id': row['embedding_id'],
                    'alumno_id': row['alumno_id'],
                    'vector': vector
                })
            
            return embeddings
            
        except Exception as e:
            print(f"Error obteniendo embeddings: {e}")
            return []
        finally:
            cursor.close()
            conexion.close()


    def obtener_embedding_por_id(self, embedding_id: int):
        """Obtiene un embedding específico por su ID"""
        conexion = self.config_db.obtener_conexion()
        if not conexion:
            return None
        
        try:
            cursor = conexion.cursor(dictionary=True)
            query = """
                SELECT ef.id as embedding_id, ef.alumno_id, ef.vector_embedding
                FROM embeddings_faciales ef
                INNER JOIN alumno a ON ef.alumno_id = a.id
                WHERE ef.id = %s AND a.estado = 'matriculado'
            """
            cursor.execute(query, (embedding_id,))
            resultado = cursor.fetchone()
            
            if resultado:
                vector = json.loads(resultado['vector_embedding'])
                return {
                    'embedding_id': resultado['embedding_id'],
                    'alumno_id': resultado['alumno_id'],
                    'vector': vector
                }
            return None
            
        except Exception as e:
            print(f"Error obteniendo embedding: {e}")
            return None
        finally:
            cursor.close()
            conexion.close()