<div class="container py-4">

    <!-- Card Principal -->
    <div class="card shadow-lg mb-4">
        <div class="card-body text-center">
            <h2 class="card-title h3 mb-4">🔥 Livewire + Bootstrap 5</h2>

            <!-- Counter Display -->
            <div class="mb-4">
                <div class="d-inline-flex align-items-center justify-content-center rounded-circle bg-primary text-white fs-1 fw-bold" style="width: 8rem; height: 8rem;">
                    {{ $count }}
                </div>
                <p class="text-muted mt-2">Contador actual</p>
            </div>

            <!-- Botones -->
            <div class="d-flex justify-content-center gap-3 mb-3">
                <button wire:click="decrement" class="btn btn-danger px-4 py-2 fw-semibold">
                    - Decrementar
                </button>

                <button wire:click="increment" class="btn btn-success px-4 py-2 fw-semibold">
                    + Incrementar
                </button>
            </div>
        </div>
    </div>

    <!-- Formulario -->
    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <h3 class="h5 mb-3">Agregar Mensaje</h3>

            <div class="row g-2">
                <div class="col">
                    <input wire:model="nombre" type="text" class="form-control" placeholder="Tu nombre...">
                </div>
                <div class="col-auto">
                    <button wire:click="agregarMensaje" class="btn btn-primary fw-semibold">
                        Agregar
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Lista de Mensajes -->
    @if(count($mensajes) > 0)
    <div class="card shadow-sm">
        <div class="card-body">
            <h3 class="h5 mb-3">📝 Mensajes ({{ count($mensajes) }})</h3>

            <div class="d-grid gap-2">
                @foreach($mensajes as $index => $msg)
                <div class="border-start border-primary border-4 p-3 bg-light rounded">
                    <div class="d-flex justify-content-between">
                        <div>
                            <strong>{{ $msg['nombre'] }}</strong>
                            <p class="mb-0 text-muted">{{ $msg['mensaje'] }}</p>
                        </div>
                        <small class="text-muted">{{ $msg['tiempo'] }}</small>
                    </div>
                </div>
                @endforeach
            </div>
        </div>
    </div>
    @endif

</div>
