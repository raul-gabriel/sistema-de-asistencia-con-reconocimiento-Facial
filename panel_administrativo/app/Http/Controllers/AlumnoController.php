<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AlumnoController extends Controller
{
    //

    public function apiLogin(Request $request)
    {
    

        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        $username = $request->input('username');
        $password = $request->input('password');

        try {
            $result = DB::select('CALL verificar_usuario(?, ?)', [$username, $password]);

            if (!empty($result) && $result[0]->status == 1) {
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
                return response()->json([
                    'success' => false,
                    'message' => 'Credenciales incorrectas.',
                ], 401);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error del servidor.',
                'error' => $e->getMessage()
            ], 500);
        }
    }



    
    public function buscar(Request $request)
    {
        $filtro = $request->input('buscar');
        $resultados = DB::select("CALL buscar_alumno(?)", [$filtro]);
        return response()->json($resultados);
    }

    public function guardarEmbedding(Request $request)
    {
        if (!$request->has(['id_alumno', 'embedding'])) {
            return response()->json(['error' => 'Faltan datos'], 400);
        }

        $idAlumno = $request->input('id_alumno');
        $embedding = json_encode($request->input('embedding'), JSON_UNESCAPED_UNICODE);

        try {
            DB::insert('INSERT INTO embeddings_faciales (alumno_id, vector_embedding) VALUES (?, ?)', [
                $idAlumno,
                $embedding
            ]);

            return response()->json(['mensaje' => 'Embedding guardado']);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Error al guardar: ' . $e->getMessage()], 500);
        }
    }
}
