import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracionServidorPage extends StatefulWidget {
  const ConfiguracionServidorPage({super.key});

  @override
  State<ConfiguracionServidorPage> createState() =>
      _ConfiguracionServidorPageState();
}

class _ConfiguracionServidorPageState extends State<ConfiguracionServidorPage> {
  final TextEditingController _apiController = TextEditingController();
  final TextEditingController _faissController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarValoresGuardados();
  }

  Future<void> _cargarValoresGuardados() async {
    final prefs = await SharedPreferences.getInstance();
    _apiController.text =
        prefs.getString('server_url') ?? 'http://localhost:9000/api';
    _faissController.text =
        prefs.getString('server_url_faiss') ?? 'http://localhost:8000';
    setState(() {});
  }

  Future<void> _guardarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', _apiController.text.trim());
    await prefs.setString('server_url_faiss', _faissController.text.trim());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada correctamente')),
    );
  }

  @override
  void dispose() {
    _apiController.dispose();
    _faissController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de Servidor')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'URL del API Principal:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _apiController,
              decoration: const InputDecoration(
                hintText: 'http://192.168.x.x:9000/api',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'URL del Servidor FAISS:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _faissController,
              decoration: const InputDecoration(
                hintText: 'http://192.168.x.x:8000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: _guardarConfiguracion,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Configuración'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
