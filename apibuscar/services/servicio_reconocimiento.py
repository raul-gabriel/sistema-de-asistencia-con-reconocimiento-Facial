import faiss  # ← Agrega esta línea
from models.modelos import RespuestaReconocimiento

class ServicioReconocimiento:
    def __init__(self, repo_estudiante, gestor_faiss):
        self.repo = repo_estudiante
        self.faiss = gestor_faiss
    
    def inicializar_faiss(self):
        """Carga embeddings de BD a FAISS"""
        try:
            embeddings = self.repo.obtener_embeddings()
            for emb in embeddings:
                self.faiss.agregar_embedding_con_id(
                    emb['embedding_id'], 
                    emb['alumno_id'], 
                    emb['vector']
                )
            print(f"FAISS inicializado con {len(embeddings)} embeddings")
            return True
        except Exception as e:
            print(f"Error inicializando FAISS: {e}")
            return False
        

    def reconocer_estudiante(self, embedding: list, umbral: float = 0.7) -> RespuestaReconocimiento:
        """
        FUNCIÓN PRINCIPAL:
        1. Busca el embedding en FAISS
        2. Si encuentra -> registra asistencia con procedimiento
        3. Si no encuentra -> devuelve error
        """
        try:
            # Buscar en FAISS
            resultados = self.faiss.buscar(embedding, umbral, 1)
            
            # Si no encuentra nada
            if not resultados:
                return RespuestaReconocimiento(
                    estado="NO_ENCONTRADO",
                    mensaje="Rostro no reconocido"
                )
            
            # Si encuentra, obtener el ID del estudiante
            alumno_id, similitud = resultados[0]
            
            # Registrar asistencia con el procedimiento
            resultado_proc = self.repo.registrar_asistencia(alumno_id)
            
            # Devolver el resultado del procedimiento
            return RespuestaReconocimiento(**resultado_proc)
            
        except Exception as e:
            print(f"Error en reconocimiento: {e}")
            return RespuestaReconocimiento(
                estado="ERROR",
                mensaje="Error interno del sistema"
            )
        





    #===================================== para tener actualziado los embeddings en FAISS =====================================#
    def listar_embeddings_info(self) -> dict:
        """Lista embeddings de BD y FAISS para debugging"""
        try:
            # Embeddings de BD
            embeddings_bd = self.repo.obtener_embeddings()
            
            # Info de FAISS
            faiss_info = {
                "total_embeddings": self.faiss.indice.ntotal,
                "mapeo_ids": dict(self.faiss.mapeo_ids)
            }
            
            return {
                "embeddings_bd": len(embeddings_bd),
                "embeddings_bd_lista": [{"alumno_id": e["alumno_id"]} for e in embeddings_bd],
                "faiss_info": faiss_info
            }
            
        except Exception as e:
            return {"error": str(e)}
    
    def sincronizar_faiss_completo(self) -> dict:
        """Recarga FAISS completamente desde la BD"""
        try:
            # Limpiar FAISS actual
            self.faiss.indice = faiss.IndexFlatIP(self.faiss.dimension_embedding)
            self.faiss.mapeo_ids = {}
            
            # Recargar desde BD
            if self.inicializar_faiss():
                return {"estado": "OK", "mensaje": "FAISS sincronizado completamente"}
            else:
                return {"estado": "ERROR", "mensaje": "Error sincronizando FAISS"}
                
        except Exception as e:
            return {"estado": "ERROR", "mensaje": f"Error: {str(e)}"}

    def agregar_embedding_a_faiss(self, embedding_id: int) -> dict:
        """Agrega un embedding específico a FAISS desde BD"""
        try:
            # Obtener el embedding específico de la BD
            embedding_data = self.repo.obtener_embedding_por_id(embedding_id)
            
            if not embedding_data:
                return {"estado": "ERROR", "mensaje": f"Embedding {embedding_id} no encontrado en BD"}
            
            # Agregar a FAISS con el embedding_id
            if self.faiss.agregar_embedding_con_id(
                embedding_data['embedding_id'], 
                embedding_data['alumno_id'], 
                embedding_data['vector']
            ):
                return {"estado": "OK", "mensaje": f"Embedding {embedding_id} agregado a FAISS"}
            else:
                return {"estado": "ERROR", "mensaje": "Error agregando a FAISS"}
                
        except Exception as e:
            return {"estado": "ERROR", "mensaje": f"Error: {str(e)}"}

    def eliminar_embedding_de_faiss(self, embedding_id: int) -> dict:
        """Elimina un embedding específico solo de FAISS"""
        try:
            if self.faiss.eliminar_embedding_por_id(embedding_id):
                return {"estado": "OK", "mensaje": f"Embedding {embedding_id} eliminado de FAISS"}
            else:
                return {"estado": "ERROR", "mensaje": f"Embedding {embedding_id} no encontrado en FAISS"}
                
        except Exception as e:
            return {"estado": "ERROR", "mensaje": f"Error: {str(e)}"}
        



    def limpiar_faiss_completo(self) -> dict:
        """Limpia FAISS completamente"""
        try:
            import os
            
            # Limpiar archivos
            if os.path.exists("./indice_faiss.bin"):
                os.remove("./indice_faiss.bin")
            if os.path.exists("./indice_faiss_metadata.pkl"):
                os.remove("./indice_faiss_metadata.pkl")
            
            # Reiniciar FAISS en memoria
            self.faiss.indice = faiss.IndexFlatIP(512)
            self.faiss.mapeo_ids = {}
            
            return {"estado": "OK", "mensaje": "FAISS limpiado completamente"}
            
        except Exception as e:
            return {"estado": "ERROR", "mensaje": f"Error: {str(e)}"}