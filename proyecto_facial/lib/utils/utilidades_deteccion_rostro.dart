import 'dart:math';
import 'package:flutter/material.dart';

/// Utilidades para detección facial y cálculos de similitud
class UtilidadesDeteccionRostro {
  /// Umbral de similitud para considerar una coincidencia válida
  static const double umbralSimilitud = 0.65;

  /// Intervalo de procesamiento en milisegundos (20 FPS máximo)
  static const int intervaloProcesamiento = 50;

  /// Tamaño de la guía visual de detección
  static const double tamanoGuiaRostro = 280.0;

  /// Duración del tiempo de espera entre detecciones del mismo estudiante
  static const Duration tiempoEsperaDeteccion = Duration(seconds: 3);

  /// Calcula la similitud de coseno entre dos vectores de embedding
  static double calcularSimilitudCoseno(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;

    double productoEscalar = 0.0;
    double normaA = 0.0;
    double normaB = 0.0;

    // Cálculo vectorizado optimizado
    for (int i = 0; i < a.length; i++) {
      final ai = a[i];
      final bi = b[i];
      productoEscalar += ai * bi;
      normaA += ai * ai;
      normaB += bi * bi;
    }

    if (normaA == 0.0 || normaB == 0.0) return 0.0;
    return productoEscalar / (sqrt(normaA) * sqrt(normaB));
  }

  /// Calcula el relleno óptimo para recortar caras
  static Rect calcularRellenoOptimalRostro(
    Rect rectanguloRostro,
    int anchoImagen,
    int altoImagen, {
    double factorRelleno = 0.25,
  }) {
    final relleno = max(
      rectanguloRostro.width * factorRelleno,
      rectanguloRostro.height * factorRelleno,
    );

    final izquierda = (rectanguloRostro.left - relleno).clamp(
      0,
      anchoImagen - 1,
    );
    final arriba = (rectanguloRostro.top - relleno).clamp(0, altoImagen - 1);
    final derecha = (rectanguloRostro.right + relleno).clamp(
      0,
      anchoImagen - 1,
    );
    final abajo = (rectanguloRostro.bottom + relleno).clamp(0, altoImagen - 1);

    return Rect.fromLTRB(
      izquierda.toDouble(),
      arriba.toDouble(),
      derecha.toDouble(),
      abajo.toDouble(),
    );
  }

  /// Escala las coordenadas de detección para el overlay de la cámara
  static Rect escalarRectParaCamara(
    Rect cajaDelimitadora,
    Size tamanoVista,
    Size tamanoPantalla,
  ) {
    final escalaX = tamanoPantalla.width / tamanoVista.height;
    final escalaY = tamanoPantalla.height / tamanoVista.width;

    return Rect.fromLTWH(
      cajaDelimitadora.top * escalaX,
      cajaDelimitadora.left * escalaY,
      cajaDelimitadora.height * escalaX,
      cajaDelimitadora.width * escalaY,
    );
  }

  /// Valida la calidad de una detección facial
  static bool esDeteccionRostroValida(
    Rect rectanguloRostro,
    Size tamanoImagen, {
    double proporcionMinimaRostro = 0.1,
    double proporcionMaximaRostro = 0.8,
  }) {
    final areaRostro = rectanguloRostro.width * rectanguloRostro.height;
    final areaImagen = tamanoImagen.width * tamanoImagen.height;
    final proporcionRostro = areaRostro / areaImagen;

    return proporcionRostro >= proporcionMinimaRostro &&
        proporcionRostro <= proporcionMaximaRostro;
  }

  /// Genera un color basado en el nivel de confianza
  static Color obtenerColorConfianza(double confianza) {
    if (confianza >= 0.8) return Colors.green;
    if (confianza >= 0.6) return Colors.orange;
    return Colors.red;
  }

  /// Formatea el porcentaje de confianza para mostrar
  static String formatearPorcentajeConfianza(double confianza) {
    return '${(confianza * 100).toStringAsFixed(1)}%';
  }

  /// Calcula la tasa de éxito de las detecciones
  static double calcularTasaExito(int exitosos, int total) {
    if (total == 0) return 0.0;
    return (exitosos / total) * 100;
  }
}

/// Configuraciones del sistema de detección
class ConfiguracionDeteccion {
  /// Configuración de la cámara
  static const configuracionCamara = {
    'resolucion': 'medium', // ResolutionPreset.medium
    'habilitarAudio': false,
    'formatoImagen': 'yuv420', // ImageFormatGroup.yuv420
  };

  /// Configuración del detector de rostros
  static const configuracionDetectorRostros = {
    'habilitarContornos': false,
    'habilitarClasificacion': false,
    'habilitarPuntosReferencia': false,
    'habilitarSeguimiento': true,
    'tamanoMinimoRostro': 0.15,
    'modoRendimiento': 'rapido', // FaceDetectorMode.fast
  };

  /// Configuración de la interfaz de usuario
  static const configuracionInterfazUsuario = {
    'duracionAnimacionEscaneo': 2000, // milisegundos
    'duracionAnimacionPulso': 800, // milisegundos
    'opacidadPanelEstado': 0.8,
    'opacidadEstadisticasTiempoReal': 0.8,
  };

