<div wire:ignore.self class="modal fade" id="visualizarModal" data-backdrop="static" tabindex="-1">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-info text-white">
                <h5 class="modal-title">
                    <i class="fa fa-brain"></i> Visualización de Embedding Facial - 512 Dimensiones
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal" wire:click="cerrarVisualizacion">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                @if($alumno_detalle)
                    <!-- Información del alumno -->
                    <div class="card mb-4">
                        <div class="card-header bg-primary text-white">
                            <h6 class="mb-0"><i class="fa fa-user"></i> Información del Alumno</h6>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <strong>Nombre:</strong> {{ $alumno_detalle->apellido_paterno }} {{ $alumno_detalle->apellido_materno }}, {{ $alumno_detalle->nombres }}<br>
                                    <strong>Código:</strong> {{ $alumno_detalle->codigo_modular }}<br>
                                    <strong>DNI:</strong> {{ $alumno_detalle->dni }}
                                </div>
                                <div class="col-md-6">
                                    <strong>Grado/Sección:</strong> {{ $alumno_detalle->grado }}{{ $alumno_detalle->seccion }} ({{ strtoupper($alumno_detalle->nivel) }})<br>
                                    <strong>Horario:</strong> {{ $alumno_detalle->nombre_horario }}<br>
                                    <strong>Embedding ID:</strong> #{{ $embedding_seleccionado }}
                                </div>
                            </div>
                        </div>
                    </div>

                    @if(!empty($vector_visualizar))
                        <!-- Estadísticas del vector -->
                        @php
                            $stats = $this->getEstadisticasVector($vector_visualizar);
                            $norma = $this->getNormaVector($vector_visualizar);
                        @endphp
                        
                        <div class="row mb-4">
                            <div class="col-md-2">
                                <div class="card text-center bg-light">
                                    <div class="card-body p-2">
                                        <h6 class="text-primary">{{ $stats['dimension'] }}</h6>
                                        <small>Dimensiones</small>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="card text-center bg-light">
                                    <div class="card-body p-2">
                                        <h6 class="text-success">{{ $stats['min'] }}</h6>
                                        <small>Mínimo</small>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="card text-center bg-light">
                                    <div class="card-body p-2">
                                        <h6 class="text-danger">{{ $stats['max'] }}</h6>
                                        <small>Máximo</small>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="card text-center bg-light">
                                    <div class="card-body p-2">
                                        <h6 class="text-info">{{ $stats['promedio'] }}</h6>
                                        <small>Promedio</small>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="card text-center bg-light">
                                    <div class="card-body p-2">
                                        <h6 class="text-warning">{{ $stats['desviacion'] }}</h6>
                                        <small>Desv. Est.</small>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <div class="card text-center bg-light">
                                    <div class="card-body p-2">
                                        <h6 class="text-secondary">{{ $norma }}</h6>
                                        <small>Norma L2</small>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Visualización del vector -->
                        <div class="card">
                            <div class="card-header">
                                <h6 class="mb-0"><i class="fa fa-chart-line"></i> Vector de Características (512 dimensiones)</h6>
                            </div>
                            <div class="card-body">
                                <!-- Gráfico de líneas del vector -->
                                <div class="mb-3">
                                    <canvas id="vectorChart" width="800" height="200"></canvas>
                                </div>
                                
                                <!-- Histograma de distribución -->
                                <div class="mb-3">
                                    <h6><i class="fa fa-bar-chart"></i> Distribución de Valores</h6>
                                    <canvas id="histogramChart" width="400" height="150"></canvas>
                                </div>

                                <!-- Vector en formato tabla (primeras y últimas 20 dimensiones) -->
                                <div class="row">
                                    <div class="col-md-6">
                                        <h6><i class="fa fa-list"></i> Primeras 20 dimensiones</h6>
                                        <div class="table-responsive" style="max-height: 300px;">
                                            <table class="table table-sm table-striped">
                                                <thead>
                                                    <tr><th>Dim</th><th>Valor</th><th>Visualización</th></tr>
                                                </thead>
                                                <tbody>
                                                    @for($i = 0; $i < min(20, count($vector_visualizar)); $i++)
                                                        <tr>
                                                            <td><strong>{{ $i }}</strong></td>
                                                            <td><code>{{ number_format($vector_visualizar[$i], 6) }}</code></td>
                                                            <td>
                                                                @php
                                                                    $valor = $vector_visualizar[$i];
                                                                    $ancho = abs($valor) * 100 / max(abs($stats['min']), abs($stats['max']));
                                                                    $color = $valor >= 0 ? 'bg-success' : 'bg-danger';
                                                                @endphp
                                                                <div class="progress" style="height: 8px;">
                                                                    <div class="progress-bar {{ $color }}" style="width: {{ $ancho }}%"></div>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    @endfor
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <h6><i class="fa fa-list"></i> Últimas 20 dimensiones</h6>
                                        <div class="table-responsive" style="max-height: 300px;">
                                            <table class="table table-sm table-striped">
                                                <thead>
                                                    <tr><th>Dim</th><th>Valor</th><th>Visualización</th></tr>
                                                </thead>
                                                <tbody>
                                                    @for($i = max(0, count($vector_visualizar) - 20); $i < count($vector_visualizar); $i++)
                                                        <tr>
                                                            <td><strong>{{ $i }}</strong></td>
                                                            <td><code>{{ number_format($vector_visualizar[$i], 6) }}</code></td>
                                                            <td>
                                                                @php
                                                                    $valor = $vector_visualizar[$i];
                                                                    $ancho = abs($valor) * 100 / max(abs($stats['min']), abs($stats['max']));
                                                                    $color = $valor >= 0 ? 'bg-success' : 'bg-danger';
                                                                @endphp
                                                                <div class="progress" style="height: 8px;">
                                                                    <div class="progress-bar {{ $color }}" style="width: {{ $ancho }}%"></div>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    @endfor
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                <!-- Vector completo colapsable -->
                                <div class="mt-3">
                                    <button class="btn btn-outline-secondary btn-sm" type="button" data-toggle="collapse" data-target="#vectorCompleto">
                                        <i class="fa fa-code"></i> Ver Vector Completo (JSON)
                                    </button>
                                    <div class="collapse mt-2" id="vectorCompleto">
                                        <div class="card card-body">
                                            <pre class="mb-0" style="max-height: 200px; overflow-y: auto; font-size: 10px;">{{ json_encode($vector_visualizar, JSON_PRETTY_PRINT) }}</pre>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    @else
                        <div class="alert alert-danger">
                            <i class="fa fa-exclamation-triangle"></i> Error: El vector embedding no pudo ser decodificado o no tiene 512 dimensiones.
                        </div>
                    @endif
                @endif
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-dismiss="modal" wire:click="cerrarVisualizacion">
                    <i class="fa fa-times"></i> Cerrar
                </button>
                @if($embedding_seleccionado)
                    <button class="btn btn-danger" 
                            onclick="confirm('¿Eliminar este embedding facial?')||event.stopImmediatePropagation()"
                            wire:click="eliminarEmbedding({{ $embedding_seleccionado }})">
                        <i class="fa fa-trash"></i> Eliminar Embedding
                    </button>
                @endif
            </div>
        </div>
    </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
