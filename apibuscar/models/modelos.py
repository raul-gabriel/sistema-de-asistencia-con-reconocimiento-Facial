from pydantic import BaseModel
from typing import List, Optional

class SolicitudReconocimiento(BaseModel):
    """Lo que llega del frontend"""
    embedding: List[float]
    umbral: Optional[float] = 0.7

class RespuestaReconocimiento(BaseModel):
    """Lo que devuelve la API - mismo formato que el procedimiento"""
    estado: str
    mensaje: str
    nombres: Optional[str] = None
    apellido_paterno: Optional[str] = None
    apellido_materno: Optional[str] = None
    nivel: Optional[str] = None
