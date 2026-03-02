<div class="container-fluid mt-5">
    <div class="row mb-4">
        <div class="col-sm-12 col-lg-6">
            <h4><i class="fa fa-brain"></i> Embeddings Faciales (512D)</h4>
            <p class="text-muted">Visualización de vectores de características faciales para reconocimiento biométrico</p>
        </div>
        <div class="col-sm-12 col-lg-6">
            <input wire:model.live='buscar' type="text" class="form-control" placeholder="Buscar alumnos con embeddings...">
        </div>
    </div>

    <!-- Estadísticas rápidas -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="card bg-primary text-white">
                <div class="card-body text-center">
                    <h5>{{ DB::table('embeddings_faciales')->count() }}</h5>
                    <small>Total Embeddings</small>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-success text-white">
                <div class="card-body text-center">
                    <h5>{{ DB::table('embeddings_faciales')->distinct('alumno_id')->count() }}</h5>
                    <small>Alumnos Registrados</small>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-info text-white">
                <div class="card-body text-center">
                    <h5>512</h5>
                    <small>Dimensiones</small>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-warning text-white">
                <div class="card-body text-center">
                    @php
                        $promedio = DB::table('embeddings_faciales')
                            ->join('alumno', 'embeddings_faciales.alumno_id', '=', 'alumno.id')
                            ->selectRaw('COUNT(embeddings_faciales.id) as total, COUNT(DISTINCT embeddings_faciales.alumno_id) as unicos')
                            ->first();
                        $avg = $promedio->unicos > 0 ? round($promedio->total / $promedio->unicos, 1) : 0;
                    @endphp
                    <h5>{{ $avg }}</h5>
                    <small>Promedio por Alumno</small>
                </div>
            </div>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-bordered table-sm">
            <thead class="thead-dark">
                <tr>
                    <th>ID</th>
                    <th>Alumno</th>
                    <th>Código/DNI</th>
                    <th>Grado</th>
                    <th>Horario</th>
                    <th>Estado</th>
                    <th>Vector Info</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                @foreach($embeddings as $embed)
                    <tr>
                        <td>
                            <span class="badge badge-secondary">#{{ $embed->id }}</span>
                        </td>
                        <td>
                            <strong>{{ $embed->apellido_paterno }} {{ $embed->apellido_materno }}</strong><br>
                            <small class="text-muted">{{ $embed->nombres }}</small>
                        </td>
                        <td>
                            <small>
                                <strong>Código:</strong> {{ $embed->codigo_modular }}<br>
                                <strong>DNI:</strong> {{ $embed->dni }}
                            </small>
                        </td>
                        <td class="text-center">
                            <span class="badge badge-primary">{{ $embed->grado }}{{ $embed->seccion }}</span><br>
                            <small class="badge badge-{{ $embed->nivel === 'primaria' ? 'success' : 'warning' }}">
                                {{ strtoupper($embed->nivel) }}
                            </small>
                        </td>
                        <td>
                            <small class="text-info">{{ $embed->nombre_horario }}</small>
                        </td>
                        <td>
                            @php
                                $badgeClass = match($embed->estado) {
                                    'matriculado' => 'success',
                                    'retirado' => 'danger',
                                    'trasladado' => 'warning',
                                    default => 'secondary'
                                };
                            @endphp
                            <span class="badge badge-{{ $badgeClass }}">
                                {{ strtoupper($embed->estado) }}
                            </span>
                        </td>
                        <td>
                            @php
                                $vector = json_decode($embed->vector_embedding, true);
                                $es_valido = is_array($vector) && count($vector) === 512;
                            @endphp
                            
                            @if($es_valido)
                                @php
                                    $min = round(min($vector), 3);
                                    $max = round(max($vector), 3);
                                    $norma = round(sqrt(array_sum(array_map(function($x) { return $x * $x; }, $vector))), 3);
                                @endphp
                                <small>
                                    <strong>Dim:</strong> 512 ✅<br>
                                    <strong>Rango:</strong> [{{ $min }}, {{ $max }}]<br>
                                    <strong>Norma:</strong> {{ $norma }}
                                </small>
                            @else
                                <span class="text-danger">
                                    <i class="fa fa-exclamation-triangle"></i> Vector inválido
                                </span>
                            @endif
                        </td>
                        <td width="120">
                            <div class="btn-group-vertical btn-group-sm">
                                <button class="btn btn-info btn-sm" 
                                        wire:click="visualizarEmbedding({{ $embed->id }})"
                                        {{ !$es_valido ? 'disabled' : '' }}>
                                    <i class="fa fa-eye"></i> Ver Vector
                                </button>
                                <button class="btn btn-danger btn-sm" 
                                        onclick="confirm('¿Eliminar embedding de {{ $embed->nombres }} {{ $embed->apellido_paterno }}?')||event.stopImmediatePropagation()"
                                        wire:click="eliminarEmbedding({{ $embed->id }})">
                                    <i class="fa fa-trash"></i> Eliminar
                                </button>
                            </div>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
        {{ $embeddings->links() }}
    </div>

    @if($embeddings->isEmpty())
        <div class="text-center mt-4">
            <div class="alert alert-warning">
                <i class="fa fa-exclamation-circle"></i> No se encontraron embeddings faciales registrados.
                <br><small>Los embeddings se generan automáticamente durante el proceso de registro facial.</small>
            </div>
        </div>
    @endif

    <!-- Modal de visualización -->
    @include('livewire.embeddings.visualizar')
</div>

<script>
    document.addEventListener('livewire:init', () => {
        Livewire.on('abrirModalVisualizacion', () => {
            $('#visualizarModal').modal('show');
        });
    });
</script>