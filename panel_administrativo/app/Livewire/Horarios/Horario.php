<?php

namespace App\Livewire\Horarios;

use Illuminate\Support\Facades\DB;
use Livewire\Component;
use Livewire\WithPagination;

class Horario extends Component
{
    use WithPagination;

    protected $paginationTheme = 'bootstrap';

    public $regis_update = 'Registrar';
    public $buscar = '';
    public $id_horario;
    public $nombre_horario, $hora_inicio, $hora_fin, $minutos_tolerancia_entrada;

    protected $rules = [
        'nombre_horario' => 'required|max:100',
        'hora_inicio' => 'required|date_format:H:i',
        'hora_fin' => 'required|date_format:H:i|after:hora_inicio',
        'minutos_tolerancia_entrada' => 'required|integer|min:0|max:60',
    ];

    protected $messages = [
        'nombre_horario.required' => 'El nombre del horario es obligatorio.',
        'hora_inicio.required' => 'La hora de inicio es obligatoria.',
        'hora_inicio.date_format' => 'La hora de inicio debe tener formato HH:MM.',
        'hora_fin.required' => 'La hora de fin es obligatoria.',
        'hora_fin.date_format' => 'La hora de fin debe tener formato HH:MM.',
        'hora_fin.after' => 'La hora de fin debe ser posterior a la hora de inicio.',
        'minutos_tolerancia_entrada.required' => 'Los minutos de tolerancia son obligatorios.',
        'minutos_tolerancia_entrada.integer' => 'Los minutos deben ser un número entero.',
        'minutos_tolerancia_entrada.min' => 'Los minutos no pueden ser negativos.',
        'minutos_tolerancia_entrada.max' => 'Los minutos no pueden ser más de 60.',
    ];

    public function render()
    {
        $key = "%{$this->buscar}%";
        $horarios = DB::table('horarios')
            ->where('nombre_horario', 'like', $key)
            ->paginate(10);

        return view('livewire.horarios.horario', ['horarios' => $horarios]);
    }

    public function limpiar()
    {
        $this->reset(['id_horario', 'nombre_horario', 'hora_inicio', 'hora_fin', 'minutos_tolerancia_entrada']);
        $this->regis_update = 'Registrar';
        $this->resetValidation();
    }

    public function recuperar($id)
    {
        $res = DB::select('CALL ObtenerHorario(?)', [$id]);
        if (!empty($res)) {
            $h = $res[0];
            $this->id_horario = $h->id;
            $this->nombre_horario = $h->nombre_horario;
            $this->hora_inicio = substr($h->hora_inicio, 0, 5);
            $this->hora_fin = substr($h->hora_fin, 0, 5);
            $this->minutos_tolerancia_entrada = $h->minutos_tolerancia_entrada;
            $this->regis_update = 'Actualizar';
            $this->resetValidation();
        }
    }

    public function registrar()
    {
        $validated = $this->validate();

        if ($this->regis_update === 'Registrar') {
            $res = DB::select('CALL CrearHorario(?, ?, ?, ?)', [
                $this->nombre_horario,
                $this->hora_inicio,
                $this->hora_fin,
                $this->minutos_tolerancia_entrada
            ]);
        } else {
            $res = DB::select('CALL ActualizarHorario(?, ?, ?, ?, ?)', [
                $this->id_horario,
                $this->nombre_horario,
                $this->hora_inicio,
                $this->hora_fin,
                $this->minutos_tolerancia_entrada
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
        $res = DB::select('CALL EliminarHorario(?)', [$id]);
        $row = $res[0];
        $this->dispatch('alerta', ['type' => $row->cod, 'message' => $row->mensaje]);
    }

    public function calcularDuracion($inicio, $fin)
    {
        $inicio = \Carbon\Carbon::createFromFormat('H:i:s', $inicio);
        $fin = \Carbon\Carbon::createFromFormat('H:i:s', $fin);
        $duracion = $inicio->diffInMinutes($fin);
        $horas = intval($duracion / 60);
        $minutos = $duracion % 60;
        return "{$horas}h {$minutos}m";
    }
}
