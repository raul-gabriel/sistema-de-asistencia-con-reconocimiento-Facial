<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;


class ApiController extends Controller
{
    /**
     * 🔐 LOGIN DE USUARIO
     */
    public function login(Request $request)
    {
        // Log para debug
        Log::info('API Login - Headers recibidos:', $request->headers->all());
        Log::info('API Login - Datos recibidos:', $request->all());

        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        $username = $request->input('username');
        $password = $request->input('password');

        try {
            $result = DB::select('CALL verificar_usuario(?, ?)', [$username, $password]);

            if (!empty($result) && $result[0]->status == 1) {
                Log::info('Login exitoso para usuario:', ['username' => $username]);

                return response()->json([
                    'success' => true,
                    'message' => 'Inicio de sesión exitoso.',
                    'user' => [
                        'id' => $result[0]->id,
                        'nombres' => $result[0]->nombres,
                        'apellidos' => $result[0]->apellidos,
                        'rol' => $result[0]->rol,
                    ]
                ]);
            } else {
                Log::warning('Login fallido para usuario:', ['username' => $username]);

                return response()->json([
                    'success' => false,
                    'message' => 'Credenciales incorrectas.',
                ], 401);
            }
        } catch (\Exception $e) {
            Log::error('Error en login:', ['error' => $e->getMessage(), 'username' => $username]);

            return response()->json([
                'success' => false,
                'message' => 'Error del servidor.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * 🔍 BUSCAR ALUMNOS
     */
    public function buscarAlumnos(Request $request)
    {
        Log::info('API Buscar alumnos - Parámetros:', $request->all());

        $filtro = $request->input('buscar', '');

        if (empty($filtro)) {
            return response()->json([
                'error' => 'Parámetro buscar es requerido'
            ], 400);
        }

        try {
            $resultados = DB::select("CALL buscar_alumno(?)", [$filtro]);

            Log::info('Buscar alumnos - Resultados:', ['count' => count($resultados)]);

            return response()->json($resultados);
        } catch (\Exception $e) {
            Log::error('Error en buscar alumnos:', [
                'filtro' => $filtro,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'error' => 'Error al buscar alumnos: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * 💾 GUARDAR EMBEDDING FACIAL
     */
    /*public function guardarEmbedding(Request $request)
    {
        Log::info('API Guardar embedding - Datos recibidos:', [
            'keys' => array_keys($request->all()),
            'id_alumno' => $request->input('id_alumno'),
            'embedding_length' => is_array($request->input('embedding')) ? count($request->input('embedding')) : 'no_array'
        ]);

        $request->validate([
            'id_alumno' => 'required|integer|min:1',
            'embedding' => 'required|array|min:1',
        ]);

        $idAlumno = $request->input('id_alumno');
        $embedding = $request->input('embedding');
        $embeddingJson = json_encode($embedding, JSON_UNESCAPED_UNICODE);

        try {
            // Verificar si ya existe embedding para este alumno
            $existingEmbedding = DB::select('SELECT id FROM embeddings_faciales WHERE alumno_id = ?', [$idAlumno]);

            if (!empty($existingEmbedding)) {
                // Actualizar embedding existente (sin updated_at)
                DB::update('UPDATE embeddings_faciales SET vector_embedding = ? WHERE alumno_id = ?', [
                    $embeddingJson,
                    $idAlumno
                ]);

                Log::info('Embedding actualizado:', ['alumno_id' => $idAlumno]);
                $mensaje = 'Embedding actualizado correctamente';
            } else {
                // Crear nuevo embedding (sin timestamps)
                DB::insert('INSERT INTO embeddings_faciales (alumno_id, vector_embedding) VALUES (?, ?)', [
                    $idAlumno,
                    $embeddingJson
                ]);

                Log::info('Embedding creado:', ['alumno_id' => $idAlumno]);
                $mensaje = 'Embedding guardado correctamente';
            }

            return response()->json([
                'mensaje' => $mensaje,
                'alumno_id' => $idAlumno,
                'embedding_dimensions' => count($embedding)
            ]);
        } catch (\Exception $e) {
            Log::error('Error al guardar embedding:', [
                'alumno_id' => $idAlumno,
                'embedding_length' => count($embedding),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'error' => 'Error al guardar embedding: ' . $e->getMessage()
            ], 500);
        }
    }*/

    public function guardarEmbedding(Request $request)
    {


        $request->validate([
            'id_alumno' => 'required|integer|min:1',
            'embedding' => 'required|array|min:1',
        ]);

        $idAlumno = $request->input('id_alumno');
        $embedding = $request->input('embedding');
        $embeddingJson = json_encode($embedding, JSON_UNESCAPED_UNICODE);

        try {
            // Llamar al procedimiento almacenado
            $result = DB::select('CALL sp_guardar_embedding(?, ?, @embedding_id, @mensaje)', [
                $idAlumno,
                $embeddingJson
            ]);

            // Obtener los valores de salida
            $outputs = DB::select('SELECT @embedding_id as embedding_id, @mensaje as mensaje');
            $output = $outputs[0];

            // Verificar si hubo error
            if ($output->embedding_id == -1) {
                throw new \Exception($output->mensaje);
            }

            $url = env('FAISS_API_URL') . '/agregar-faiss/' . $output->embedding_id;
            $response = Http::post($url);

            return response()->json([
                'mensaje' => $output->mensaje,
                'alumno_id' => $idAlumno,
                'embedding_id' => $output->embedding_id,
                'embedding_dimensions' => count($embedding)
            ]);
        } catch (\Exception $e) {
            Log::error('Error al guardar embedding:', [
                'alumno_id' => $idAlumno,
                'embedding_length' => count($embedding),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'error' => 'Error al guardar embedding: ' . $e->getMessage()
            ], 500);
        }
    }
}
