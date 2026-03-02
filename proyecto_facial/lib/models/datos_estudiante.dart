import 'dart:ui';

class DatosEstudiante {
  final String nombre;
  final String curso;
  final DateTime fechaRegistro;

  DatosEstudiante({
    required this.nombre,
    required this.curso,
    required this.fechaRegistro,
  });
}

class CoincidenciaEstudiante {
  final int indiceRostro;
  final Rect cajaDelimitadora;
  final DatosEstudiante? estudiante;
  final double confianza;
  final bool esCoincidencia;

  CoincidenciaEstudiante({
    required this.indiceRostro,
    required this.cajaDelimitadora,
    this.estudiante,
    required this.confianza,
    required this.esCoincidencia,
  });
}

class RespuestaApi {
  final String estado;
  final String mensaje;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String nivel;

  RespuestaApi({
    required this.estado,
    required this.mensaje,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.nivel,
  });

  factory RespuestaApi.convertirJson(Map<String, dynamic> json) {
    return RespuestaApi(
      estado: (json['estado'] ?? 0),
      mensaje: json['mensaje'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidoPaterno: json['apellido_paterno'] ?? '',
      apellidoMaterno: json['apellido_materno'] ?? '',
      nivel: json['nivel'] ?? '',
    );
  }

  DatosEstudiante aDatosEstudiante() {
    return DatosEstudiante(
      nombre: '$nombres $apellidoPaterno $apellidoMaterno'.trim(),
      curso: nivel,
      fechaRegistro: DateTime.now(),
    );
  }
}
