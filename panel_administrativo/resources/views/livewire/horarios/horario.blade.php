<div class="container mt-5">
    <div class="row mb-4">
        <div class="col-sm-12 col-lg-4">
            <input wire:model.live='buscar' type="text" class="form-control" placeholder="Buscar horarios">
        </div>
        <div class="col-sm-12 col-lg-8">
            <button class="btn btn-success" data-toggle="modal" data-target="#registrarModal" wire:click.prevent="limpiar()">
                <i class="fa fa-plus"></i> Agregar Horario
            </button>
            @include('livewire.horarios.registrar')
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-bordered table-sm">
            <thead class="thead-dark">
                <tr>
                    <th>#</th>
                    <th>Nombre Horario</th>
                    <th>Hora Inicio</th>
                    <th>Hora Fin</th>
                    <th>Duración</th>
                    <th>Tolerancia (min)</th>
                    <th>Acción</th>
                </tr>
            </thead>
            <tbody>
                @foreach($horarios as $fila)
                    <tr>
                        <td>{{ $fila->id }}</td>
                        <td>
                            <strong>{{ $fila->nombre_horario }}</strong>
                        </td>
                        <td>
                            <span class="badge badge-info">
                                {{ \Carbon\Carbon::createFromFormat('H:i:s', $fila->hora_inicio)->format('h:i A') }}
                            </span>
                        </td>
                        <td>
                            <span class="badge badge-warning">
                                {{ \Carbon\Carbon::createFromFormat('H:i:s', $fila->hora_fin)->format('h:i A') }}
                            </span>
                        </td>
                        <td>
                            @php
                                $inicio = \Carbon\Carbon::createFromFormat('H:i:s', $fila->hora_inicio);
                                $fin = \Carbon\Carbon::createFromFormat('H:i:s', $fila->hora_fin);
                                $duracion = $inicio->diffInMinutes($fin);
                                $horas = intval($duracion / 60);
                                $minutos = $duracion % 60;
                            @endphp
                            <span class="badge badge-secondary">
                                {{ $horas }}h {{ $minutos }}m
                            </span>
                        </td>
                        <td>
                            <span class="badge badge-success">
                                {{ $fila->minutos_tolerancia_entrada }} min
                            </span>
                        </td>
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
                                    <a class="dropdown-item" onclick="confirm('¿Eliminar horario {{ $fila->nombre_horario }}?\n\nNOTA: Solo se puede eliminar si no tiene alumnos asignados.')||event.stopImmediatePropagation()"
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
        {{ $horarios->links() }}
    </div>

    @if($horarios->isEmpty())
        <div class="text-center mt-4">
            <div class="alert alert-info">
                <i class="fa fa-info-circle"></i> No se encontraron horarios registrados.
            </div>
        </div>
    @endif
</div>