<div class="container mt-5">
    <div class="row mb-4">
        <div class="col-sm-12 col-lg-4">
            <input wire:model.live='buscar' type="text" class="form-control" placeholder="Buscar usuarios">
        </div>
        <div class="col-sm-12 col-lg-8">
            <button class="btn btn-success" data-toggle="modal" data-target="#registrarModal" wire:click.prevent="limpiar()">
                <i class="fa fa-plus"></i> Agregar Usuario
            </button>
            @include('livewire.usuarios.registrar')
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-bordered table-sm">
            <thead class="thead-dark">
                <tr>
                    <th>#</th>
                    <th>Usuario/correo</th>
                    <th>Nombres</th>
                    <th>Apellidos</th>
                    <th>Rol</th>
                    <th>Estado</th>
                    <th>Fecha Creación</th>
                    <th>Acción</th>
                </tr>
            </thead>
            <tbody>
                @foreach($usuarios as $fila)
                    <tr>
                        <td>{{ $fila->id }}</td>
                        <td>{{ $fila->username }}</td>
                        <td>{{ $fila->nombres }}</td>
                        <td>{{ $fila->apellidos }}</td>
                        <td>
                            <span class="badge badge-{{ $fila->rol === 'admin' ? 'danger' : ($fila->rol === 'docente' ? 'primary' : 'info') }}">
                                {{ strtoupper($fila->rol) }}
                            </span>
                        </td>
                        <td>
                            <span class="badge badge-{{ $fila->estado === 'activo' ? 'success' : 'secondary' }}">
                                {{ strtoupper($fila->estado) }}
                            </span>
                        </td>
                        <td>{{ \Carbon\Carbon::parse($fila->fecha_creacion)->format('d/m/Y H:i') }}</td>
                        <td width="90">
                            <div class="btn-group">
                                <button class="btn btn-danger btn-sm dropdown-toggle" data-toggle="dropdown">
                                    Acción
                                </button>
                                <div class="dropdown-menu dropdown-menu-right">
                                    <a class="dropdown-item" data-toggle="modal" data-target="#registrarModal"
                                       wire:click="recuperar({{ $fila->id }})">
                                        <i class="fa fa-edit"></i> Editar
                                    </a>
                                    <a class="dropdown-item" onclick="confirm('¿Eliminar usuario {{ $fila->username }}?')||event.stopImmediatePropagation()"
                                       wire:click="destroy({{ $fila->id }})">
                                        <i class="fa fa-trash"></i> Eliminar
                                    </a>
                                </div>
                            </div>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
        {{ $usuarios->links() }}
    </div>
</div>