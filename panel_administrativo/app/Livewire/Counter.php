<?php

namespace App\Livewire;

use Livewire\Component;

class Counter extends Component
{
    public $count = 0;
    public $nombre = '';
    public $mensajes = [];

    public function increment()
    {
        $this->count++;
    }

    public function decrement()
    {
        $this->count--;
    }

    

    public function agregarMensaje()
    {
        if (!empty($this->nombre)) {
            $this->mensajes[] = [
                'nombre' => $this->nombre,
                'mensaje' => "Hola desde {$this->nombre}! Contador: {$this->count}",
                'tiempo' => now()->format('H:i:s')
            ];
            $this->nombre = '';
        }
    }

    public function render()
    {
        return view('livewire.counter');
    }
}