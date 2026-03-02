<?php

namespace App\Http\Controllers\Auth;


use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class LoginController extends Controller
{
    public function index()
    {
        return view('login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required',
            'password' => 'required|min:6',
        ]);

        $user = User::verificarCredenciales($request->email, $request->password);

        if ($user) {
            Auth::login($user);
            return redirect()->route('inicio');
        } else {
            return back()->withErrors([
                'email' => 'Las credenciales proporcionadas no son válidas.',
            ]);
        }
    }

    // Cerrar sesion
    public function logout()
    {
        Auth::logout();
        return redirect('/login');
    }



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
}
