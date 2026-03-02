// utils/ui_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utilidades para interfaz de usuario y feedback
class UIUtils {
  /// Muestra un SnackBar con estilo personalizado
  static void mostrarSnackBar(
    BuildContext context,
    String mensaje,
    Color colorFondo, {
    Duration duracion = const Duration(seconds: 2),
    IconData? icono,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icono != null) ...[
              Icon(icono, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: colorFondo,
        duration: duracion,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Muestra un SnackBar de éxito
  static void mostrarExito(BuildContext context, String mensaje) {
    mostrarSnackBar(context, mensaje, Colores.exito, icono: Icons.check_circle);
  }

  /// Muestra un SnackBar de error
  static void mostrarError(BuildContext context, String mensaje) {
    mostrarSnackBar(context, mensaje, Colores.error, icono: Icons.error);
  }

  /// Muestra un SnackBar de advertencia
  static void mostrarAdvertencia(BuildContext context, String mensaje) {
    mostrarSnackBar(
      context,
      mensaje,
      Colores.advertencia,
      icono: Icons.warning,
    );
  }

  /// Muestra un SnackBar informativo
  static void mostrarInfo(BuildContext context, String mensaje) {
    mostrarSnackBar(context, mensaje, Colores.info, icono: Icons.info);
  }

  /// Proporciona feedback háptico según el tipo
  static void darFeedbackHaptico(TipoFeedback tipo) {
    switch (tipo) {
      case TipoFeedback.ligero:
        HapticFeedback.lightImpact();
        break;
      case TipoFeedback.medio:
        HapticFeedback.mediumImpact();
        break;
      case TipoFeedback.fuerte:
        HapticFeedback.heavyImpact();
        break;
      case TipoFeedback.seleccion:
        HapticFeedback.selectionClick();
        break;
    }
  }

  /// Muestra un diálogo de carga con mensaje personalizable
  static void mostrarDialogoCarga(
    BuildContext context,
    String mensaje, {
    String? submensaje,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(mensaje, textAlign: TextAlign.center),
            if (submensaje != null) ...[
              const SizedBox(height: 8),
              Text(
                submensaje,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Cierra el diálogo activo
  static void cerrarDialogo(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  /// Muestra diálogo para ingresar nombre
  static Future<String?> mostrarDialogoNombre(BuildContext context) async {
    final controladorNombre = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎯 Registrar Rostro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nombre de la persona:'),
              const SizedBox(height: 16),
              TextField(
                controller: controladorNombre,
                decoration: const InputDecoration(
                  hintText: 'Nombre completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final nombre = controladorNombre.text.trim();
                if (nombre.isNotEmpty) {
                  Navigator.of(context).pop(nombre);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

/// Clase con colores predefinidos para diferentes estados
class Colores {
  static const Color exito = Colors.green;
  static const Color error = Colors.red;
  static const Color advertencia = Colors.orange;
  static const Color info = Colors.blue;
  static const Color procesando = Colors.grey;
  static const Color rostroDetectado = Colors.green;
  static const Color sinRostro = Colors.red;
}

/// Tipos de feedback háptico disponibles
enum TipoFeedback { ligero, medio, fuerte, seleccion }
