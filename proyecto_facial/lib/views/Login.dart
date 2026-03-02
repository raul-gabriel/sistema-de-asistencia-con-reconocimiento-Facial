import 'package:flutter/material.dart';
import 'package:proyecto_facial/config/colores_app.dart';
import 'package:proyecto_facial/model/SesionUsuario.dart';
import 'package:proyecto_facial/services/ApiService.dart';
import 'package:proyecto_facial/views/HomePage.dart';
import 'package:proyecto_facial/widget/ServidorDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Extensión para mostrar SnackBar fácilmente
extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
      ),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serverUrlController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _serverUrl = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadServerUrl();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _serverUrlController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverUrl = prefs.getString('server_url') ?? '';
      _serverUrlController.text = _serverUrl;
    });
  }

  // Método corregido para guardar la URL en SharedPreferences
  Future<void> _saveServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url);
    setState(() {
      _serverUrl = url;
      _serverUrlController.text = url;
    });
    debugPrint('🔗 URL guardada en SharedPreferences: $url');
  }

  // Método corregido para mostrar el diálogo
  void mostrarConfigurarServidorDialog(
    BuildContext context,
    String initialUrl,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ServidorDialog(
          initialUrl: initialUrl,
          onSave: (String nuevaUrl) async {
            // ✅ AQUÍ ESTÁ LA CORRECCIÓN: ahora sí guardamos en SharedPreferences
            await _saveServerUrl(nuevaUrl);

            // Mostrar mensaje de confirmación
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'URL del servidor guardada correctamente',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: ColoresApp.colorExito,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }

  void IniciarSesion() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      context.showSnackBar(
        'Por favor, ingresa tu email y contraseña.',
        isError: true,
      );
      return;
    }

    if (_serverUrl.isEmpty) {
      context.showSnackBar(
        'Por favor, configura la URL del servidor primero.',
        isError: true,
      );
      mostrarConfigurarServidorDialog(context, _serverUrl);
      return;
    }

    setState(() {
      _isLoading = true; // 🔥 Mostrar Loading
    });

    // Iniciar sesión (espera respuesta)
    final result = await ApiService.iniciarSesion(
      username: email,
      password: password,
    );

    setState(() {
      _isLoading = false; // 🔥 Ocultar Loading al terminar
    });

    if (result['success']) {
      final user = result['user'];

      // Guardar en sesión temporal
      SesionUsuario().iniciarSesion(user);

      context.showSnackBar(
        'Bienvenido ${user['nombres']} ${user['apellidos']}',
      );

      // Redirigir a HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      context.showSnackBar(
        result['message'] ?? 'Error desconocido',
        isError: true,
      );
    }
  }

  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [ColoresApp.colorPrimario, ColoresApp.colorPrimarioClaro],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: Column(
                children: [
                  // Sección superior con diseño decorativo
                  Container(
                    height:
                        MediaQuery.of(context).size.height *
                        0.20, // Reducido de 0.35 a 0.20
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // Círculo grande más pequeño
                        Positioned(
                          top: 20, // antes 40
                          right: -30, // antes -50
                          child: Container(
                            width: 100, // antes 150
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        // Círculo pequeño más pequeño
                        Positioned(
                          top: 50, // antes 100
                          left: -20, // antes -30
                          child: Container(
                            width: 60, // antes 100
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),
                        // Círculo acento más pequeño
                        Positioned(
                          bottom: 10, // antes 20
                          right: 20, // antes 30
                          child: Container(
                            width: 50, // antes 80
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColoresApp.colorAcento.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sección inferior con formulario
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ColoresApp.colorTarjeta,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título
                          Text(
                            'Bienvenido a RostroID',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: ColoresApp.textoPrimario,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Inicia sesión en tu cuenta',
                            style: TextStyle(
                              fontSize: 16,
                              color: ColoresApp.textoPrimario,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Campo Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              fontSize: 16,
                              color: ColoresApp.textoPrimario,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'usuario@ejemplo.com',
                              labelStyle: TextStyle(
                                color: ColoresApp.textoPrimario,
                                fontWeight: FontWeight.w500,
                              ),
                              hintStyle: TextStyle(
                                color: ColoresApp.textoPrimario.withOpacity(
                                  0.6,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.email_rounded,
                                color: ColoresApp.textoPrimario,
                                size: 22,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: ColoresApp.colorBorde,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: ColoresApp.colorBorde,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: ColoresApp.colorBorde,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: ColoresApp.colorFondo,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Campo Contraseña
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: TextStyle(
                              fontSize: 16,
                              color: ColoresApp.colorPrimario,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              hintText: 'Tu contraseña segura',
                              labelStyle: TextStyle(
                                color: ColoresApp.textoPrimario,
                                fontWeight: FontWeight.w500,
                              ),
                              hintStyle: TextStyle(
                                color: ColoresApp.textoPrimario.withOpacity(
                                  0.6,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: ColoresApp.colorPrimario,
                                size: 22,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: ColoresApp.colorPrimario,
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: ColoresApp.colorBorde,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: ColoresApp.colorBorde,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: ColoresApp.colorBorde,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: ColoresApp.colorFondo,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Remember Me y Forgot Password
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isChecked = !isChecked;
                                  });
                                },
                                child: Icon(
                                  isChecked
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked,
                                  color: isChecked ? Colors.green : Colors.grey,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Recuérdame',
                                style: TextStyle(
                                  color: ColoresApp.textoPrimario,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () {
                                  context.showSnackBar(
                                    'Funcionalidad de recuperación en desarrollo',
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  '¿Has olvidado tu contraseña?',
                                  style: TextStyle(
                                    color: ColoresApp.colorPrimario,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Indicador de servidor
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _serverUrl.isEmpty
                                  ? ColoresApp.colorAdvertencia.withOpacity(0.1)
                                  : ColoresApp.colorExito.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _serverUrl.isEmpty
                                    ? ColoresApp.colorAdvertencia.withOpacity(
                                        0.3,
                                      )
                                    : ColoresApp.colorExito.withOpacity(0.3),
                                width: 1,
                              ),
                            ),

                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _serverUrl.isEmpty
                                        ? ColoresApp.colorAdvertencia
                                              .withOpacity(0.2)
                                        : ColoresApp.colorExito.withOpacity(
                                            0.2,
                                          ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _serverUrl.isEmpty
                                        ? Icons.warning_rounded
                                        : Icons.check_circle_rounded,
                                    color: _serverUrl.isEmpty
                                        ? ColoresApp.colorAdvertencia
                                        : ColoresApp.colorExito,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _serverUrl.isEmpty
                                            ? 'Servidor no configurado'
                                            : 'Servidor configurado',
                                        style: TextStyle(
                                          color: _serverUrl.isEmpty
                                              ? ColoresApp.colorAdvertencia
                                              : ColoresApp.colorExito,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (_serverUrl.isNotEmpty)
                                        Text(
                                          _serverUrl.length > 25
                                              ? '${_serverUrl.substring(0, 25)}...'
                                              : _serverUrl,
                                          style: TextStyle(
                                            color: ColoresApp.textoPrimario,
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      mostrarConfigurarServidorDialog(
                                        context,
                                        _serverUrl,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.settings_rounded,
                                      color: ColoresApp.textoPrimario,
                                      size: 18,
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                    padding: EdgeInsets.all(8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Botón Login
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : IniciarSesion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColoresApp.colorPrimario,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: ColoresApp
                                    .textoPrimario
                                    .withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                shadowColor: ColoresApp.colorPrimario
                                    .withOpacity(0.3),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Don't have account
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: "¿No tienes cuenta? ",
                                style: TextStyle(
                                  color: ColoresApp.textoPrimario,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Solicitar Acceso",
                                    style: TextStyle(
                                      color: ColoresApp.colorPrimario,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: ColoresApp.colorPrimario,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
