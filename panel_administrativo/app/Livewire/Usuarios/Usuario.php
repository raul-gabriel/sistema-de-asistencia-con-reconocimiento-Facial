<?php

namespace App\Livewire\Usuarios;

use Illuminate\Support\Facades\DB;
use Livewire\Component;
use Livewire\WithPagination;

class Usuario extends Component
{
    use WithPagination;

    protected $paginationTheme = 'bootstrap';

    public $regis_update = 'Registrar';
    public $buscar = '';
    public $id_usuario;
    public $username, $password, $nombres, $apellidos, $rol, $estado;



    public function render()
    {
        $key = "%{$this->buscar}%";
        $usuarios = DB::table('usuario')
            ->where('username', 'like', $key)
            ->orWhere('nombres', 'like', $key)
            ->orWhere('apellidos', 'like', $key)
            ->paginate(10);

        return view('livewire.usuarios.usuario', ['usuarios' => $usuarios]);
    }

    public function limpiar()
    {
        $this->reset(['id_usuario', 'username', 'password', 'nombres', 'apellidos', 'rol', 'estado']);
        $this->regis_update = 'Registrar';
        $this->resetValidation();
    }

    public function recuperar($id)
    {
        $res = DB::select('CALL ObtenerUsuario(?)', [$id]);
        if (!empty($res)) {
            $u = $res[0];
            $this->id_usuario = $u->id;
            $this->username = $u->username;
            $this->nombres = $u->nombres;
            $this->apellidos = $u->apellidos;
            $this->rol = $u->rol;
            $this->estado = $u->estado;
            $this->password = ''; // No mostrar la contraseña por seguridad
            $this->regis_update = 'Actualizar';
            $this->resetValidation();
        }
    }

    public function registrar()
    {
        $rules = [
            'username' => 'required|max:50',
            'nombres' => 'required|max:100',
            'apellidos' => 'required|max:100',
            'rol' => 'required|in:admin,docente,auxiliar',
            'estado' => 'required|in:activo,inactivo',
        ];

        if ($this->regis_update === 'Registrar') {
            $rules['password'] = 'required|min:6';
        } else {
            if ($this->password && $this->password !== '-') {
                $rules['password'] = 'min:6';
            }
        }

        $validated = $this->validate($rules);

        if ($this->regis_update === 'Registrar') {
            $res = DB::select('CALL CrearUsuario(?, ?, ?, ?, ?, ?)', [
                $this->username,
                $this->password,
                $this->nombres,
                $this->apellidos,
                $this->rol,
                $this->estado
            ]);
        } else {
            $password = $this->password ?: '-';

            $res = DB::select('CALL ActualizarUsuario(?, ?, ?, ?, ?, ?, ?)', [
                $this->id_usuario,
                $this->username,
                $password,
                $this->nombres,
                $this->apellidos,
                $this->rol,
                $this->estado
            ]);
        }

        $row = $res[0];
        $this->dispatch('alerta', ['type' => $row->cod, 'message' => $row->mensaje]);

        if ($row->cod == 1) {
            $this->dispatch('cerrarModal');
            $this->limpiar();
        }
    }


    public function destroy($id)
    {
        $res = DB::select('CALL EliminarUsuario(?)', [$id]);
        $row = $res[0];
        $this->dispatch('alerta', ['type' => $row->cod, 'message' => $row->mensaje]);
    }
}
