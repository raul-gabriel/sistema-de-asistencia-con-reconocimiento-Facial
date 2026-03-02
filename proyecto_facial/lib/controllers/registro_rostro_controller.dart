// controllers/registro_rostro_controller.dart
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../model/rostro_detectado.dart';
import '../services/camara_service.dart';
import '../services/detector_rostro_service.dart';
import '../services/FaceEncoder.dart';
import '../services/ApiService.dart';
import '../utils/imagen_utils.dart';
import '../utils/ui_utils.dart';

/// Controlador optimizado para registro facial
/// Flujo simple: Capturar → Procesar → Enviar API
class RegistroRostroController extends ChangeNotifier {
  // Servicios esenciales
  final CamaraService _serviceCamara = CamaraService();
  final DetectorRostroService _serviceDetector = DetectorRostroService();
  final FaceEncoder _encoderRostro = FaceEncoder();

  // Estados del controlador
  bool _estaInicializando = true;
  bool _estaProcesando = false;
  String? _mensajeError;

  // Datos de captura
  XFile? _imagenCapturada;
  RostroDetectado? _rostroCapturado;
  Size? _dimensionImagen;
  List<Alumno>? _alumnos;

  // Getters públicos
  bool get estaInicializando => _estaInicializando;
  bool get estaProcesando => _estaProcesando;
  String? get mensajeError => _mensajeError;
  XFile? get imagenCapturada => _imagenCapturada;
  RostroDetectado? get rostroCapturado => _rostroCapturado;
  Size? get dimensionImagen => _dimensionImagen;
  List<Alumno>? get alumnos => _alumnos;

  // Estados de servicios
  bool get camaraLista => _serviceCamara.estaInicializada;
  bool get detectorListo => _serviceDetector.estaInicializado;
  bool get encoderListo => _encoderRostro.isModelLoaded;
  Size? get dimensionPreview => _serviceCamara.dimensionPreview;

  /// Obtiene el controlador de cámara para UI
  CameraController? obtenerControladorCamara() => _serviceCamara.controlador;

  /// Inicialización optimizada - solo lo esencial
  Future<void> inicializar() async {
    debugPrint('🚀 Iniciando sistema de registro optimizado...');

    _estaInicializando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      // Inicializar servicios en paralelo para mayor velocidad
      final futures = await Future.wait([
        _serviceDetector.inicializar(),
        _encoderRostro.loadModel(),
        _serviceCamara.inicializar(),
      ]);

      if (!futures[0]) {
        throw Exception(
          'Error inicializando detector: ${_serviceDetector.ultimoError}',
        );
      }
      if (!futures[1]) {
        throw Exception('Error cargando FaceNet-512');
      }
      if (!futures[2]) {
        throw Exception(
          'Error inicializando cámara: ${_serviceCamara.ultimoError}',
        );
      }

      _estaInicializando = false;
      debugPrint('✅ Sistema listo - Modo optimizado activado');
    } catch (e) {
      _mensajeError = e.toString();
      _estaInicializando = false;
      debugPrint('❌ Error inicializando: $e');
    }

