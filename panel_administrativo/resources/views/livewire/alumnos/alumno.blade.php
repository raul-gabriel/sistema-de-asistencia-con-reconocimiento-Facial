<div class="container-fluid mt-5">




    <!-- Estadísticas rápidas -->
    <div class="row mt-4">
        <div class="col-md-3">
            <div class="card bg-primary text-white">
                <div class="card-body text-center">
                    <h5>{{ $alumnos->total() }}</h5>
                    <small>Total Alumnos</small>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-success text-white">
                <div class="card-body text-center">
                    <h5>{{ DB::table('alumno')->where('estado', 'matriculado')->count() }}</h5>
                    <small>Matriculados</small>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-warning text-white">
                <div class="card-body text-center">
                    <h5>{{ DB::table('alumno')->where('nivel', 'primaria')->count() }}</h5>
                    <small>Primaria</small>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-info text-white">
                <div class="card-body text-center">
                    <h5>{{ DB::table('alumno')->where('nivel', 'secundaria')->count() }}</h5>
                    <small>Secundaria</small>
                </div>
            </div>
        </div>
    </div>





    <div class="row mb-4 mt-4">
        <div class="col-sm-12 col-lg-4">
            <input wire:model.live='buscar' type="text" class="form-control" placeholder="Buscar alumnos (código, nombres, apellidos, DNI)">
        </div>
        <div class="col-sm-12 col-lg-8">
            <button class="btn btn-success" data-toggle="modal" data-target="#registrarModal" wire:click.prevent="limpiar()">
                <i class="fa fa-plus"></i> Agregar Alumno
            </button>
            @include('livewire.alumnos.registrar')
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-bordered table-sm">
            <thead class="thead-dark">
                <tr>
                    <th>#</th>
                    <th>Código</th>
                    <th>Alumno</th>
                    <th>DNI</th>
                    <th>Grado/Sección</th>
                    <th>Nivel</th>
                    <th>Apoderado</th>
                    <th>Teléfono</th>
                    <th>Horario</th>
                    <th>Estado</th>
                    <th>Acción</th>
                </tr>
            </thead>
            <tbody>
                @foreach($alumnos as $fila)
                    <tr>
                        <td>{{ $fila->id }}</td>
                        <td>
                            <span class="badge badge-secondary">{{ $fila->codigo_modular }}</span>
                        </td>
                        <td>
                            <strong>{{ $fila->apellido_paterno }} {{ $fila->apellido_materno }}</strong><br>
                            <small class="text-muted">{{ $fila->nombres }}</small>
                        </td>
                        <td>
                            <span class="badge badge-info">{{ $fila->dni }}</span>
                        </td>
                        <td class="text-center">
                            <span class="badge badge-primary">{{ $fila->grado }}{{ $fila->seccion }}</span>
                        </td>
                        <td>
                            <span class="badge badge-{{ $fila->nivel === 'primaria' ? 'success' : 'warning' }}">
                                {{ strtoupper($fila->nivel) }}
                            </span>
                        </td>
                        <td>
                            <small>{{ $fila->apoderado_nombre }}</small>
                        </td>
                        <td>
                            @if($fila->apoderado_telefono)
                                <a href="tel:{{ $fila->apoderado_telefono }}" class="text-decoration-none">
                                    <i class="fa fa-phone"></i> {{ $fila->apoderado_telefono }}
                                </a>
                            @else
                                <span class="text-muted">No registrado</span>
                            @endif
                        </td>
                        <td>
                            <small class="text-info">{{ $fila->nombre_horario }}</small>
                        </td>
                        <td>
                            @php
                                $badgeClass = match($fila->estado) {
                                    'matriculado' => 'success',
                                    'retirado' => 'danger',
                                    'trasladado' => 'warning',
                                    default => 'secondary'
                                };
                            @endphp
                            <span class="badge badge-{{ $badgeClass }}">
                                {{ strtoupper($fila->estado) }}
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
                                    <div class="dropdown-divider"></div>
                                    <a class="dropdown-item" onclick="confirm('¿Eliminar alumno {{ $fila->nombres }} {{ $fila->apellido_paterno }}?')||event.stopImmediatePropagation()"
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
        {{ $alumnos->links() }}
    </div>

    @if($alumnos->isEmpty())
        <div class="text-center mt-4">
            <div class="alert alert-info">
                <i class="fa fa-info-circle"></i> No se encontraron alumnos registrados.
                <br><small>Intente con otros términos de búsqueda o registre un nuevo alumno.</small>
            </div>
        </div>
    @endif

    
</div>