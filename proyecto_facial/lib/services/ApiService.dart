import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:proyecto_facial/models/datos_estudiante.dart';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<String> _obtenerBaseUrlApi() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('server_url') ?? 'http://localhost:9000') + '/api';
  }

  static Future<String> _obtenerbaseUrlFaisAsistencia() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_url_faiss') ?? 'http://localhost:8000';
  }

  /// POST - Enviar embedding
  static Future<String> enviarEmbedding({
    required int idAlumno,
    required List<double> embedding,
  }) async {
    try {
      // URL para enviar embedding
      final baseUrlApi = await _obtenerBaseUrlApi();
      final url = Uri.parse('$baseUrlApi/guardarembedding');
      final body = {"id_alumno": idAlumno, "embedding": embedding};

      debugPrint('📤 Enviando $url \n embedding para alumno: $idAlumno');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final mensaje = responseData['mensaje'] ?? 'Sin mensaje';

        debugPrint('✅ Respuesta API: $mensaje');
        return mensaje;
      } else {
        debugPrint('❌ Error HTTP: ${response.statusCode}');
        return 'Error HTTP ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('❌ Excepción: $e');
      return 'Error de conexión';
    }
  }

  /// GET - Buscar alumnos por filtro (DNI o nombre completo)
  static Future<List<Alumno>?> buscarAlumno(String filtro) async {
    try {
      final baseUrlApi = await _obtenerBaseUrlApi();
      final url = Uri.parse('$baseUrlApi/alumnos?buscar=$filtro');

      debugPrint('🔗 URL: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final alumnos = jsonData.map((json) => Alumno.fromJson(json)).toList();

        debugPrint('✅ ${alumnos.length} alumnos encontrados');
        return alumnos;
      } else {
        debugPrint('❌ Error en búsqueda: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error de conexión en búsqueda: $e');
      return null;
    }
  }

  //registrar desde python
  static Future<RespuestaApi?> registrarAsistencia(
    List<double> embedding,
  ) async {
    try {
      debugPrint(
        '\x1B[31m🚀 Enviando embedding de ${embedding.length} dimensiones',
      );

      // ✅ CORRECCIÓN: Definir la URL como Uri
      final baseUrlFaisAsistencia = await _obtenerbaseUrlFaisAsistencia();
      final url = Uri.parse('$baseUrlFaisAsistencia/reconocer');
      debugPrint('🔗 URL: $url');

      final body = {"embedding": embedding};
      final bodyJson = jsonEncode(body);

      debugPrint('📤\x1B[31m🚀  Body completo: $bodyJson');

      final response = await http
          .post(
            url, // ✅ Ahora sí está definida
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: bodyJson,
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('📥 Status Code: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final respuesta = RespuestaApi.convertirJson(json);

        debugPrint('⚠️ Estudiante no encontrado: ${respuesta.mensaje}');

        return respuesta;
      } else {
        debugPrint(
          '❌ \x1B[31mError HTTP: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('❌ \x1B[31m Error en registrarAsistencia: $e');
      return null;
    }
  }

  /// 🔐 LOGIN DE USUARIO
  static Future<Map<String, dynamic>> iniciarSesion({
    required String username,
    required String password,
  }) async {
    try {
      final baseUrlApi = await _obtenerBaseUrlApi();
      final url = Uri.parse('$baseUrlApi/login');
      final body = {'username': username, 'password': password};

      debugPrint('📤 Enviando login a $url con $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('📥 Status Code: ${response.statusCode}');
      debugPrint('📥 Body: ${response.body}');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        debugPrint('✅ Inicio de sesión exitoso');
        return {
          'success': true,
          'user': jsonData['user'],
          'message': jsonData['message'],
        };
      } else {
        debugPrint('❌ Error de autenticación');
        return {
          'success': false,
          'message': jsonData['message'] ?? 'Credenciales incorrectas',
        };
      }
    } catch (e) {
      debugPrint('❌ Excepción en iniciarSesion: $e');
      return {'success': false, 'message': 'Error de conexión'};
    }
  }
}

/// Modelo de datos para Alumno
class Alumno {
  final int id;
  final String codigoModular;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String dni;
  final String grado;
  final String seccion;
  final String nivel;
  final String? apoderadoNombre;
  final String? apoderadoTelefono;
  final int idHorario;
  final String estado;

  Alumno({
    required this.id,
    required this.codigoModular,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.dni,
    required this.grado,
    required this.seccion,
    required this.nivel,
    required this.idHorario,
    required this.estado,
    this.apoderadoNombre,
    this.apoderadoTelefono,
  });

  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['id'],
      codigoModular: json['codigo_modular'],
      nombres: json['nombres'],
      apellidoPaterno: json['apellido_paterno'],
      apellidoMaterno: json['apellido_materno'],
      dni: json['dni'],
      grado: json['grado'],
      seccion: json['seccion'],
      nivel: json['nivel'],
      apoderadoNombre: json['apoderado_nombre'],
      apoderadoTelefono: json['apoderado_telefono'],
      idHorario: json['id_horario'],
      estado: json['estado'],
    );
  }

  String get nombreCompleto => '$nombres $apellidoPaterno $apellidoMaterno';
}
