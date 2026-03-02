from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
from dotenv import load_dotenv

from config.database import ConfigBaseDatos
from models.GestorFAISS import GestorFAISS
from repositories.repositorio_estudiante import RepositorioEstudiante
from services.servicio_reconocimiento import ServicioReconocimiento
from controllers.controlador_facial import ControladorFacial

load_dotenv()

app = FastAPI(title="API Reconocimiento Facial", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inicializar componentes
config_bd = ConfigBaseDatos()
gestor_faiss = GestorFAISS(512, "./indice_faiss.bin")
repo_estudiante = RepositorioEstudiante(config_bd)
servicio_reconocimiento = ServicioReconocimiento(repo_estudiante, gestor_faiss)
controlador = ControladorFacial(servicio_reconocimiento)

@app.on_event("startup")
async def inicio():
    """Inicializa la aplicación"""
    if not config_bd.crear_pool():
        raise Exception("Error creando pool de BD")
    
    # NUEVO: Limpiar y sincronizar FAISS al iniciar
    print("Limpiando y sincronizando FAISS con BD...")
    
    # Limpiar FAISS completamente
    servicio_reconocimiento.limpiar_faiss_completo()
    
    # Sincronizar desde BD (datos frescos)
    if not servicio_reconocimiento.inicializar_faiss():
        print("Advertencia: FAISS iniciado vacío")
    else:
        print("FAISS sincronizado correctamente con BD")
    
    print("API iniciada correctamente")

@app.on_event("shutdown")
async def cierre():
    """Guarda el índice FAISS al cerrar"""
    gestor_faiss.guardar_indice()
    print("API cerrada")

@app.get("/")
async def raiz():
    return {
        "mensaje": "API Reconocimiento Facial",
        "endpoint_principal": "/reconocer"
    }

# Incluir rutas
app.include_router(controlador.router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)