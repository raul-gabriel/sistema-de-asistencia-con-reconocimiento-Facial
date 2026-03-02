/// Configuración principal de la aplicación
class ConfiguracionApp {
  // URLs de los servicios
  static const String urlBaseApi =
      'http://192.168.1.30/APP_RECONOCIMIENTO_FACIAL/oficial/backend/api';
  static const String urlBaseFaisAsistencia = 'http://localhost:8000/';

  // Configuración de la detección facial
  static const double umbralSimilitud = 0.65;
  static const int intervaloProcesamientoMs = 50; // 20 FPS
  static const double tamanoGuiaRostro = 280.0;
  static const Duration tiempoEsperaDeteccion = Duration(seconds: 3);

  // Configuración de la cámara
  static const String resolucionCamara = 'medium';
  static const bool habilitarAudio = false;
  static const String formatoImagen = 'yuv420';

  // Configuración del detector
  static const double tamanoMinimoRostro = 0.15;
  static const bool habilitarSeguimiento = true;
  static const String modoRendimiento = 'fast';

  // Tiempos de espera de red
  static const int tiempoEsperaConexionMs = 10000;
  static const int tiempoEsperaLecturaMs = 15000;
  static const int maximoReintentos = 3;

  // Configuración de interfaz de usuario
  static const int duracionAnimacionEscaneoMs = 2000;
  static const int duracionAnimacionPulsoMs = 800;
  static const double opacidadSuperposicion = 0.8;

  // Configuración de registros
  static const bool habilitarRegistrosDebug = true;
  static const bool habilitarRegistrosRendimiento = true;

  // Versión de la aplicación
  static const String versionApp = '2.0.0';
  static const String numeroCompilacion = '20240128';

  // Configuración de la base de datos (si se necesita en el futuro)
  static const String nombreBaseDatos = 'reconocimiento_facial.db';
  static const int versionBaseDatos = 1;

  // Configuración de caché
  static const int tamanoMaximoCache = 100;
  static const Duration expiracionCache = Duration(hours: 24);

  // Configuración de notificaciones
  static const bool habilitarRetroalimentacionHaptica = true;
  static const bool habilitarRetroalimentacionSonido = false;
  static const bool habilitarRetroalimentacionVisual = true;

  // Configuración de seguridad
  static const int maximoIntentosError = 5;
  static const Duration duracionBloqueo = Duration(minutes: 5);

  // Configuración de estadísticas
  static const bool habilitarEstadisticasTiempoReal = true;
  static const bool habilitarMetricasRendimiento = true;
  static const Duration intervaloActualizacionEstadisticas = Duration(
    seconds: 1,
  );

  // Configuración de archivos temporales
  static const String prefijoImagenTemporal = 'deteccion_rostro_';
  static const String extensionImagenTemporal = '.jpg';
  static const Duration intervaloLimpiezaArchivosTemporal = Duration(
    minutes: 10,
  );

  // Configuración de calidad de imagen
  static const double calidadMinimaImagen = 0.7;
  static const int anchoMaximoImagen = 1920;
  static const int altoMaximoImagen = 1080;

  // Configuración de embeddings
  static const int dimensionesEmbedding = 512;
  static const double umbralNormaEmbedding = 0.1;

  // Configuración de errores
  static const int maximoReintentosError = 3;
  static const Duration tiempoEsperaError = Duration(seconds: 30);

  // Métodos de configuración dinámica
  static bool get esModoDebug => habilitarRegistrosDebug;
  static bool get esModoProduccion => !habilitarRegistrosDebug;

  static String get endpointApiReconocimiento =>
      '$urlBaseFaisAsistencia/reconocer';
  static String get endpointApiEstudiantes => '$urlBaseApi/estudiantes';
  static String get endpointApiAsistencia => '$urlBaseApi/marcar-asistencia';
  static String get endpointApiEstadisticas => '$urlBaseApi/estadisticas';

  // Validaciones de configuración
  static bool validarConfiguracion() {
    // Validar URLs
    if (urlBaseApi.isEmpty || urlBaseFaisAsistencia.isEmpty) {
      return false;
    }

    // Validar parámetros de detección
    if (umbralSimilitud < 0.0 || umbralSimilitud > 1.0) {
      return false;
    }

    if (intervaloProcesamientoMs <= 0 || tamanoGuiaRostro <= 0) {
      return false;
    }

    // Validar tiempos de espera
    if (tiempoEsperaConexionMs <= 0 || tiempoEsperaLecturaMs <= 0) {
      return false;
    }

    return true;
  }

  static Map<String, dynamic> aJson() {
    return {
      'urlBaseApi': urlBaseApi,
      'urlBaseFaisAsistencia': urlBaseFaisAsistencia,
      'umbralSimilitud': umbralSimilitud,
      'intervaloProcesamientoMs': intervaloProcesamientoMs,
      'tamanoGuiaRostro': tamanoGuiaRostro,
      'tiempoEsperaDeteccionSegundos': tiempoEsperaDeteccion.inSeconds,
      'versionApp': versionApp,
      'numeroCompilacion': numeroCompilacion,
      'esModoDebug': esModoDebug,
    };
  }
}
