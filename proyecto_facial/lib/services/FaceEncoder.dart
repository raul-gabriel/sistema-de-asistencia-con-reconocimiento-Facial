import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceEncoder {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  Future<bool> loadModel() async {
    try {
      final modelData = await rootBundle.load('assets/facenet_512.tflite');
      final buffer = modelData.buffer.asUint8List();
      _interpreter = await Interpreter.fromBuffer(buffer);

      // Debug info
      final inputTensors = _interpreter!.getInputTensors();
      final outputTensors = _interpreter!.getOutputTensors();

      debugPrint('📥 Input shape: ${inputTensors.first.shape}');
      debugPrint('📤 Output shape: ${outputTensors.first.shape}');
      debugPrint('📊 Output type: ${outputTensors.first.type}');

      _isModelLoaded = true;
      debugPrint('✅ FaceNet-512 cargado correctamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error cargando modelo: $e');
      _isModelLoaded = false;
      return false;
    }
  }

  bool get isModelLoaded => _isModelLoaded;

  /// Preprocesamiento específico para FaceNet
  img.Image _preprocessForFaceNet(img.Image face) {
    // FaceNet requiere 160x160, no 112x112
    return img.copyResize(
      face,
      width: 160,
      height: 160,
      interpolation: img.Interpolation.cubic,
    );
  }

  /// Normalización específica para FaceNet
  Float32List _normalizeFaceNet(img.Image image) {
    Float32List input = Float32List(160 * 160 * 3);
    int index = 0;

    // FaceNet usa normalización [0, 1] con whitening
    for (var y = 0; y < 160; y++) {
      for (var x = 0; x < 160; x++) {
        final pixel = image.getPixel(x, y);

        // 🔥 NORMALIZACIÓN CORRECTA PARA FACENET
        // Convertir a [0, 1] y aplicar whitening estándar
        input[index++] = (pixel.r / 255.0 - 0.5) / 0.5; // [-1, 1]
        input[index++] = (pixel.g / 255.0 - 0.5) / 0.5;
        input[index++] = (pixel.b / 255.0 - 0.5) / 0.5;
      }
    }

    return input;
  }

  /// L2 Normalización del embedding
  List<double> _l2Normalize(List<double> embedding) {
    double norm = 0.0;
    for (double value in embedding) {
      norm += value * value;
    }
    norm = math.sqrt(norm);

    if (norm == 0.0) return embedding;

    return embedding.map((value) => value / norm).toList();
  }

  /// Procesar rostro con FaceNet-512
  List<double>? processFace(img.Image croppedFace) {
    if (!_isModelLoaded || _interpreter == null) {
      debugPrint('❌ Modelo no cargado');
      return null;
    }

    try {
      // 1. Preprocesar para FaceNet (160x160)
      final resized = _preprocessForFaceNet(croppedFace);

      // 2. Normalizar input
      final input = _normalizeFaceNet(resized);

      // 3. 🔥 CAMBIO CRÍTICO: 512 dimensiones, no 192
      var output = List.filled(512, 0.0).reshape([1, 512]);

      // 4. Ejecutar inferencia con shape correcto
      _interpreter!.run(input.reshape([1, 160, 160, 3]), output);

      // 5. Obtener y normalizar embedding
      final rawEmbedding = List<double>.from(output[0]);
      final normalizedEmbedding = _l2Normalize(rawEmbedding);

      debugPrint(
        '✅ Embedding generado: ${normalizedEmbedding.length} dimensiones',
      );
      return normalizedEmbedding;
    } catch (e) {
      debugPrint('❌ Error procesando rostro: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Calcular similitud coseno entre embeddings
  double calculateSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      debugPrint('❌ Embeddings de diferentes dimensiones');
      return 0.0;
    }

    double dotProduct = 0.0;
    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
    }

    // Los embeddings ya están L2-normalizados, así que el producto punto es la similitud coseno
    return dotProduct;
  }

  /// Verificar si dos rostros son de la misma persona
  bool verifyFaces(
    List<double> embedding1,
    List<double> embedding2, {
    double threshold = 0.6,
  }) {
    final similarity = calculateSimilarity(embedding1, embedding2);
    debugPrint(
      '🎯 Similitud: ${similarity.toStringAsFixed(4)} (threshold: $threshold)',
    );
    return similarity > threshold;
  }

  /// Encontrar la mejor coincidencia en una lista de embeddings
  Map<String, dynamic> findBestMatch(
    List<double> queryEmbedding,
    Map<String, List<double>> knownFaces, {
    double threshold = 0.6,
  }) {
    double bestSimilarity = -1.0;
    String? bestMatch;

    for (String name in knownFaces.keys) {
      final similarity = calculateSimilarity(queryEmbedding, knownFaces[name]!);
      if (similarity > bestSimilarity && similarity > threshold) {
        bestSimilarity = similarity;
        bestMatch = name;
      }
    }

    return {
      'name': bestMatch,
      'similarity': bestSimilarity,
      'isMatch': bestMatch != null,
    };
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
  }
}
