<?php

namespace App\Livewire\Alumnos;

use Illuminate\Support\Facades\DB;
use Livewire\Component;
use Livewire\WithPagination;

class Alumno extends Component
{
    use WithPagination;

    protected $paginationTheme = 'bootstrap';

    public $regis_update = 'Registrar';
    public $buscar = '';
    public $id_alumno;
    public $codigo_modular, $nombres, $apellido_paterno, $apellido_materno, $dni;
    public $grado, $seccion, $nivel, $apoderado_nombre, $apoderado_telefono;
    public $id_horario, $estado;

    public $fecha_seleccionada;






    // Para cargar horarios en el select
    public $horarios = [];

    protected $rules = [
        'codigo_modular' => 'required|max:20',
        'nombres' => 'required|max:100',
        'apellido_paterno' => 'required|max:100',
        'apellido_materno' => 'required|max:100',
        'dni' => 'required|size:8|regex:/^[0-9]{8}$/',
        'grado' => 'required|in:1°,2°,3°,4°,5°,6°',
        'seccion' => 'required|in:A,B,C,D,E',
        'nivel' => 'required|in:primaria,secundaria',
        'apoderado_nombre' => 'required|max:150',
        'apoderado_telefono' => 'nullable|max:15|regex:/^[0-9]{9}$/',
        'id_horario' => 'required|exists:horarios,id',
        'estado' => 'required|in:matriculado,retirado,trasladado',
    ];

    protected $messages = [
        'codigo_modular.required' => 'El código modular es obligatorio.',
        'nombres.required' => 'Los nombres son obligatorios.',
        'apellido_paterno.required' => 'El apellido paterno es obligatorio.',
        'apellido_materno.required' => 'El apellido materno es obligatorio.',
        'dni.required' => 'El DNI es obligatorio.',
        'dni.size' => 'El DNI debe tener exactamente 8 dígitos.',
        'dni.regex' => 'El DNI solo debe contener números.',
        'grado.required' => 'Debe seleccionar un grado.',
        'seccion.required' => 'Debe seleccionar una sección.',
        'nivel.required' => 'Debe seleccionar un nivel.',
        'apoderado_nombre.required' => 'El nombre del apoderado es obligatorio.',
        'apoderado_telefono.regex' => 'El teléfono debe tener 9 dígitos.',
        'id_horario.required' => 'Debe seleccionar un horario.',
        'id_horario.exists' => 'El horario seleccionado no existe.',
        'estado.required' => 'Debe seleccionar un estado.',
    ];

    public function mount()
    {
        $this->fecha_seleccionada = now()->format('Y-m-d');
        $this->cargarHorarios();

    }

    public function cargarHorarios()
    {
        $this->horarios = DB::table('horarios')
            ->select('id', 'nombre_horario', 'hora_inicio', 'hora_fin')
            ->get();
    }

    public function render()
    {
        $key = "%{$this->buscar}%";
        $alumnos = DB::table('alumno as a')
            ->join('horarios as h', 'a.id_horario', '=', 'h.id')
            ->select('a.*', 'h.nombre_horario')
            ->where(function ($query) use ($key) {
                $query->where('a.codigo_modular', 'like', $key)
                    ->orWhere('a.nombres', 'like', $key)
                    ->orWhere('a.apellido_paterno', 'like', $key)
                    ->orWhere('a.apellido_materno', 'like', $key)
                    ->orWhere('a.dni', 'like', $key);
            })
            ->paginate(10);

        return view('livewire.alumnos.alumno', ['alumnos' => $alumnos]);
    }

    public function limpiar()
    {
        $this->reset([
            'id_alumno',
            'codigo_modular',
            'nombres',
            'apellido_paterno',
            'apellido_materno',
            'dni',
            'grado',
            'seccion',
            'nivel',
            'apoderado_nombre',
            'apoderado_telefono',
            'id_horario',
            'estado'
        ]);
        $this->regis_update = 'Registrar';
        $this->resetValidation();
    }

    public function recuperar($id)
    {
        $res = DB::select('CALL ObtenerAlumno(?)', [$id]);
        if (!empty($res)) {
            $a = $res[0];
            $this->id_alumno = $a->id;
            $this->codigo_modular = $a->codigo_modular;
            $this->nombres = $a->nombres;
            $this->apellido_paterno = $a->apellido_paterno;
            $this->apellido_materno = $a->apellido_materno;
            $this->dni = $a->dni;
            $this->grado = $a->grado;
            $this->seccion = $a->seccion;
            $this->nivel = $a->nivel;
            $this->apoderado_nombre = $a->apoderado_nombre;
            $this->apoderado_telefono = $a->apoderado_telefono;
            $this->id_horario = $a->id_horario;
            $this->estado = $a->estado;
            $this->regis_update = 'Actualizar';
            $this->resetValidation();
        }
    }

    public function registrar()
    {
        $validated = $this->validate();

        if ($this->regis_update === 'Registrar') {
            $res = DB::select('CALL CrearAlumno(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                $this->codigo_modular,
                $this->nombres,
                $this->apellido_paterno,
                $this->apellido_materno,
                $this->dni,
                $this->grado,
                $this->seccion,
                $this->nivel,
                $this->apoderado_nombre,
                $this->apoderado_telefono,
                $this->id_horario,
                $this->estado
            ]);
        } else {
            $res = DB::select('CALL ActualizarAlumno(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                $this->id_alumno,
                $this->codigo_modular,
                $this->nombres,
                $this->apellido_paterno,
                $this->apellido_materno,
                $this->dni,
                $this->grado,
                $this->seccion,
                $this->nivel,
                $this->apoderado_nombre,
                $this->apoderado_telefono,
                $this->id_horario,
                $this->estado
            ]);
        }

        // Los SP devuelven un SELECT con mensaje y cod
        $row = $res[0];
        $this->dispatch('alerta', ['type' => $row->cod, 'message' => $row->mensaje]);

        if ($row->cod == 1) {
            $this->dispatch('cerrarModal');
            $this->limpiar();
        }
    }

    public function destroy($id)
    {
        $res = DB::select('CALL EliminarAlumno(?)', [$id]);
        $row = $res[0];
        $this->dispatch('alerta', ['type' => $row->cod, 'message' => $row->mensaje]);
    }

    public function getNombreCompleto($nombres, $apellido_paterno, $apellido_materno)
    {
        return trim($apellido_paterno . ' ' . $apellido_materno . ', ' . $nombres);
    }
}
