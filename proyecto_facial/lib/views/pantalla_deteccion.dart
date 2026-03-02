import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:proyecto_facial/models/datos_estudiante.dart';
import 'package:proyecto_facial/services/ApiService.dart';
import 'package:proyecto_facial/services/FaceEncoder.dart';

class DeteccionRostro extends StatefulWidget {
  const DeteccionRostro({super.key});

  @override
  State<DeteccionRostro> createState() => _EstadoDeteccionRostro();
}

class _EstadoDeteccionRostro extends State<DeteccionRostro>
    with TickerProviderStateMixin {
  // Controladores principales
  CameraController? _controladorCamara;
  late FaceDetector _detectorRostros;
  late FaceEncoder _codificadorRostros;

  // Estados del sistema
  bool _estaInicializado = false;
  bool _estaDetectando = false;
  String? _mensajeError;

  // Datos de detección
  List<Face> _rostrosDetectados = [];
  List<CoincidenciaEstudiante> _coincidenciasEstudiantes = [];

  // Control de detección
  DateTime? _tiempoUltimaDeteccion;
  static const Duration _tiempoEsperaDeteccion = Duration(seconds: 3);
  static const int _intervaloProcesamiento =
      100; // Reducido para mejor rendimiento

  // Animaciones
  late AnimationController _controladorAnimacionEscaneo;
  late AnimationController _controladorAnimacionPulso;
  late Animation<double> _animacionEscaneo;
  late Animation<double> _animacionPulso;

  // Estados de UI
  String _mensajeEstado = "🔍 Buscando estudiantes...";
  Color _colorEstado = Colors.blue;
  bool _estaProcesando = false;

  @override
  void initState() {
    super.initState();
    _configurarAnimaciones();
    _inicializarSistema();
  }

  void _configurarAnimaciones() {
    _controladorAnimacionEscaneo = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _controladorAnimacionPulso = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animacionEscaneo = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controladorAnimacionEscaneo,
        curve: Curves.linear,
      ),
    );

    _animacionPulso = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controladorAnimacionPulso,
        curve: Curves.elasticOut,
      ),
    );
  }

  Future<void> _inicializarSistema() async {
    setState(() {
      _mensajeEstado = "🚀 Inicializando sistema...";
      _colorEstado = Colors.blue;
    });

    await _inicializarDetectorRostros();
    if (_mensajeError != null) return;

    await _inicializarCodificadorRostros();
    if (_mensajeError != null) return;

    await _inicializarCamara();
  }

  Future<void> _inicializarDetectorRostros() async {
    try {
      _detectorRostros = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: false,
          enableClassification: false,
          enableLandmarks: false,
          enableTracking: true,
          minFaceSize: 0.15,
          performanceMode: FaceDetectorMode.fast,
        ),
      );
      debugPrint('✅ Detector de rostros inicializado');
    } catch (e) {
      setState(() => _mensajeError = 'Error inicializando detector: $e');
    }
  }

  Future<void> _inicializarCodificadorRostros() async {
    try {
      _codificadorRostros = FaceEncoder();
      final exito = await _codificadorRostros.loadModel();
      if (!exito) {
        throw Exception('No se pudo cargar MobileFaceNet');
      }
      debugPrint('✅ Modelo FaceEncoder cargado');
    } catch (e) {
      setState(() => _mensajeError = 'Error cargando modelo: $e');
    }
  }

  Future<void> _inicializarCamara() async {
    try {
      final camaras = await availableCameras();
      if (camaras.isEmpty) throw Exception('No hay cámaras disponibles');

      final camaraFrontal = camaras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => camaras.first,
      );

      _controladorCamara = CameraController(
        camaraFrontal,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controladorCamara!.initialize();
      await _controladorCamara!.lockCaptureOrientation();

      if (mounted) {
        setState(() {
          _estaInicializado = true;
          _mensajeError = null;
          _mensajeEstado = "✅ Sistema listo - Posiciónate frente a la cámara";
          _colorEstado = Colors.green;
        });

        _iniciarDeteccion();
      }
    } catch (e) {
      setState(() => _mensajeError = 'Error inicializando cámara: $e');
    }
  }

  void _iniciarDeteccion() {
    if (!_estaInicializado || _controladorCamara == null) return;

    Stream.periodic(Duration(milliseconds: _intervaloProcesamiento)).listen((
      _,
    ) {
      if (mounted &&
          !_estaDetectando &&
          _controladorCamara != null &&
          _controladorCamara!.value.isInitialized) {
        _procesarDeteccion();
      }
    });
  }

  Future<void> _procesarDeteccion() async {
    if (_estaDetectando) return;

    setState(() {
      _estaDetectando = true;
      _estaProcesando = true;
    });

    try {
      final foto = await _controladorCamara!.takePicture();
      final imagenEntrada = InputImage.fromFilePath(foto.path);
      final rostros = await _detectorRostros.processImage(imagenEntrada);

      if (rostros.isNotEmpty) {
        debugPrint('👤 Rostro detectado');

        // Extraer embedding
        final embedding = await _extraerEmbedding(foto.path, rostros.first);

        if (embedding != null && embedding.isNotEmpty) {
          debugPrint('🧠 Embedding extraído: ${embedding.length} dimensiones');

          print('\x1B[31m📤 Embedding completo:\n');

          // Enviar a API
          final respuesta = await ApiService.registrarAsistencia(embedding);

          debugPrint('\x1B[31m🔥 Consumió API correctamente\x1B[0m');
          debugPrint('📡 Respuesta de la API: ${respuesta}');

          if (respuesta != null) {
            // ✅ Verificar si el estado indica ÉXITO
            if (respuesta.estado == 'ASISTENCIA_REGISTRADO_PUNTUAL' ||
                respuesta.estado == 'ASISTENCIA_REGISTRADO_TARDE') {
              // ✅ ESTUDIANTE ENCONTRADO Y ASISTENCIA REGISTRADA EXITOSAMENTE
              final estudiante = respuesta.aDatosEstudiante();
              await _manejarEstudianteDetectado(estudiante, respuesta.mensaje);
              setState(() {
                _coincidenciasEstudiantes = [
                  CoincidenciaEstudiante(
                    indiceRostro: 0,
                    cajaDelimitadora: rostros.first.boundingBox,
                    estudiante: estudiante,
                    confianza: 0.85,
                    esCoincidencia: true,
                  ),
                ];
              });
            } else {
              // ⚠️ ERROR: NO_ENCONTRADO, ASISTENCIA_DUPLICADO, ALUMNO_NO_MATRICULADO, FUERA_DE_HORARIO, ERROR
              setState(() {
                _coincidenciasEstudiantes = [
                  CoincidenciaEstudiante(
                    indiceRostro: 0,
                    cajaDelimitadora: rostros.first.boundingBox,
                    estudiante: null,
                    confianza: 0.0,
                    esCoincidencia: false,
                  ),
                ];
              });
              // Mostrar alerta pequeña con el mensaje de error
              _mostrarAlertaPequena(respuesta.mensaje ?? 'Error desconocido');
            }
          } else {
            debugPrint('❌ No se pudo extraer embedding');
          }
        } else {
          debugPrint('❌ No se pudo extraer embedding');
        }

        setState(() => _rostrosDetectados = rostros);
        _actualizarEstadoUI(rostros.first, _coincidenciasEstudiantes);
      } else {
        // No hay rostros
        setState(() {
          _rostrosDetectados = [];
          _coincidenciasEstudiantes = [];
        });
        _actualizarEstadoUI(null, []);
      }

      // Limpiar archivo temporal
      await File(foto.path).delete();
    } catch (e) {
      debugPrint('❌ Error procesando detección: $e');
    } finally {
      if (mounted) {
        setState(() {
          _estaDetectando = false;
          _estaProcesando = false;
        });
      }
    }
  }

  void _mostrarAlertaPequena(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: TextStyle(fontSize: 14)),
        backgroundColor: Colors.orange[600],
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<List<double>?> _extraerEmbedding(
    String rutaImagen,
    Face rostro,
  ) async {
    try {
      final bytes = await File(rutaImagen).readAsBytes();
      final imagen = img.decodeImage(bytes);
      if (imagen == null) {
        debugPrint('❌ No se pudo decodificar la imagen');
        return null;
      }

      final rect = rostro.boundingBox;
      final padding = max(rect.width * 0.25, rect.height * 0.25);

      final izquierda = (rect.left - padding)
          .clamp(0, imagen.width - 1)
          .toInt();
      final arriba = (rect.top - padding).clamp(0, imagen.height - 1).toInt();
      final derecha = (rect.right + padding).clamp(0, imagen.width - 1).toInt();
      final abajo = (rect.bottom + padding).clamp(0, imagen.height - 1).toInt();

      final rostroRecortado = img.copyCrop(
        imagen,
        x: izquierda,
        y: arriba,
        width: derecha - izquierda,
        height: abajo - arriba,
      );

      debugPrint(
        '🖼️ Imagen recortada: ${rostroRecortado.width}x${rostroRecortado.height}',
      );

      final embedding = await _codificadorRostros.processFace(rostroRecortado);

      if (embedding != null && embedding.isNotEmpty) {
        debugPrint('✅ Embedding generado exitosamente');
      } else {
        debugPrint('❌ FaceEncoder devolvió embedding vacío o nulo');
      }

      return embedding;
    } catch (e) {
      debugPrint('❌ Error extrayendo embedding: $e');
      return null;
    }
  }

  Future<void> _manejarEstudianteDetectado(
    DatosEstudiante estudiante,
    String mensaje,
  ) async {
    final ahora = DateTime.now();

    // Control de tiempo de espera
    if (_tiempoUltimaDeteccion != null &&
        ahora.difference(_tiempoUltimaDeteccion!) < _tiempoEsperaDeteccion) {
      return;
    }

    _tiempoUltimaDeteccion = ahora;

    // Retroalimentación
    HapticFeedback.mediumImpact();
    _controladorAnimacionPulso.forward().then(
      (_) => _controladorAnimacionPulso.reverse(),
    );

    // Mostrar diálogo
    if (mounted) {
      _mostrarDialogoEstudiante(estudiante, mensaje);
    }
  }

  void _mostrarDialogoEstudiante(DatosEstudiante estudiante, String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          DialogoEstudianteDetectado(estudiante: estudiante, mensaje: mensaje),
    );
  }

  void _actualizarEstadoUI(
    Face? rostro,
    List<CoincidenciaEstudiante> coincidencias,
  ) {
    if (rostro == null) {
      setState(() {
        _mensajeEstado = "🔍 Buscando estudiantes...";
        _colorEstado = Colors.blue;
      });
      return;
    }

    final tieneCoincidencia = coincidencias.any((c) => c.esCoincidencia);

    if (tieneCoincidencia) {
      final coincidencia = coincidencias.firstWhere((c) => c.esCoincidencia);
      setState(() {
        _mensajeEstado = "✅ ${coincidencia.estudiante!.nombre} detectado";
        _colorEstado = Colors.green;
      });
    } else {
      setState(() {
        _mensajeEstado = "⚠️ Rostro no registrado en el sistema";
        _colorEstado = Colors.orange;
      });
    }
  }

  void _reiniciarSistema() {
    setState(() {
      _estaInicializado = false;
      _mensajeError = null;
    });
    _inicializarSistema();
  }

  @override
  void dispose() {
    _controladorAnimacionEscaneo.dispose();
    _controladorAnimacionPulso.dispose();
    _controladorCamara?.dispose();
    _detectorRostros.close();
    _codificadorRostros.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('🎓 Sistema de Asistencia'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reiniciarSistema,
          ),
        ],
      ),
      body: _construirInterfaz(),
    );
  }

  Widget _construirInterfaz() {
    if (_mensajeError != null) {
      return _construirInterfazError();
    }

    if (!_estaInicializado) {
      return _construirInterfazCarga();
    }

    return Stack(
      children: [
        _construirVistaCamara(),
        _construirGuiaRostro(),
        _construirPanelEstado(),
        if (_estaProcesando) _construirIndicadorProcesamiento(),
      ],
    );
  }

  Widget _construirVistaCamara() {
    return SizedBox.expand(
      child: ClipRRect(child: CameraPreview(_controladorCamara!)),
    );
  }

  Widget _construirGuiaRostro() {
    return Center(
      child: AnimatedBuilder(
        animation: _animacionPulso,
        builder: (context, child) {
          return Transform.scale(
            scale: _animacionPulso.value,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _colorEstado.withOpacity(0.8),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _colorEstado.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _animacionEscaneo,
                builder: (context, child) {
                  return CustomPaint(
                    painter: PintorLineaEscaneo(
                      _animacionEscaneo.value,
                      _colorEstado,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _construirPanelEstado() {
    return Positioned(
      top: 20,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: _colorEstado.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _colorEstado,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _mensajeEstado,
                style: TextStyle(
                  color: _colorEstado,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            if (_estaProcesando)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(_colorEstado),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirIndicadorProcesamiento() {
    return const Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          '🧠 Procesando...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _construirInterfazCarga() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '🚀 Inicializando Sistema',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Preparando detección facial...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _construirInterfazError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 72),
            const SizedBox(height: 20),
            Text(
              _mensajeError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _reiniciarSistema,
              icon: const Icon(Icons.refresh),
              label: const Text('Reiniciar Sistema'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pintor para la línea de escaneo
class PintorLineaEscaneo extends CustomPainter {
  final double progreso;
  final Color color;

  PintorLineaEscaneo(this.progreso, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2.0;

    final y = (progreso + 1) * size.height / 2;
    canvas.drawLine(
      Offset(size.width * 0.1, y),
      Offset(size.width * 0.9, y),
      pincel,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Diálogo de estudiante detectado
class DialogoEstudianteDetectado extends StatelessWidget {
  final DatosEstudiante estudiante;
  final String mensaje;

  const DialogoEstudianteDetectado({
    super.key,
    required this.estudiante,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de éxito
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 3),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),

            // Título
            const Text(
              '✅ ASISTENCIA REGISTRADA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Información del estudiante
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construirFila(Icons.person, 'Nombre', estudiante.nombre),
                  const SizedBox(height: 8),
                  _construirFila(Icons.school, 'Nivel', estudiante.curso),
                  const SizedBox(height: 8),
                  _construirFila(Icons.info, 'Estado', mensaje),
                  const SizedBox(height: 8),
                  _construirFila(
                    Icons.access_time,
                    'Hora',
                    _formatearFecha(DateTime.now()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botón cerrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirFila(IconData icono, String etiqueta, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$etiqueta: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}
