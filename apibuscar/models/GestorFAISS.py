import faiss
import numpy as np
import os
import pickle
from typing import List, Tuple

class GestorFAISS:
    def __init__(self, dimension_embedding: int = 512, ruta_indice: str = "./indice_faiss.bin"):
        self.dimension_embedding = dimension_embedding
        self.ruta_indice = ruta_indice
        self.ruta_metadata = ruta_indice.replace('.bin', '_metadata.pkl')
        
        # Crear índice FAISS optimizado para similitud coseno
        self.indice = faiss.IndexFlatIP(dimension_embedding)
        self.mapeo_ids = {}  # índice FAISS -> id_alumno

        self.cargar_indice()
    
    def normalizar_embedding(self, embedding: np.ndarray) -> np.ndarray:
        # Normaliza el embedding para usar similitud coseno
        norma = np.linalg.norm(embedding)
        if norma == 0:
            return embedding
        return embedding / norma
    
    def agregar_embedding(self, id_estudiante: int, embedding: List[float]) -> bool:
        # Agrega un embedding al índice FAISS
        try:
            embedding_np = np.array(embedding, dtype=np.float32).reshape(1, -1)
            embedding_normalizado = self.normalizar_embedding(embedding_np)
            
            id_faiss = self.indice.ntotal
            self.indice.add(embedding_normalizado)
            self.mapeo_ids[id_faiss] = id_estudiante
            
            self.guardar_indice()
            return True
        except Exception as e:
            print(f"Error al agregar embedding: {e}")
            return False
    
    def buscar(self, embedding: List[float], umbral: float = 0.7, top_k: int = 1) -> List[Tuple[int, float]]:
        """Busca los embeddings más similares y devuelve alumno_id"""
        try:
            if self.indice.ntotal == 0:
                return []
            
            embedding_np = np.array(embedding, dtype=np.float32).reshape(1, -1)
            embedding_normalizado = self.normalizar_embedding(embedding_np)
            
            puntajes, indices = self.indice.search(embedding_normalizado, min(top_k, self.indice.ntotal))
            
            resultados = []
            for puntaje, indice in zip(puntajes[0], indices[0]):
                if indice == -1:
                    continue
                if puntaje >= umbral:
                    # CAMBIO: ahora mapeo_ids contiene diccionarios
                    data = self.mapeo_ids.get(indice)
                    if data and 'alumno_id' in data:
                        alumno_id = data['alumno_id']
                        resultados.append((alumno_id, float(puntaje)))
            
            return sorted(resultados, key=lambda x: x[1], reverse=True)
        except Exception as e:
            print(f"Error en la búsqueda: {e}")
            return []
    
    def guardar_indice(self):
        # Guarda el índice FAISS y el mapeo
        try:
            faiss.write_index(self.indice, self.ruta_indice)
            with open(self.ruta_metadata, 'wb') as archivo:
                pickle.dump(self.mapeo_ids, archivo)
        except Exception as e:
            print(f"Error al guardar el índice: {e}")
    
    def cargar_indice(self):
        # Carga el índice y el mapeo desde disco
        try:
            if os.path.exists(self.ruta_indice):
                self.indice = faiss.read_index(self.ruta_indice)
            if os.path.exists(self.ruta_metadata):
                with open(self.ruta_metadata, 'rb') as archivo:
                    self.mapeo_ids = pickle.load(archivo)
        except Exception as e:
            print(f"Error al cargar el índice: {e}")
            self.indice = faiss.IndexFlatIP(self.dimension_embedding)
            self.mapeo_ids = {}



    # =================================para tener actualizado los embeddings en FAISS==================================
    def agregar_embedding_con_id(self, embedding_id: int, alumno_id: int, embedding: List[float]) -> bool:
        """Agrega un embedding al índice FAISS usando embedding_id como clave"""
        try:
            embedding_np = np.array(embedding, dtype=np.float32).reshape(1, -1)
            embedding_normalizado = self.normalizar_embedding(embedding_np)
            
            id_faiss = self.indice.ntotal
            self.indice.add(embedding_normalizado)
            # CAMBIO: ahora mapeo embedding_id -> alumno_id
            self.mapeo_ids[id_faiss] = {'embedding_id': embedding_id, 'alumno_id': alumno_id}
            
            self.guardar_indice()
            return True
        except Exception as e:
            print(f"Error al agregar embedding: {e}")
            return False
    
    
    def eliminar_embedding_por_id(self, embedding_id: int) -> bool:
        """Elimina un embedding específico del índice FAISS"""
        try:
            # Encontrar el índice FAISS del embedding
            indice_faiss = None
            for idx, data in self.mapeo_ids.items():
                if data['embedding_id'] == embedding_id:
                    indice_faiss = idx
                    break
            
            if indice_faiss is None:
                print(f"Embedding {embedding_id} no encontrado en FAISS")
                return False
            
            # Reconstruir el índice sin este embedding
            self._reconstruir_indice_sin(indice_faiss)
            self.guardar_indice()
            return True
            
        except Exception as e:
            print(f"Error eliminando embedding de FAISS: {e}")
            return False




    def _reconstruir_indice_sin(self, indice_eliminar: int):
        """Reconstruye el índice FAISS excluyendo un embedding específico"""
        if self.indice.ntotal <= 1:
            self.indice = faiss.IndexFlatIP(self.dimension_embedding)
            self.mapeo_ids = {}
            return
        
        embeddings_actuales = []
        nuevo_mapeo = {}
        nuevo_indice = 0
        
        for idx in range(self.indice.ntotal):
            if idx != indice_eliminar:
                embedding = self.indice.reconstruct(idx)
                embeddings_actuales.append(embedding)
                nuevo_mapeo[nuevo_indice] = self.mapeo_ids[idx]
                nuevo_indice += 1
        
        self.indice = faiss.IndexFlatIP(self.dimension_embedding)
        self.mapeo_ids = nuevo_mapeo
        
        if embeddings_actuales:
            embeddings_np = np.array(embeddings_actuales)
            self.indice.add(embeddings_np)