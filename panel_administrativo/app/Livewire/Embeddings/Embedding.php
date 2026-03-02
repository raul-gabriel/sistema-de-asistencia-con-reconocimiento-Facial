<?php

namespace App\Livewire\Embeddings;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Livewire\Component;
use Livewire\WithPagination;

class Embedding extends Component
{
    use WithPagination;

    protected $paginationTheme = 'bootstrap';

    public $buscar = '';
    public $embedding_seleccionado = null;
    public $vector_visualizar = [];
    public $alumno_detalle = null;

    public function render()
    {
        $key = "%{$this->buscar}%";
        $embeddings = DB::table('embeddings_faciales as ef')
            ->join('alumno as a', 'ef.alumno_id', '=', 'a.id')
            ->join('horarios as h', 'a.id_horario', '=', 'h.id')
            ->select(
                'ef.id',
                'ef.alumno_id',
                'ef.vector_embedding',
                'a.codigo_modular',
                'a.nombres',
                'a.apellido_paterno',
                'a.apellido_materno',
                'a.dni',
                'a.grado',
                'a.seccion',
                'a.nivel',
                'a.estado',
                'h.nombre_horario'
            )
            ->where(function ($query) use ($key) {
                $query->where('a.codigo_modular', 'like', $key)
                    ->orWhere('a.nombres', 'like', $key)
                    ->orWhere('a.apellido_paterno', 'like', $key)
                    ->orWhere('a.apellido_materno', 'like', $key)
                    ->orWhere('a.dni', 'like', $key);
            })
            ->orderBy('a.apellido_paterno')
            ->paginate(10);

        return view('livewire.embeddings.embedding', ['embeddings' => $embeddings]);
    }

    public function visualizarEmbedding($id)
    {
        $embedding = DB::table('embeddings_faciales as ef')
            ->join('alumno as a', 'ef.alumno_id', '=', 'a.id')
            ->join('horarios as h', 'a.id_horario', '=', 'h.id')
            ->select(
                'ef.id',
                'ef.vector_embedding',
                'a.codigo_modular',
                'a.nombres',
                'a.apellido_paterno',
                'a.apellido_materno',
                'a.dni',
                'a.grado',
                'a.seccion',
                'a.nivel',
                'h.nombre_horario'
            )
            ->where('ef.id', $id)
            ->first();

        if ($embedding) {
            $this->embedding_seleccionado = $embedding->id;
            $this->alumno_detalle = $embedding;

            // Decodificar el vector (asumiendo que está en JSON)
            $vector = json_decode($embedding->vector_embedding, true);
            if (is_array($vector) && count($vector) === 512) {
                $this->vector_visualizar = $vector;
            } else {
                $this->vector_visualizar = [];
            }

            $this->dispatch('abrirModalVisualizacion');
        }
    }

    public function cerrarVisualizacion()
    {
        $this->embedding_seleccionado = null;
        $this->vector_visualizar = [];
        $this->alumno_detalle = null;
    }

    public function eliminarEmbedding($id)
    {
        try {
            $res = DB::select('CALL eliminar_embedding_faciales(?, @type, @message, @id_eliminado)', [$id]);
            $row = $res[0];

            if ($row->type == 1 && $row->id_eliminado) {
                Http::delete(env('FAISS_API_URL') . '/eliminar-faiss/' . $row->id_eliminado);
            }

            $this->dispatch('alerta', [
                'type' => $row->type,
                'message' => $row->message
            ]);
        } catch (\Exception $e) {
            // Error general
            $this->dispatch('alerta', [
                'type' => 0,
                'message' => 'Error al eliminar: ' . $e->getMessage()
            ]);
        }
    }


    public function getEstadisticasVector($vector)
    {
        if (empty($vector)) return null;

        return [
            'min' => round(min($vector), 4),
            'max' => round(max($vector), 4),
            'promedio' => round(array_sum($vector) / count($vector), 4),
            'desviacion' => round($this->calcularDesviacionEstandar($vector), 4),
            'dimension' => count($vector)
        ];
    }

    private function calcularDesviacionEstandar($vector)
    {
        $promedio = array_sum($vector) / count($vector);
        $suma_cuadrados = array_sum(array_map(function ($x) use ($promedio) {
            return pow($x - $promedio, 2);
        }, $vector));
        return sqrt($suma_cuadrados / count($vector));
    }

    public function getNormaVector($vector)
    {
        if (empty($vector)) return 0;
        return round(sqrt(array_sum(array_map(function ($x) {
            return $x * $x;
        }, $vector))), 4);
    }
}
