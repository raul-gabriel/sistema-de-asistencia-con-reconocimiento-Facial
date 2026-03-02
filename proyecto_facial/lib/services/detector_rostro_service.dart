// services/detector_rostro_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../model/rostro_detectado.dart';

/// Detector simplificado - solo para imágenes capturadas
/// Sin stream, optimizado para procesamiento único
class DetectorRostroService {
  FaceDetector? _detector;
  bool _estaInicializado = false;
  bool _estaProcesando = false;
  String? _ultimoError;

  // Getters públicos
  bool get estaInicializado => _estaInicializado;
  bool get estaProcesando => _estaProcesando;
  String? get ultimoError => _ultimoError;

  /// Inicializa detector con configuración óptima para precisión
  Future<bool> inicializar() async {
    try {
      _ultimoError = null;
      debugPrint('🎯 Inicializando detector optimizado...');

      // Configuración balanceada: precisión + velocidad
      _detector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: false, // No necesario
          enableClassification: false, // No necesario
          enableLandmarks: true, // Para validación de calidad
          enableTracking: false, // No necesario sin stream
          minFaceSize: 0.15, // 15% del frame (más estricto)
          performanceMode: FaceDetectorMode.accurate, // Máxima precisión
        ),
      );

      _estaInicializado = true;
      debugPrint('✅ Detector listo - Modo preciso');
      return true;
    } catch (e) {
      _ultimoError = e.toString();
      debugPrint('❌ Error detector: $e');
      return false;
    }
  }

  /// Procesa imagen capturada para detectar rostros
  Future<List<RostroDetectado>> procesarImagenCapturada(
    String rutaImagen,
  ) async {
    if (!_estaInicializado || _detector == null) {
      _ultimoError = 'Detector no inicializado';
      return [];
    }

    if (_estaProcesando) {
      debugPrint('⚠️ Detector ocupado');
      return [];
    }

    _estaProcesando = true;

    try {
      debugPrint('🔍 Analizando imagen...');

      // Crear InputImage desde archivo
      final inputImage = InputImage.fromFilePath(rutaImagen);

      // Detectar rostros
      final rostrosML = await _detector!.processImage(inputImage);

      if (rostrosML.isEmpty) {
        debugPrint('❌ Sin rostros detectados');
        return [];
      }

      debugPrint('✅ ${rostrosML.length} rostro(s) encontrado(s)');

      // Convertir y filtrar rostros válidos
      final rostrosValidos = <RostroDetectado>[];

      for (final rostro in rostrosML) {
        if (_esRostroValido(rostro)) {
          rostrosValidos.add(
            RostroDetectado(rostro: rostro, rectangulo: rostro.boundingBox),
          );
          debugPrint(
            '  ✅ Rostro válido: ${_calcularArea(rostro.boundingBox).toInt()}px²',
          );
        } else {
          debugPrint('  ❌ Rostro descartado por calidad');
        }
      }

      return rostrosValidos;
    } catch (e) {
      _ultimoError = e.toString();
      debugPrint('❌ Error procesando: $e');
      return [];
    } finally {
      _estaProcesando = false;
    }
  }

  /// Valida si un rostro cumple criterios de calidad
  /// OPTIMIZADO: Criterios más estrictos para mejor precisión
  bool validarCalidadRostro(RostroDetectado rostro) {
    // 1. Tamaño mínimo más estricto
    if (!_esRostroValido(rostro.rostro)) {
      debugPrint('❌ Rostro muy pequeño o mal detectado');
      return false;
    }

    // 2. Landmarks obligatorios
    if (rostro.rostro.landmarks.isEmpty) {
      debugPrint('❌ Sin landmarks - detección poco confiable');
      return false;
    }

    // 3. Ángulos extremos (más estricto)
    final anguloY = rostro.rostro.headEulerAngleY;
    final anguloZ = rostro.rostro.headEulerAngleZ;

    if (anguloY != null && anguloY.abs() > 35) {
      // Más estricto: 35° vs 45°
      debugPrint('❌ Rostro muy ladeado: ${anguloY.toStringAsFixed(1)}°');
      return false;
    }

    if (anguloZ != null && anguloZ.abs() > 25) {
      // Más estricto: 25° vs 30°
      debugPrint('❌ Rostro muy inclinado: ${anguloZ.toStringAsFixed(1)}°');
      return false;
    }

    debugPrint('✅ Rostro de alta calidad validado');
    return true;
  }

  /// Selecciona el mejor rostro de una lista
  /// OPTIMIZADO: Prioriza calidad > tamaño > posición central
  RostroDetectado? seleccionarMejorRostro(
    List<RostroDetectado> rostros,
    Size? dimensionImagen,
  ) {
    if (rostros.isEmpty) return null;
    if (rostros.length == 1) return rostros.first;

    debugPrint('🎯 Seleccionando mejor de ${rostros.length} rostros...');

    RostroDetectado? mejorRostro;
    double mejorPuntuacion = 0;

    for (final rostro in rostros) {
      double puntuacion = 0;

      // 1. CALIDAD (peso mayor - 60%)
      if (validarCalidadRostro(rostro)) {
        puntuacion += 60;

        // Bonus por landmarks específicos
        final landmarks = rostro.rostro.landmarks;
        if (landmarks.containsKey(FaceLandmarkType.leftEye) &&
            landmarks.containsKey(FaceLandmarkType.rightEye)) {
          puntuacion += 10; // Ojos detectados
        }
        if (landmarks.containsKey(FaceLandmarkType.noseBase)) {
          puntuacion += 5; // Nariz detectada
        }
      }

      // 2. TAMAÑO (peso medio - 25%)
      final area = _calcularArea(rostro.rectangulo);
      puntuacion += (area / 50000) * 25; // Normalizar área

      // 3. POSICIÓN CENTRAL (peso menor - 15%)
      if (dimensionImagen != null) {
        final centroImagen = Offset(
          dimensionImagen.width / 2,
          dimensionImagen.height / 2,
        );
        final centroRostro = rostro.rectangulo.center;
        final distancia = (centroImagen - centroRostro).distance;
        final distanciaMax = dimensionImagen.width / 2;
        final factorCentrado = 1 - (distancia / distanciaMax);
        puntuacion += factorCentrado * 15;
      }

      debugPrint('  📊 Rostro puntuación: ${puntuacion.toStringAsFixed(1)}');

      if (puntuacion > mejorPuntuacion) {
        mejorPuntuacion = puntuacion;
        mejorRostro = rostro;
      }
    }

    if (mejorRostro != null) {
      debugPrint(
        '✅ Mejor rostro: ${mejorPuntuacion.toStringAsFixed(1)} puntos',
      );
    }

    return mejorRostro;
  }

  // MÉTODOS AUXILIARES PRIVADOS

  /// Valida rostro ML Kit básico
  bool _esRostroValido(Face rostro) {
    final area = _calcularArea(rostro.boundingBox);
    return area > 15000; // Área mínima más estricta
  }

  /// Calcula área del rectángulo
  double _calcularArea(Rect rectangulo) {
    return rectangulo.width * rectangulo.height;
  }

  /// Reinicia detector
  Future<bool> reiniciar() async {
    debugPrint('🔄 Reiniciando detector...');
    await dispose();
    await Future.delayed(const Duration(milliseconds: 100));
    return await inicializar();
  }

  /// Libera recursos
  Future<void> dispose() async {
    debugPrint('🗑️ Liberando detector...');
    _estaInicializado = false;
    _estaProcesando = false;

    try {
      if (_detector != null) {
        await _detector!.close();
        _detector = null;
      }
      debugPrint('✅ Detector liberado');
    } catch (e) {
      debugPrint('❌ Error liberando detector: $e');
    }
  }

  /// Estadísticas simplificadas
  Map<String, dynamic> obtenerEstadisticas() {
    return {
      'inicializado': _estaInicializado,
      'procesando': _estaProcesando,
      'ultimo_error': _ultimoError,
    };
  }
}