  /// Configuración de la API
  static const configuracionApi = {
    'tiempoEsperaConexion': 10000, // milisegundos
    'tiempoEsperaLectura': 15000, // milisegundos
    'intentosReintento': 3,
  };
}

/// Mensajes del sistema
class MensajesSistema {
  static const String buscando = "🔍 Buscando estudiantes...";
  static const String listo =
      "✅ Sistema listo - Posiciónate frente a la cámara";
  static const String procesando = "🧠 Procesando...";
  static const String noRegistrado = "⚠️ Rostro no registrado en el sistema";
  static const String errorConexion = "❌ Error de conexión con el servidor";
  static const String sinEstudiantes = "📋 No hay estudiantes registrados";
  static const String errorCamara = "📷 Error con la cámara";
  static const String errorModelo = "🧠 Error cargando modelo de IA";

  static String estudianteDetectado(String nombre) => "✅ $nombre detectado";
  static String asistenciaMarcada(String nombre) =>
      "✅ Asistencia registrada: $nombre";
  static String estudiantesCargados(int cantidad) =>
      "📚 $cantidad estudiantes cargados";
}

/// Validadores del sistema
class ValidadoresSistema {
  /// Valida si el sistema puede iniciar la detección
  static bool puedeIniciarDeteccion({
    required bool estaInicializado,
    required bool estaDetectando,
    required bool tieneCamara,
    required bool tieneEstudiantes,
  }) {
    return estaInicializado &&
        !estaDetectando &&
        tieneCamara &&
        tieneEstudiantes;
  }

  /// Valida si se puede procesar una nueva detección
  static bool puedeProcesarNuevaDeteccion({
    required DateTime? ultimaDeteccion,
    required Duration tiempoEspera,
  }) {
    if (ultimaDeteccion == null) return true;
    return DateTime.now().difference(ultimaDeteccion) >= tiempoEspera;
  }

  /// Valida la respuesta de la API
  static bool esRespuestaApiValida(Map<String, dynamic>? respuesta) {
    if (respuesta == null) return false;

    return respuesta.containsKey('estado') &&
        respuesta.containsKey('mensaje') &&
        respuesta['estado'] is bool;
  }

  /// Valida los datos del embedding
  static bool esEmbeddingValido(List<double>? embedding) {
    if (embedding == null || embedding.isEmpty) return false;

    // Verificar que no contenga valores NaN o infinitos
    return embedding.every((valor) => valor.isFinite);
  }

  /// Valida las URLs de configuración
  static bool sonUrlsValidas(String urlApi, String urlFais) {
    if (urlApi.isEmpty || urlFais.isEmpty) return false;

    // Validación básica de formato URL
    try {
      Uri.parse(urlApi);
      Uri.parse(urlFais);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Valida los parámetros de detección
  static bool sonParametrosDeteccionValidos({
    required double umbralSimilitud,
    required int intervaloProcesamiento,
    required double tamanoGuiaRostro,
  }) {
    return umbralSimilitud >= 0.0 &&
        umbralSimilitud <= 1.0 &&
        intervaloProcesamiento > 0 &&
        tamanoGuiaRostro > 0;
  }
}

/// Utilidades de formato y conversión
class UtilidadesFormato {
  /// Formatea una fecha para mostrar
  static String formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  /// Formatea una fecha con hora para mostrar
  static String formatearFechaConHora(DateTime fecha) {
    return '${formatearFecha(fecha)} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  /// Formatea un número con separadores de miles
  static String formatearNumero(int numero) {
    return numero.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Formatea un porcentaje
  static String formatearPorcentaje(double valor, {int decimales = 1}) {
    return '${valor.toStringAsFixed(decimales)}%';
  }

  /// Formatea el tamaño de archivo
  static String formatearTamanoArchivo(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Constantes del sistema
class ConstantesSistema {
  // Colores del tema
  static const Color colorPrimario = Colors.blue;
  static const Color colorExito = Colors.green;
  static const Color colorAdvertencia = Colors.orange;
  static const Color colorError = Colors.red;
  static const Color colorInfo = Colors.blue;

  // Tamaños
  static const double tamanoIconoPequeno = 16.0;
  static const double tamanoIconoMedio = 24.0;
  static const double tamanoIconoGrande = 32.0;

  // Espaciado
  static const double espaciadoPequeno = 8.0;
  static const double espaciadoMedio = 16.0;
  static const double espaciadoGrande = 24.0;

  // Bordes redondeados
  static const double radioEsquinaPequeno = 4.0;
  static const double radioEsquinaMedio = 8.0;
  static const double radioEsquinaGrande = 16.0;

  // Elevación
  static const double elevacionBaja = 2.0;
  static const double elevacionMedia = 4.0;
  static const double elevacionAlta = 8.0;

  // Duraciones de animación
  static const Duration animacionRapida = Duration(milliseconds: 200);
  static const Duration animacionMedia = Duration(milliseconds: 400);
  static const Duration animacionLenta = Duration(milliseconds: 600);
}
