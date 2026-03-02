<div class="container-fluid py-4">
    <div class="row">
        <div class="col-12">
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white">
                    <div class="d-flex justify-content-between align-items-center">
                        <h4 class="mb-0">
                            <i class="fas fa-calendar-check me-2"></i>
                            Registro de Asistencias
                        </h4>
                        <div>
                            @if(count($asistencias) > 0)
                                <button wire:click="exportarExcel" class="btn btn-success btn-sm">
                                    <i class="fas fa-file-excel me-1"></i>
                                    Exportar Excel
                                </button>
                            @endif
                        </div>
                    </div>
                </div>

                <div class="card-body">
                    <!-- Filtros -->
                    <div class="row mb-4">
                        <div class="col-md-4">
                            <label for="fecha" class="form-label fw-bold">Fecha:</label>
                            <select wire:model.live="fechaSeleccionada" id="fecha" class="form-control">
                                <option value="">Selecciona una fecha</option>
                                @foreach($fechasDisponibles as $fecha)
                                    <option value="{{ $fecha->fecha }}">
                                        {{ $fecha->fecha_legible }}
                                    </option>
                                @endforeach
                            </select>
                        </div>

                        <div class="col-md-3">
                            <label for="nivel" class="form-label fw-bold">Nivel:</label>
                            <select wire:model.live="nivelSeleccionado" id="nivel" class="form-control">
                                <option value="">Selecciona nivel</option>
                                @foreach($niveles as $key => $valor)
                                    <option value="{{ $key }}">{{ $valor }}</option>
                                @endforeach
                            </select>
                        </div>

                        <div class="col-md-3">
                            <label for="grado" class="form-label fw-bold">Grado:</label>
                            <select wire:model.live="gradoSeleccionado" id="grado" class="form-control">
                                <option value="">Selecciona grado</option>
                                @foreach($grados as $key => $valor)
                                    <option value="{{ $key }}">{{ $valor }}</option>
                                @endforeach
                            </select>
                        </div>

                        <div class="col-md-2 d-flex align-items-end">
                            <button wire:click="limpiarFiltros" class="btn btn-outline-secondary w-100">
                                <i class="fas fa-eraser me-1"></i>
                                Limpiar
                            </button>
                        </div>
                    </div>

                    <!-- Mensajes Flash -->
                    @if (session()->has('error'))
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-triangle me-2"></i>
                            {{ session('error') }}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    @endif

                    @if (session()->has('info'))
                        <div class="alert alert-info alert-dismissible fade show" role="alert">
                            <i class="fas fa-info-circle me-2"></i>
                            {{ session('info') }}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    @endif

                    <!-- Loading Spinner -->
                    <div wire:loading class="fixed inset-0 z-50 flex items-center justify-center bg-white/80">
                        <div class="flex flex-col items-center">
                            <svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 24 24"><g fill="none" stroke="#059669" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"><path stroke-dasharray="16" stroke-dashoffset="16" d="M12 3c4.97 0 9 4.03 9 9"><animate fill="freeze" attributeName="stroke-dashoffset" dur="0.3s" values="16;0"/><animateTransform attributeName="transform" dur="1.5s" repeatCount="indefinite" type="rotate" values="0 12 12;360 12 12"/></path><path stroke-dasharray="64" stroke-dashoffset="64" stroke-opacity=".3" d="M12 3c4.97 0 9 4.03 9 9c0 4.97 -4.03 9 -9 9c-4.97 0 -9 -4.03 -9 -9c0 -4.97 4.03 -9 9 -9Z"><animate fill="freeze" attributeName="stroke-dashoffset" dur="1.2s" values="64;0"/></path></g></svg>
                            <p class="mt-4 text-gray-600 text-sm">Consultando asistencias...</p>
                        </div>
                    </div>
                    
                    

                    <!-- Tabla de Asistencias -->
                    @if(count($asistencias) > 0)
                        <div wire:loading.remove class="table-responsive">
                            <table class="table table-hover table-bordered">
                                <thead class="table-dark">
                                    <tr>
                                        <th scope="col">#</th>
                                        <th scope="col">Código</th>
                                        <th scope="col">Nombres y Apellidos</th>
                                        <th scope="col">Grado</th>
                                        <th scope="col">Sección</th>
                                        <th scope="col">Estado</th>
                                        <th scope="col">Hora Registro</th>
                                        <th scope="col">Observaciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($asistencias as $index => $asistencia)
                                        <tr>
                                            <td class="fw-bold">{{ $index + 1 }}</td>
                                            <td>
                                                <code>{{ $asistencia->{'Código Modular'} }}</code>
                                            </td>
                                            <td class="fw-semibold">
                                                {{ $asistencia->{'Nombres y Apellidos'} }}
                                            </td>
                                            <td class="text-center">
                                                <span class="badge bg-secondary">
                                                    {{ $asistencia->Grado }}
                                                </span>
                                            </td>
                                            <td class="text-center">
                                                <span class="badge bg-info">
                                                    {{ $asistencia->Sección }}
                                                </span>
                                            </td>
                                            <td class="text-center">
                                                @if($asistencia->Estado == 'PRESENTE')
                                                    <span class="badge bg-success">
                                                        <i class="fas fa-check me-1"></i>
                                                        PRESENTE
                                                    </span>
                                                @elseif($asistencia->Estado == 'TARDANZA')
                                                    <span class="badge bg-warning text-dark">
                                                        <i class="fas fa-clock me-1"></i>
                                                        TARDANZA
                                                    </span>
                                                @else
                                                    <span class="badge bg-danger">
                                                        <i class="fas fa-times me-1"></i>
                                                        FALTA
                                                    </span>
                                                @endif
                                            </td>
                                            <td class="text-center">
                                                @if($asistencia->{'Hora Registro'} != 'No registró')
                                                    <span class="badge bg-light text-dark">
                                                        {{ $asistencia->{'Hora Registro'} }}
                                                    </span>
                                                @else
                                                    <span class="text-muted">
                                                        <i>No registró</i>
                                                    </span>
                                                @endif
                                            </td>
                                            <td>
                                                <small class="text-muted">
                                                    {{ $asistencia->Observaciones ?? '-' }}
                                                </small>
                                            </td>
                                        </tr>
                                    @endforeach
                                </tbody>
                            </table>

                            <!-- Resumen -->
                            @php
                                $presentes = collect($asistencias)->where('Estado', 'PRESENTE')->count();
                                $tardanzas = collect($asistencias)->where('Estado', 'TARDANZA')->count();
                                $faltas = collect($asistencias)->where('Estado', 'FALTA')->count();
                                $total = count($asistencias);
                                $porcentajeAsistencia = $total > 0 ? round((($presentes + $tardanzas) / $total) * 100, 2) : 0;
                            @endphp

                            <div class="row mt-4">
                                <div class="col-12">
                                    <div class="alert alert-light border">
                                        <h6 class="mb-3"><i class="fas fa-chart-pie me-2"></i>Resumen de Asistencia</h6>
                                        <div class="row text-center">
                                            <div class="col-md-3">
                                                <div class="card bg-success text-white">
                                                    <div class="card-body py-2">
                                                        <h4 class="mb-0">{{ $presentes }}</h4>
                                                        <small>Presentes</small>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="card bg-warning text-dark">
                                                    <div class="card-body py-2">
                                                        <h4 class="mb-0">{{ $tardanzas }}</h4>
                                                        <small>Tardanzas</small>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="card bg-danger text-white">
                                                    <div class="card-body py-2">
                                                        <h4 class="mb-0">{{ $faltas }}</h4>
                                                        <small>Faltas</small>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="card bg-primary text-white">
                                                    <div class="card-body py-2">
                                                        <h4 class="mb-0">{{ $porcentajeAsistencia }}%</h4>
                                                        <small>% Asistencia</small>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    @elseif($fechaSeleccionada && $gradoSeleccionado && $nivelSeleccionado)
                        <div wire:loading.remove class="text-center py-5">
                            <div class="text-muted">
                                <i class="fas fa-search fa-3x mb-3"></i>
                                <h5>No se encontraron registros de asistencia</h5>
                                <p>Para los filtros seleccionados no hay datos disponibles.</p>
                            </div>
                        </div>
                    @else
                        <div wire:loading.remove class="text-center py-5">
                            <div class="text-muted">
                                <i class="fas fa-filter fa-3x mb-3"></i>
                                <h5>Selecciona los filtros</h5>
                                <p>Escoge una fecha, nivel y grado para ver las asistencias.</p>
                            </div>
                        </div>
                    @endif
                </div>
            </div>
        </div>
    </div>
</div>