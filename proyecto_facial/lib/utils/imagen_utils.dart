// utils/imagen_utils.dart
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

/// Utilidades para procesamiento de imágenes y conversiones
class ImagenUtils {
  /// Convierte CameraImage a InputImage de forma optimizada
  static InputImage? convertirCameraImageAInputImage(CameraImage imagen) {
    try {
      final WriteBuffer todosLosBytes = WriteBuffer();
      for (final Plane plano in imagen.planes) {
        todosLosBytes.putUint8List(plano.bytes);
      }
      final bytes = todosLosBytes.done().buffer.asUint8List();

      final metadatos = InputImageMetadata(
        size: Size(imagen.width.toDouble(), imagen.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: imagen.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadatos);
    } catch (e) {
      print('❌ Error convirtiendo CameraImage: $e');
      return null;
    }
  }

  /// Recorta el rostro de la imagen con padding óptimo
  static img.Image? recortarRostroConPadding(
    img.Image imagenCompleta,
    Rect rectanguloRostro, {
    double factorPadding = 0.4,
  }) {
    try {
      // Calcular padding óptimo basado en el dimension del rostro
      final paddingOptimo = max(
        rectanguloRostro.width * factorPadding,
        rectanguloRostro.height * factorPadding,
      );

      // Calcular coordenadas con padding, respetando límites de imagen
      final izquierda = (rectanguloRostro.left - paddingOptimo)
          .clamp(0, imagenCompleta.width - 1)
          .toInt();
      final arriba = (rectanguloRostro.top - paddingOptimo)
          .clamp(0, imagenCompleta.height - 1)
          .toInt();
      final derecha = (rectanguloRostro.right + paddingOptimo)
          .clamp(0, imagenCompleta.width - 1)
          .toInt();
      final abajo = (rectanguloRostro.bottom + paddingOptimo)
          .clamp(0, imagenCompleta.height - 1)
          .toInt();

      return img.copyCrop(
        imagenCompleta,
        x: izquierda,
        y: arriba,
        width: derecha - izquierda,
        height: abajo - arriba,
      );
    } catch (e) {
      print('❌ Error recortando rostro: $e');
      return null;
    }
  }

  /// Escala un rectángulo de rostro para display en pantalla
  static Rect escalarRectanguloParaPantalla(
    Rect rectanguloOriginal,
    Size dimensionImagen,
    Size dimensionPantalla,
  ) {
    final escalaX = dimensionPantalla.width / dimensionImagen.width;
    final escalaY = dimensionPantalla.height / dimensionImagen.height;
    final escala = min(escalaX, escalaY);

    final anchoImagenEscalado = dimensionImagen.width * escala;
    final altoImagenEscalado = dimensionImagen.height * escala;
    final offsetX = (dimensionPantalla.width - anchoImagenEscalado) / 2;
    final offsetY = (dimensionPantalla.height - altoImagenEscalado) / 2;

    return Rect.fromLTWH(
      rectanguloOriginal.left * escala + offsetX,
      rectanguloOriginal.top * escala + offsetY,
      rectanguloOriginal.width * escala,
      rectanguloOriginal.height * escala,
    );
  }

  /// Carga y decodifica imagen desde archivo
  static Future<img.Image?> cargarImagenDesdeArchivo(String rutaArchivo) async {
    try {
      final archivo = File(rutaArchivo);
      if (!await archivo.exists()) {
        print('❌ Archivo no existe: $rutaArchivo');
        return null;
      }

      final bytes = await archivo.readAsBytes();
      return img.decodeImage(bytes);
    } catch (e) {
      print('❌ Error cargando imagen: $e');
      return null;
    }
  }

  /// Calcula el área de un rectángulo
  static double calcularArea(Rect rectangulo) {
    return rectangulo.width * rectangulo.height;
  }

  /// Verifica si un rostro tiene dimension mínimo válido
  static bool esdimensionValido(Rect rectangulo, {double areaMinima = 10000}) {
    return calcularArea(rectangulo) >= areaMinima;
  }
}
