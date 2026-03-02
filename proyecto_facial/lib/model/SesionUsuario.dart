class SesionUsuario {
  static final SesionUsuario _instancia = SesionUsuario._internal();

  factory SesionUsuario() => _instancia;

  SesionUsuario._internal();

  int? id;
  String? nombres;
  String? apellidos;
  String? rol;

  void iniciarSesion(Map<String, dynamic> user) {
    id = user['id'];
    nombres = user['nombres'];
    apellidos = user['apellidos'];
    rol = user['rol'];
  }

  void cerrarSesion() {
    id = null;
    nombres = null;
    apellidos = null;
    rol = null;
  }

  bool get estaLogueado => id != null;
}
