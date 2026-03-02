// services/camara_service.dart
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Servicio simplificado de cámara - solo para captura
/// Sin stream innecesario, optimizado para registro
class CamaraService {
  CameraController? _controlador;
  bool _estaInicializada = false;
  String? _ultimoError;

  // Getters públicos
  CameraController? get controlador => _controlador;
  bool get estaInicializada =>
      _estaInicializada && _controlador?.value.isInitialized == true;
  String? get ultimoError => _ultimoError;
  Size? get dimensionPreview => _controlador?.value.previewSize;

  /// Inicializa la cámara optimizada para captura única
  Future<bool> inicializar() async {
    try {
      _ultimoError = null;

      // Obtener cámaras disponibles
      final camarasDisponibles = await availableCameras();
      if (camarasDisponibles.isEmpty) {
        throw Exception('No hay cámaras disponibles');
      }

      // Seleccionar mejor cámara (frontal preferida para selfies)
      final camaraOptima = _seleccionarMejorCamara(camarasDisponibles);
      debugPrint('📱 Inicializando: ${camaraOptima.name}');

      // Configurar para máxima calidad sin audio
      _controlador = CameraController(
        camaraOptima,
        ResolutionPreset
            .veryHigh, // Optimizado: muy alta, no max para velocidad
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      // Inicializar
      await _controlador!.initialize();

      // Configuración rápida optimizada
      await _aplicarConfiguracionRapida();

      _estaInicializada = true;
      debugPrint(
        '✅ Cámara lista: ${dimensionPreview?.width}x${dimensionPreview?.height}',
      );

      return true;
    } catch (e) {
      _ultimoError = e.toString();
      debugPrint('❌ Error cámara: $e');
      return false;
    }
  }

  /// Selecciona la mejor cámara (frontal para selfies)
  CameraDescription _seleccionarMejorCamara(List<CameraDescription> camaras) {
    // Buscar frontal primero
    final frontal = camaras
        .where((c) => c.lensDirection == CameraLensDirection.front)
        .firstOrNull;
    if (frontal != null) {
      debugPrint('📱 Usando cámara frontal');
      return frontal;
    }

    debugPrint('📱 Usando cámara trasera');
    return camaras.first;
  }

  /// Configuración mínima para velocidad
  Future<void> _aplicarConfiguracionRapida() async {
    if (_controlador == null) return;

    try {
      // Solo configuraciones esenciales
      await _controlador!.setFlashMode(FlashMode.off);
      await _controlador!.setFocusMode(FocusMode.auto);
      debugPrint('⚙️ Configuración rápida aplicada');
    } catch (e) {
      debugPrint('⚠️ Error config: $e');
      // No es crítico, continúa
    }
  }

  /// Captura foto optimizada sin stream previo
  Future<XFile?> capturarFoto() async {
    if (!estaInicializada) {
      _ultimoError = 'Cámara no inicializada';
      return null;
    }

    try {
      debugPrint('📸 Capturando foto...');

      final foto = await _controlador!.takePicture();

      debugPrint('✅ Foto capturada: ${foto.path}');
      return foto;
    } catch (e) {
      _ultimoError = e.toString();
      debugPrint('❌ Error captura: $e');
      return null;
    }
  }

  /// Reinicia cámara completamente
  Future<bool> reiniciar() async {
    debugPrint('🔄 Reiniciando cámara...');
    await dispose();
    await Future.delayed(const Duration(milliseconds: 200));
    return await inicializar();
  }

  /// Libera recursos
  Future<void> dispose() async {
    debugPrint('🗑️ Liberando cámara...');
    _estaInicializada = false;

    try {
      if (_controlador != null) {
        await _controlador!.dispose();
        _controlador = null;
      }
      debugPrint('✅ Cámara liberada');
    } catch (e) {
      debugPrint('❌ Error liberando: $e');
    }
  }

  /// Estado actual simplificado
  EstadoCamara obtenerEstado() {
    if (_ultimoError != null) return EstadoCamara.error;
    if (!_estaInicializada) return EstadoCamara.noInicializada;
    if (_controlador?.value.isInitialized != true)
      return EstadoCamara.inicializando;
    return EstadoCamara.lista;
  }
}

/// Estados posibles de la cámara (simplificado)
enum EstadoCamara { noInicializada, inicializando, lista, error }
