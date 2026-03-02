<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\DB;

class User extends Authenticatable
{
    use HasFactory, Notifiable;

    // Nombre correcto de la tabla
    protected $table = 'usuario';

    // No usar timestamps si no hay created_at y updated_at
    public $timestamps = false;

    // Clave primaria
    protected $primaryKey = 'id';

    // Campos que pueden asignarse masivamente
    protected $fillable = [
        'id',
        'username',
        'password_hash',
        'nombres',
        'apellidos',
        'rol',
        'estado',
    ];

    // Campos ocultos al convertir a JSON
    protected $hidden = [
        'password_hash',
    ];

    // Encriptar automáticamente el password al guardarlo
    public function setPasswordHashAttribute($value)
    {
        $this->attributes['password_hash'] = password_hash($value, PASSWORD_BCRYPT);
    }

    /**
     * Verifica credenciales con el procedimiento almacenado.
     */
    public static function verificarCredenciales($email, $password)
    {
        $result = DB::select('CALL verificar_usuario(?, ?)', [$email, $password]);
    
        if (!empty($result) && $result[0]->status == 1) {
            // Buscar el usuario en la base de datos usando su ID
            return self::find($result[0]->id);
        }
    
        return null;
    }
    
}
