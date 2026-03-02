import 'package:flutter/material.dart';
import 'package:proyecto_facial/config/colores_app.dart';
import 'package:proyecto_facial/model/SesionUsuario.dart';
import 'package:proyecto_facial/sistencia_manual/AsistenciaManual.dart';
import 'package:proyecto_facial/views/ConfiguracionServidorPage.dart';
import 'package:proyecto_facial/views/Login.dart';
import 'package:proyecto_facial/views/pantalla_deteccion.dart';
import 'package:proyecto_facial/views/registrar_rostro_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SesionUsuario();

    return Scaffold(
      backgroundColor: ColoresApp.colorFondo,
      appBar: AppBar(
        title: const Text('Sistema de Asistencia Facial'),
        backgroundColor: ColoresApp.colorPrimario,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bienvenida al usuario
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ColoresApp.colorSombras.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: ColoresApp.colorprimario_500,
                    child: Icon(Icons.person, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.nombres} ${user.apellidos}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.rol ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Lógica para cerrar sesión (limpiar datos, navegar al login)
                      // Ejemplo simple:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    tooltip: 'Cerrar Sesión',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Menú de botones
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _MenuButton(
                    icon: Icons.person_add,
                    label: 'Registrar Rostros',
                    color: ColoresApp.colorPrimario,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrarRostroScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuButton(
                    icon: Icons.face_retouching_natural,
                    label: 'Registrar Asistencia automática',
                    color: ColoresApp.colorPrimario,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeteccionRostro(),
                        ),
                      );
                    },
                  ),

                  _MenuButton(
                    icon: Icons.face_retouching_natural_sharp,
                    label: 'Registrar Asistencia Manual',
                    color: ColoresApp.colorPrimario,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AsistenciaManual(),
                        ),
                      );
                    },
                  ),

                  _MenuButton(
                    icon: Icons.settings_rounded,
                    label: 'configuraciones',
                    color: ColoresApp.colorPrimario,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ConfiguracionServidorPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