    notifyListeners();
  }

  /// Flujo principal: Capturar y procesar rostro
  Future<bool> capturarYProcesarRostro(BuildContext context) async {
    if (_estaProcesando) return false;

    _estaProcesando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      // Verificar que todos los servicios estén listos
      if (!_validarServiciosListos(context)) {
        return false;
      }

      // 1. CAPTURAR - Feedback inmediato
      UIUtils.darFeedbackHaptico(TipoFeedback.medio);
      UIUtils.mostrarInfo(context, '📸 Capturando en máxima resolución...');

      final foto = await _serviceCamara.capturarFoto();
      if (foto == null) {
        throw Exception('Error capturando imagen');
      }

      _imagenCapturada = foto;
      notifyListeners();

      // 2. OBTENER DIMENSIONES
      final imagen = await ImagenUtils.cargarImagenDesdeArchivo(foto.path);
      if (imagen == null) {
        throw Exception('Error decodificando imagen');
      }

      _dimensionImagen = Size(
        imagen.width.toDouble(),
        imagen.height.toDouble(),
      );
      debugPrint('📐 Imagen: ${imagen.width}x${imagen.height}px');

      // 3. DETECTAR ROSTROS
      UIUtils.mostrarInfo(context, '🔍 Analizando rostros...');

      final rostrosDetectados = await _serviceDetector.procesarImagenCapturada(
        foto.path,
      );

      if (rostrosDetectados.isEmpty) {
        UIUtils.mostrarError(context, '❌ No se detectó ningún rostro');
        UIUtils.darFeedbackHaptico(TipoFeedback.fuerte);
        return false;
      }

      // 4. SELECCIONAR MEJOR ROSTRO
      final mejorRostro = _serviceDetector.seleccionarMejorRostro(
        rostrosDetectados,
        _dimensionImagen,
      );

      if (mejorRostro == null ||
          !_serviceDetector.validarCalidadRostro(mejorRostro)) {
        UIUtils.mostrarError(context, '❌ Rostro de baja calidad detectado');
        UIUtils.darFeedbackHaptico(TipoFeedback.fuerte);
        return false;
      }

      _rostroCapturado = mejorRostro;
      notifyListeners();

      // 5. GENERAR EMBEDDING
      UIUtils.mostrarInfo(context, '🧠 Procesando con FaceNet-512...');

      final embedding = await _generarEmbeddingOptimizado(
        imagen,
        mejorRostro.rectangulo,
      );

      if (embedding == null || embedding.isEmpty) {
        UIUtils.mostrarError(context, '❌ Error generando embedding');
        return false;
      }

      // 6. ACTUALIZAR ROSTRO CON EMBEDDING
      _rostroCapturado = mejorRostro.copiarCon(
        embedding: embedding,
        estaValidado: true,
      );

      UIUtils.mostrarExito(context, '🎯 Rostro procesado exitosamente');
      UIUtils.darFeedbackHaptico(TipoFeedback.ligero);

      debugPrint('✅ Embedding de ${embedding.length}D generado');
      return true;
    } catch (e) {
      _mensajeError = e.toString();
      UIUtils.mostrarError(context, '❌ Error: ${e.toString()}');
      UIUtils.darFeedbackHaptico(TipoFeedback.fuerte);
      return false;
    } finally {
      _estaProcesando = false;
      notifyListeners();
    }
  }

  /// Valida que todos los servicios estén listos
  bool _validarServiciosListos(BuildContext context) {
    if (!camaraLista) {
      UIUtils.mostrarAdvertencia(context, '📱 Cámara no disponible');
      return false;
    }
    if (!detectorListo) {
      UIUtils.mostrarAdvertencia(context, '🔍 Detector no listo');
      return false;
    }
    if (!encoderListo) {
      UIUtils.mostrarAdvertencia(context, '🧠 FaceNet-512 no cargado');
      return false;
    }
    return true;
  }

  /// Genera embedding optimizado - sin cargar imagen desde archivo
  Future<List<double>?> _generarEmbeddingOptimizado(
    dynamic imagen, // Ya tenemos la imagen cargada
    Rect rectanguloRostro,
  ) async {
    try {
      debugPrint('🧠 Generando embedding con FaceNet-512...');

      // Recortar rostro directamente de la imagen en memoria
      final rostroRecortado = ImagenUtils.recortarRostroConPadding(
        imagen,
        rectanguloRostro,
        factorPadding: 0.3, // Optimizado: menos padding = más rápido
      );

      if (rostroRecortado == null) {
        throw Exception('Error recortando rostro');
      }

      // Generar embedding
      final embedding = _encoderRostro.processFace(rostroRecortado);

      if (embedding == null || embedding.isEmpty) {
        throw Exception('Embedding vacío o nulo');
      }

      return embedding;
    } catch (e) {
      debugPrint('❌ Error generando embedding: $e');
      return null;
    }
  }

  /// Envía embedding a la API
  Future<bool> enviarEmbeddingAApi(BuildContext context, int idAlumno) async {
    if (_rostroCapturado?.embedding == null) {
      UIUtils.mostrarAdvertencia(context, '❌ No hay embedding para enviar');
      return false;
    }

    try {
      UIUtils.mostrarInfo(context, '📤 Enviando a servidor...');

      final mensaje = await ApiService.enviarEmbedding(
        idAlumno: idAlumno,
        embedding: _rostroCapturado!.embedding!,
      );

      UIUtils.mostrarExito(context, '✅ $mensaje');
      UIUtils.darFeedbackHaptico(TipoFeedback.ligero);

      return true;
    } catch (e) {
      UIUtils.mostrarError(context, '❌ Error enviando: $e');
      UIUtils.darFeedbackHaptico(TipoFeedback.fuerte);
      return false;
    }
  }

  /// Reinicia para nueva captura
  void reiniciarParaNuevaCaptura() {
    _imagenCapturada = null;
    _rostroCapturado = null;
    _dimensionImagen = null;
    _mensajeError = null;
    notifyListeners();
  }

  /// Reintenta inicialización
  Future<void> reintentar() async {
    await dispose();
    await Future.delayed(const Duration(milliseconds: 300));
    await inicializar();
  }

  /// Estado para debugging
  Map<String, dynamic> obtenerEstadoCompleto() {
    return {
      'servicios': {
        'camara': camaraLista,
        'detector': detectorListo,
        'encoder': encoderListo,
      },
      'datos': {
        'imagen_capturada': _imagenCapturada?.path != null,
        'rostro_procesado': _rostroCapturado?.tieneEmbedding ?? false,
        'alumnos_cargados': _alumnos?.length ?? 0,
      },
    };
  }

  @override
  Future<void> dispose() async {
    debugPrint('🗑️ Liberando controlador optimizado...');

    await Future.wait([_serviceCamara.dispose(), _serviceDetector.dispose()]);

    _encoderRostro.dispose();
    super.dispose();

    debugPrint('✅ Controlador liberado');
  }
}