<script>
let vectorChart = null;
let histogramChart = null;

document.addEventListener('livewire:init', () => {
    Livewire.on('abrirModalVisualizacion', () => {
        setTimeout(() => {
            const vectorData = @json($vector_visualizar ?? []);
            if (vectorData.length === 512) {
                crearGraficoVector(vectorData);
                crearHistograma(vectorData);
            }
        }, 500);
    });
});

function crearGraficoVector(data) {
    const ctx = document.getElementById('vectorChart');
    if (!ctx) return;
    
    if (vectorChart) vectorChart.destroy();
    
    vectorChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: Array.from({length: 512}, (_, i) => i),
            datasets: [{
                label: 'Valores del Vector',
                data: data,
                borderColor: 'rgb(54, 162, 235)',
                backgroundColor: 'rgba(54, 162, 235, 0.1)',
                borderWidth: 1,
                pointRadius: 0,
                tension: 0.1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false }
            },
            scales: {
                x: { 
                    title: { display: true, text: 'Dimensión' },
                    ticks: { maxTicksLimit: 20 }
                },
                y: { 
                    title: { display: true, text: 'Valor' }
                }
            }
        }
    });
}

function crearHistograma(data) {
    const ctx = document.getElementById('histogramChart');
    if (!ctx) return;
    
    if (histogramChart) histogramChart.destroy();
    
    // Crear bins para el histograma
    const min = Math.min(...data);
    const max = Math.max(...data);
    const bins = 20;
    const binSize = (max - min) / bins;
    const histogram = new Array(bins).fill(0);
    const labels = [];
    
    for (let i = 0; i < bins; i++) {
        labels.push((min + i * binSize).toFixed(3));
    }
    
    data.forEach(value => {
        const binIndex = Math.min(Math.floor((value - min) / binSize), bins - 1);
        histogram[binIndex]++;
    });
    
    histogramChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Frecuencia',
                data: histogram,
                backgroundColor: 'rgba(75, 192, 192, 0.6)',
                borderColor: 'rgba(75, 192, 192, 1)',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false }
            },
            scales: {
                x: { 
                    title: { display: true, text: 'Rango de Valores' }
                },
                y: { 
                    title: { display: true, text: 'Frecuencia' }
                }
            }
        }
    });
}
</script>