<div wire:ignore.self class="modal fade" id="registrarModal" data-backdrop="static" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="fa fa-clock"></i> {{ $regis_update }} Horario
                </h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body p-4">
                <form>
                    <div class="form-group">
                        <label for="nombre_horario">
                            <i class="fa fa-tag"></i> Nombre del Horario
                        </label>
                        <input wire:model.defer="nombre_horario" class="form-control" placeholder="Ej: Turno Mañana, Horario A, etc.">
                        <x-validacion_input for="nombre_horario" />
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="hora_inicio">
                                    <i class="fa fa-play"></i> Hora de Inicio
                                </label>
                                <input wire:model.defer="hora_inicio" type="time" class="form-control">
                                <x-validacion_input for="hora_inicio" />
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="hora_fin">
                                    <i class="fa fa-stop"></i> Hora de Fin
                                </label>
                                <input wire:model.defer="hora_fin" type="time" class="form-control">
                                <x-validacion_input for="hora_fin" />
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="minutos_tolerancia_entrada">
                            <i class="fa fa-hourglass-half"></i> Tolerancia de Entrada (minutos)
                        </label>
                        <div class="input-group">
                            <input wire:model.defer="minutos_tolerancia_entrada" type="number" min="0" max="60" class="form-control" placeholder="0">
                            <div class="input-group-append">
                                <span class="input-group-text">minutos</span>
                            </div>
                        </div>
                        <x-validacion_input for="minutos_tolerancia_entrada" />
                        <small class="text-muted">
                            <i class="fa fa-info-circle"></i> Tiempo extra permitido después de la hora de inicio (0-60 minutos)
                        </small>
                    </div>

                    @if($hora_inicio && $hora_fin)
                        <div class="alert alert-info">
                            <i class="fa fa-calculator"></i> 
                            <strong>Vista previa:</strong>
                            @php
                                try {
                                    $inicio = \Carbon\Carbon::createFromFormat('H:i', $hora_inicio);
                                    $fin = \Carbon\Carbon::createFromFormat('H:i', $hora_fin);
                                    if ($fin->gt($inicio)) {
                                        $duracion = $inicio->diffInMinutes($fin);
                                        $horas = intval($duracion / 60);
                                        $minutos = $duracion % 60;
                                        echo "Duración: {$horas}h {$minutos}m";
                                    }
                                } catch (Exception $e) {
                                    echo "Formato de hora inválido";
                                }
                            @endphp
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