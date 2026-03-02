<div wire:ignore.self class="modal fade" id="registrarModal" data-backdrop="static" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="fa fa-user-graduate"></i> {{ $regis_update }} Alumno
                </h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body p-4">
                <form>
                    <!-- Información Básica del Alumno -->
                    <div class="card mb-3">
                        <div class="card-header bg-primary text-white">
                            <h6 class="mb-0"><i class="fa fa-user"></i> Información del Alumno</h6>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="codigo_modular">
                                            <i class="fa fa-barcode"></i> Código Modular *
                                        </label>
                                        <input wire:model.defer="codigo_modular" class="form-control" placeholder="Código único del alumno">
                                        <x-validacion_input for="codigo_modular" />
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="dni">
                                            <i class="fa fa-id-card"></i> DNI *
                                        </label>
                                        <input wire:model.defer="dni" class="form-control" placeholder="12345678" maxlength="8">
                                        <x-validacion_input for="dni" />
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="nombres">
                                    <i class="fa fa-user"></i> Nombres *
                                </label>
                                <input wire:model.defer="nombres" class="form-control" placeholder="Nombres del alumno">
                                <x-validacion_input for="nombres" />
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="apellido_paterno">Apellido Paterno *</label>
                                        <input wire:model.defer="apellido_paterno" class="form-control" placeholder="Apellido paterno">
                                        <x-validacion_input for="apellido_paterno" />
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="apellido_materno">Apellido Materno *</label>
                                        <input wire:model.defer="apellido_materno" class="form-control" placeholder="Apellido materno">
                                        <x-validacion_input for="apellido_materno" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Información Académica -->
                    <div class="card mb-3">
                        <div class="card-header bg-success text-white">
                            <h6 class="mb-0"><i class="fa fa-graduation-cap"></i> Información Académica</h6>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label for="nivel">
                                            <i class="fa fa-layer-group"></i> Nivel *
                                        </label>
                                        <select wire:model.defer="nivel" class="form-control">
                                            <option value="">--- SELECCIONAR ---</option>
                                            <option value="primaria">PRIMARIA</option>
                                            <option value="secundaria">SECUNDARIA</option>
                                        </select>
                                        <x-validacion_input for="nivel" />
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label for="grado">
                                            <i class="fa fa-sort-numeric-up"></i> Grado *
                                        </label>
                                        <select wire:model.defer="grado" class="form-control">
                                            <option value="">--- SELECCIONAR ---</option>
                                            <option value="1°">1° GRADO</option>
                                            <option value="2°">2° GRADO</option>
                                            <option value="3°">3° GRADO</option>
                                            <option value="4°">4° GRADO</option>
                                            <option value="5°">5° GRADO</option>
                                            <option value="6°">6° GRADO</option>
                                        </select>
                                        <x-validacion_input for="grado" />
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label for="seccion">
                                            <i class="fa fa-list"></i> Sección *
                                        </label>
                                        <select wire:model.defer="seccion" class="form-control">
                                            <option value="">--- SELECCIONAR ---</option>
                                            <option value="A">SECCIÓN A</option>
                                            <option value="B">SECCIÓN B</option>
                                            <option value="C">SECCIÓN C</option>
                                            <option value="D">SECCIÓN D</option>
                                            <option value="E">SECCIÓN E</option>
                                        </select>
                                        <x-validacion_input for="seccion" />
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="id_horario">
                                            <i class="fa fa-clock"></i> Horario *
                                        </label>
                                        <select wire:model.defer="id_horario" class="form-control">
                                            <option value="">--- SELECCIONAR HORARIO ---</option>
                                            @foreach($horarios as $horario)
                                                <option value="{{ $horario->id }}">
                                                    {{ $horario->nombre_horario }} 
                                                    ({{ \Carbon\Carbon::createFromFormat('H:i:s', $horario->hora_inicio)->format('h:i A') }} - 
                                                     {{ \Carbon\Carbon::createFromFormat('H:i:s', $horario->hora_fin)->format('h:i A') }})
                                                </option>
                                            @endforeach
                                        </select>
                                        <x-validacion_input for="id_horario" />
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="estado">
                                            <i class="fa fa-flag"></i> Estado *
                                        </label>
                                        <select wire:model.defer="estado" class="form-control">
                                            <option value="">--- SELECCIONAR ---</option>
                                            <option value="matriculado">MATRICULADO</option>
                                            <option value="retirado">RETIRADO</option>
                                            <option value="trasladado">TRASLADADO</option>
                                        </select>
                                        <x-validacion_input for="estado" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Información del Apoderado -->
                    <div class="card">
                        <div class="card-header bg-warning text-dark">
                            <h6 class="mb-0"><i class="fa fa-users"></i> Información del Apoderado</h6>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-8">
                                    <div class="form-group">
                                        <label for="apoderado_nombre">
                                            <i class="fa fa-user-tie"></i> Nombre del Apoderado *
                                        </label>
                                        <input wire:model.defer="apoderado_nombre" class="form-control" placeholder="Nombre completo del apoderado">
                                        <x-validacion_input for="apoderado_nombre" />
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label for="apoderado_telefono">
                                            <i class="fa fa-phone"></i> Teléfono
                                        </label>
                                        <input wire:model.defer="apoderado_telefono" class="form-control" placeholder="987654321" maxlength="9">
                                        <x-validacion_input for="apoderado_telefono" />
                                        <small class="text-muted">9 dígitos (opcional)</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    @if($nombres && $apellido_paterno && $apellido_materno)
                        <div class="alert alert-info mt-3">
                            <i class="fa fa-info-circle"></i> 
                            <strong>Vista previa:</strong> {{ $apellido_paterno }} {{ $apellido_materno }}, {{ $nombres }}
                            @if($grado && $seccion)
                                - {{ $grado }}{{ $seccion }}
                            @endif
                            @if($nivel)
                                ({{ strtoupper($nivel) }})
                            @endif
                        </div>
                    @endif
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-dismiss="modal">
                    <i class="fa fa-times"></i> Cancelar
                </button>
                <button class="btn btn-primary" wire:click.prevent="registrar()">
                    <i class="fa fa-save"></i> {{ $regis_update }}
                </button>
            </div>
        </div>
    </div>
</div>