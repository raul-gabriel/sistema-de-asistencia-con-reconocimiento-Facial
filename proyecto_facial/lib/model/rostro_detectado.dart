// models/rostro_detectado.dart
import 'dart:ui';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Modelo que representa un rostro detectado con su información asociada
class RostroDetectado {
  final Face rostro;
  final Rect rectangulo;
  final List<double>? embedding;
  final String? nombrePersona;
  final bool estaValidado;
  final DateTime fechaDeteccion;

  RostroDetectado({
    required this.rostro,
    required this.rectangulo,
    this.embedding,
    this.nombrePersona,
    this.estaValidado = false,
    DateTime? fechaDeteccion,
  }) : fechaDeteccion = fechaDeteccion ?? DateTime.now();

  /// Crea una copia del rostro con nuevos valores
  RostroDetectado copiarCon({
    Face? rostro,
    Rect? rectangulo,
    List<double>? embedding,
    String? nombrePersona,
    bool? estaValidado,
  }) {
    return RostroDetectado(
      rostro: rostro ?? this.rostro,
      rectangulo: rectangulo ?? this.rectangulo,
      embedding: embedding ?? this.embedding,
      nombrePersona: nombrePersona ?? this.nombrePersona,
      estaValidado: estaValidado ?? this.estaValidado,
      fechaDeteccion: fechaDeteccion,
    );
  }

  /// Verifica si el rostro tiene embedding generado
  bool get tieneEmbedding => embedding != null && embedding!.isNotEmpty;

  /// Verifica si el rostro está listo para ser guardado
  bool get listo => tieneEmbedding && nombrePersona?.isNotEmpty == true;

  /// Calcula el área del rostro detectado
  double get area => rectangulo.width * rectangulo.height;

  /// Verifica si es un rostro de dimension válido (no muy pequeño)
  bool get dimensionValido => area > 10000; // Área mínima en píxeles

  @override
  String toString() {
    return 'RostroDetectado(area: ${area.toStringAsFixed(0)}, '
        'embedding: ${tieneEmbedding ? '${embedding!.length}D' : 'No'}, '
        'nombre: ${nombrePersona ?? 'Sin nombre'})';
  }
}
