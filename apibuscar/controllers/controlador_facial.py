from fastapi import APIRouter, HTTPException
from models.modelos import SolicitudReconocimiento, RespuestaReconocimiento

class ControladorFacial:
    def __init__(self, servicio_reconocimiento):
        self.router = APIRouter()
        self.servicio = servicio_reconocimiento
        self._definir_rutas()
    
    def _definir_rutas(self):
        
        @self.router.post("/reconocer", response_model=RespuestaReconocimiento)
        async def reconocer_y_registrar(solicitud: SolicitudReconocimiento):
            """
            ENDPOINT PRINCIPAL: Recibe embedding y registra asistencia
            """
            try:
                if not solicitud.embedding:
                    raise HTTPException(status_code=400, detail="Embedding vacío")
                
                if len(solicitud.embedding) != 512:
                    raise HTTPException(status_code=400, detail="Embedding debe ser de 512 dimensiones")
                
                resultado = self.servicio.reconocer_estudiante(
                    solicitud.embedding, 
                    solicitud.umbral
                )


                #imprimir el embedding completo en un archivo para testear
                #with open("embedding_completo.txt", "w") as f:
                #    f.write(str(solicitud.embedding))

                return resultado
                
            except HTTPException:
                raise
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Error: {str(e)}")
            





        #=====================================para tener actualizado los embeddings en FAISS ========================
        @self.router.get("/listar-embeddings")
        async def listar_embeddings():
            """Lista todos los embeddings en BD y FAISS"""
            try:
                resultado = self.servicio.listar_embeddings_info()
                return resultado
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Error: {str(e)}")
    
        @self.router.post("/sincronizar-faiss")
        async def sincronizar_faiss_completo():
            """Sincroniza FAISS completamente desde BD"""
            try:
                resultado = self.servicio.sincronizar_faiss_completo()
                return resultado
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

        @self.router.post("/agregar-faiss/{embedding_id}")
        async def agregar_embedding_faiss(embedding_id: int):
            """Agrega un embedding específico a FAISS"""
            try:
                resultado = self.servicio.agregar_embedding_a_faiss(embedding_id)
                if resultado["estado"] == "ERROR":
                    raise HTTPException(status_code=400, detail=resultado["mensaje"])
                return resultado
            except HTTPException:
                raise
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

        @self.router.delete("/eliminar-faiss/{embedding_id}")
        async def eliminar_embedding_faiss(embedding_id: int):
            """Elimina un embedding específico de FAISS"""
            try:
                resultado = self.servicio.eliminar_embedding_de_faiss(embedding_id)
                if resultado["estado"] == "ERROR":
                    raise HTTPException(status_code=400, detail=resultado["mensaje"])
                return resultado
            except HTTPException:
                raise
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Error: {str(e)}")
            


        # Agrega este endpoint temporal para limpiar
        @self.router.delete("/limpiar-faiss")
        async def limpiar_faiss_completo():
            """LIMPIA FAISS COMPLETAMENTE - Solo para debugging"""
            try:
                resultado = self.servicio.limpiar_faiss_completo()
                return resultado
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Error: {str(e)}")