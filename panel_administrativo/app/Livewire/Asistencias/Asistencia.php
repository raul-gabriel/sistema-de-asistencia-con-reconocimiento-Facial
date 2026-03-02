<?php

namespace App\Livewire\Asistencias;

use Illuminate\Support\Facades\DB;
use Livewire\Component;

class Asistencia extends Component
{
    public $fechaSeleccionada = '';
    public $gradoSeleccionado = '';
    public $nivelSeleccionado = '';
    public $fechasDisponibles = [];
    public $asistencias = [];
    public $loading = false;

    public $grados = [
        '1°' => 'Primero',
        '2°' => 'Segundo', 
        '3°' => 'Tercero',
        '4°' => 'Cuarto',
        '5°' => 'Quinto',
        '6°' => 'Sexto'
    ];

    public $niveles = [
        'primaria' => 'Primaria',
        'secundaria' => 'Secundaria'
    ];

    public function mount()
    {
        $this->cargarFechasDisponibles();
    }

    public function cargarFechasDisponibles()
    {
        $this->fechasDisponibles = DB::select('CALL ListarFechasAsistencias()');
    }

    public function updatedFechaSeleccionada()
    {
        $this->buscarAsistencias();
    }

    public function updatedGradoSeleccionado()
    {
        $this->buscarAsistencias();
    }

    public function updatedNivelSeleccionado()
    {
        $this->buscarAsistencias();
    }

    public function buscarAsistencias()
    {
        if ($this->fechaSeleccionada && $this->gradoSeleccionado && $this->nivelSeleccionado) {
            $this->loading = true;
            
            try {
                $this->asistencias = DB::select(
                    'CALL sp_listado_asistencias(?, ?, ?)', 
                    [$this->fechaSeleccionada, $this->gradoSeleccionado, $this->nivelSeleccionado]
                );
            } catch (\Exception $e) {
                session()->flash('error', 'Error al consultar asistencias: ' . $e->getMessage());
                $this->asistencias = [];
            }
            
            $this->loading = false;
        }
    }

    public function limpiarFiltros()
    {
        $this->fechaSeleccionada = '';
        $this->gradoSeleccionado = '';
        $this->nivelSeleccionado = '';
        $this->asistencias = [];
    }

    public function exportarExcel()
    {
        // Aquí puedes implementar la exportación a Excel
        session()->flash('info', 'Funcionalidad de exportación pendiente de implementar');
    }

    public function render()
    {
        return view('livewire.asistencias.asistencia');
    }
}