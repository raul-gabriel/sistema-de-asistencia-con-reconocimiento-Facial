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

class AsistenciaManual extends StatefulWidget {
  const AsistenciaManual({super.key});

  @override
  State<AsistenciaManual> createState() => _AsistenciaManualState();
}

class _AsistenciaManualState extends State<AsistenciaManual> {
  // Controladores principales
  CameraController? _controladorCamara;
  late FaceDetector _detectorRostros;
  late FaceEncoder _codificadorRostros;

  // Estados simples
  bool _estaInicializado = false;
  bool _estaProcesando = false;
  String? _mensajeError;
  String _mensajeEstado = "📷 Listo para capturar";
  Color _colorEstado = Colors.blue;

  @override
  void initState() {
    super.initState();
    _inicializarSistema();
  }

  Future<void> _inicializarSistema() async {
    try {
      // Detector de rostros
      _detectorRostros = FaceDetector(
        options: FaceDetectorOptions(
          minFaceSize: 0.15,
          performanceMode: FaceDetectorMode.fast,
        ),
      );

      // Codificador facial
      _codificadorRostros = FaceEncoder();
      await _codificadorRostros.loadModel();

      // Cámara trasera
      final camaras = await availableCameras();
      final camaraTrasera = camaras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => camaras.first,
      );

      _controladorCamara = CameraController(
        camaraTrasera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controladorCamara!.initialize();

      setState(() {
        _estaInicializado = true;
        _mensajeEstado = "✅ Listo - Presiona para capturar";
        _colorEstado = Colors.green;
      });
    } catch (e) {
      setState(() => _mensajeError = 'Error: $e');
    }
  }

  // 🔥 FUNCIÓN PRINCIPAL - SIMPLE Y RÁPIDA
  Future<void> _capturarAsistencia() async {
    if (_estaProcesando) return;

    setState(() {
      _estaProcesando = true;
      _mensajeEstado = "📸 Capturando...";
      _colorEstado = Colors.blue;
    });

    HapticFeedback.mediumImpact();

    try {
      // 1. Tomar foto
      final foto = await _controladorCamara!.takePicture();

      setState(() => _mensajeEstado = "🔍 Detectando rostros...");

      // 2. Detectar rostros
      final imagenEntrada = InputImage.fromFilePath(foto.path);
      final rostros = await _detectorRostros.processImage(imagenEntrada);

      if (rostros.isEmpty) {
        _mostrarError("❌ No se detectaron rostros");
        return;
      }

      setState(() => _mensajeEstado = "🧠 Procesando...");

      // 3. Extraer embedding del primer rostro
      final embedding = await _extraerEmbedding(foto.path, rostros.first);

      if (embedding == null) {
        _mostrarError("❌ Error procesando rostro");
        return;
      }

      setState(() => _mensajeEstado = "📡 Consultando sistema...");

      // 4. Enviar a API
      final respuesta = await ApiService.registrarAsistencia(embedding);

      // 5. Mostrar resultado
      if (respuesta != null) {
        if (respuesta.estado == 'ASISTENCIA_REGISTRADO_PUNTUAL' ||
            respuesta.estado == 'ASISTENCIA_REGISTRADO_TARDE') {
          final estudiante = respuesta.aDatosEstudiante();
          _mostrarExito(estudiante, respuesta.mensaje);
        } else {
          _mostrarError(respuesta.mensaje);
        }
      } else {
        _mostrarError("❌ Error de conexión");
      }

      // Limpiar archivo
      await File(foto.path).delete();
    } catch (e) {
      _mostrarError("❌ Error: $e");
    } finally {
      setState(() {
        _estaProcesando = false;
        _mensajeEstado = "📷 Listo para capturar";
        _colorEstado = Colors.blue;
      });
    }
  }

  void _mostrarExito(DatosEstudiante estudiante, String mensaje) {
    setState(() {
      _mensajeEstado = "✅ Asistencia registrada";
      _colorEstado = Colors.green;
    });

    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('✅ ÉXITO', style: TextStyle(color: Colors.green)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '👤 ${estudiante.nombre}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('🏫 ${estudiante.curso}'),
            SizedBox(height: 8),
            Text('📝 $mensaje', style: TextStyle(color: Colors.green[700])),
            SizedBox(height: 8),
            Text(
              '🕒 ${_formatearFecha(DateTime.now())}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarError(String mensaje) {
    setState(() {
      _mensajeEstado = "⚠️ Error";
      _colorEstado = Colors.red;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('❌', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
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
      if (imagen == null) return null;

      final rect = rostro.boundingBox;
      final padding = max(rect.width * 0.2, rect.height * 0.2);

      final x = (rect.left - padding).clamp(0, imagen.width - 1).toInt();
      final y = (rect.top - padding).clamp(0, imagen.height - 1).toInt();
      final w = (rect.width + padding * 2).clamp(0, imagen.width - x).toInt();
      final h = (rect.height + padding * 2).clamp(0, imagen.height - y).toInt();

      final rostroRecortado = img.copyCrop(
        imagen,
        x: x,
        y: y,
        width: w,
        height: h,
      );
      return await _codificadorRostros.processFace(rostroRecortado);
    } catch (e) {
      debugPrint('Error extrayendo embedding: $e');
      return null;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
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
        title: Text('📷 Asistencia Manual'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _construirInterfaz(),
    );
  }

  Widget _construirInterfaz() {
    if (_mensajeError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              _mensajeError!,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _mensajeError = null);
                _inicializarSistema();
              },
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (!_estaInicializado) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              '🚀 Inicializando...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Vista de cámara
        SizedBox.expand(child: CameraPreview(_controladorCamara!)),

        // Panel de estado
        Positioned(
          top: 20,
          left: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: _colorEstado.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _colorEstado,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _mensajeEstado,
                    style: TextStyle(
                      color: _colorEstado,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
        ),

        // Botón de captura
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _estaProcesando ? null : _capturarAsistencia,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _estaProcesando ? Colors.grey : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _estaProcesando
                    ? CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 3,
                      )
                    : Icon(Icons.camera_alt, color: Colors.black, size: 32),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
