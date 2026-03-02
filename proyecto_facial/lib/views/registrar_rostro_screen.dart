// views/registrar_rostro_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:proyecto_facial/config/colores_app.dart';
import '../controllers/registro_rostro_controller.dart';
import '../utils/imagen_utils.dart';
import '../services/ApiService.dart';

/// Pantalla optimizada para registro facial
/// UI simple y directa: Preview → Capturar → Seleccionar Alumno → Enviar
class RegistrarRostroScreen extends StatefulWidget {
  const RegistrarRostroScreen({super.key});

  @override
  State<RegistrarRostroScreen> createState() => _RegistrarRostroScreenState();
}

class _RegistrarRostroScreenState extends State<RegistrarRostroScreen> {
  late final RegistroRostroController _controlador;
  final TextEditingController _buscadorController = TextEditingController();
  List<Alumno> _alumnosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _controlador = RegistroRostroController();
    _controlador.addListener(_onControladorCambiado);

    // Inicializar sistema
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controlador.inicializar();
    });
  }

  void _onControladorCambiado() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controlador.removeListener(_onControladorCambiado);
    _controlador.dispose();
    _buscadorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('📸 Registro Facial Optimizado'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Mostrar estado del sistema
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _obtenerColorEstado(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _obtenerTextoEstado(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: _construirCuerpo(),
    );
  }

  Color _obtenerColorEstado() {
    if (_controlador.mensajeError != null) return Colors.red;
    if (_controlador.estaInicializando) return Colors.orange;
    if (!_controlador.camaraLista || !_controlador.encoderListo)
      return Colors.orange;
    return Colors.green;
  }

  String _obtenerTextoEstado() {
    if (_controlador.mensajeError != null) return 'ERROR';
    if (_controlador.estaInicializando) return 'CARGANDO';
    if (!_controlador.camaraLista) return 'CÁMARA';
    if (!_controlador.encoderListo) return 'IA';
    return 'LISTO';
  }

  Widget _construirCuerpo() {
    // Mostrar error
    if (_controlador.mensajeError != null) {
      return _construirPantallaError();
    }

    // Mostrar carga inicial
    if (_controlador.estaInicializando) {
      return _construirPantallaCarga();
    }

    // Pantalla principal optimizada
    return Stack(
      children: [
        _construirVistaImagen(),
        if (_controlador.imagenCapturada != null) _construirOverlayRostro(),
        _construirBotones(),
        if (_controlador.estaProcesando) _construirOverlayProcesando(),
      ],
    );
  }

  Widget _construirPantallaError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _controlador.mensajeError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _controlador.reintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('🔄 Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirPantallaCarga() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            '🚀 Inicializando sistema optimizado...',
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Cargando FaceNet-512 + Detector ML Kit',
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _construirVistaImagen() {
    if (_controlador.imagenCapturada == null) {
      // Preview limpio de cámara
      if (_controlador.camaraLista) {
        final controladorCamara = _controlador.obtenerControladorCamara();
        if (controladorCamara != null) {
          return SizedBox.expand(child: CameraPreview(controladorCamara));
        }
      }
      return const Center(
        child: Text(
          '📱 Preparando cámara...',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      // Imagen capturada
      return SizedBox.expand(
        child: Image.file(
          File(_controlador.imagenCapturada!.path),
          fit: BoxFit.cover,
        ),
      );
    }
  }

  Widget _construirOverlayRostro() {
    final rostro = _controlador.rostroCapturado;
    if (rostro == null || _controlador.dimensionImagen == null) {
      return const SizedBox.shrink();
    }

    final dimensionPantalla = MediaQuery.of(context).size;
    final rectanguloEscalado = ImagenUtils.escalarRectanguloParaPantalla(
      rostro.rectangulo,
      _controlador.dimensionImagen!,
      dimensionPantalla,
    );

    final color = rostro.tieneEmbedding ? Colors.green : Colors.blue;

    return Positioned(
      left: rectanguloEscalado.left,
      top: rectanguloEscalado.top,
      child: Container(
        width: rectanguloEscalado.width,
        height: rectanguloEscalado.height,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: rostro.tieneEmbedding
            ? const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Text('✅', style: TextStyle(fontSize: 20)),
                ),
              )
            : null,
      ),
    );
  }

  Widget _construirBotones() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: _controlador.imagenCapturada == null
          ? _construirBotonCapturar()
          : _construirBotonesPostCaptura(),
    );
  }

  Widget _construirBotonCapturar() {
    final puedeCapturar =
        !_controlador.estaProcesando &&
        _controlador.camaraLista &&
        _controlador.encoderListo;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: puedeCapturar ? _manejarCaptura : null,
        icon: Icon(
          _controlador.estaProcesando
              ? Icons.hourglass_empty
              : Icons.camera_alt,
          size: 28,
        ),
        label: Text(
          _controlador.estaProcesando
              ? "⚡ Procesando..."
              : "📸 Capturar Rostro",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: puedeCapturar
              ? ColoresApp.colorPrimario
              : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _construirBotonesPostCaptura() {
    final puedeEnviar = _controlador.rostroCapturado?.tieneEmbedding == true;

    return Column(
      children: [
        // Botón principal: Seleccionar Alumno
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: puedeEnviar ? _mostrarSelectorAlumno : null,
            icon: const Icon(Icons.person_add, size: 28),
            label: const Text(
              "👤 Seleccionar Alumno",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: puedeEnviar ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Botón secundario: Nueva foto
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _controlador.reiniciarParaNuevaCaptura,
            icon: const Icon(Icons.refresh),
            label: const Text("🔄 Nueva Foto"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirOverlayProcesando() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            SizedBox(height: 16),
            Text(
              '🧠 Procesando con FaceNet-512...',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Generando embedding de 512 dimensiones',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // MÉTODOS DE MANEJO

  Future<void> _manejarCaptura() async {
    await _controlador.capturarYProcesarRostro(context);
  }

  void _mostrarSelectorAlumno() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _construirSelectorAlumno(),
    );
  }

  Widget _construirSelectorAlumno() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_search, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Seleccionar Alumno',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Buscador
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _buscadorController,
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o DNI...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filtrarAlumnos,
            ),
          ),

          // Lista de alumnos
          Expanded(
            child: _alumnosFiltrados.isEmpty
                ? const Center(
                    child: Text(
                      '🔍 Ingresa nombre o DNI para buscar',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    itemCount: _alumnosFiltrados.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final a = _alumnosFiltrados[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            a.nombres.isNotEmpty ? a.nombres[0] : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          '${a.nombres} ${a.apellidoPaterno} ${a.apellidoMaterno}',
                        ),
                        subtitle: Text(
                          '${a.grado} ${a.seccion} - DNI: ${a.dni}',
                        ),
                        onTap: () => _seleccionarAlumno(a),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _filtrarAlumnos(String query) async {
    if (query.isEmpty) {
      setState(() {
        _alumnosFiltrados = [];
      });
      return;
    }

    final resultado = await ApiService.buscarAlumno(query);
    debugPrint(
      '\x1B[31mResultado búsqueda: $resultado\x1B[0m',
    ); // 🔴 Resultado búsqueda
    setState(() {
      _alumnosFiltrados = resultado ?? [];
    });
  }

  Future<void> _seleccionarAlumno(Alumno alumno) async {
    Navigator.pop(context); // Cerrar selector

    // Confirmar envío
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Registro'),
        content: Text('¿Registrar rostro para ${alumno.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final exito = await _controlador.enviarEmbeddingAApi(context, alumno.id);
      if (exito) {
        // Volver al inicio después de éxito
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          _controlador.reiniciarParaNuevaCaptura();
        }
      }
    }
  }
}
