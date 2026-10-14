import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/session_controller.dart';

/// Inicio de sesión y registro. Al terminar con éxito cierra la pantalla.
class AuthPage extends StatefulWidget {
  final bool startInRegisterMode;

  const AuthPage({super.key, this.startInRegisterMode = false});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late bool _isRegistering = widget.startInRegisterMode;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _programController = TextEditingController();
  final _semesterController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _hidePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _programController.dispose();
    _semesterController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validate(String email, String password) {
    if (email.isEmpty || !email.contains('@')) {
      return 'Escribe un correo electrónico válido.';
    }
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (_isRegistering && _nameController.text.trim().isEmpty) {
      return 'Escribe tu nombre completo.';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final validationError = _validate(email, password);
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final session = context.read<SessionController>();
    final result = _isRegistering
        ? await session.register(
            name: _nameController.text.trim(),
            email: email,
            program: _programController.text.trim(),
            semester: _semesterController.text.trim(),
            password: password,
          )
        : await session.login(email: email, password: password);

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _errorMessage = result.error;
    });
    if (result.user != null) Navigator.of(context).pop();
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _AuthHeader(isRegistering: _isRegistering),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                Text(
                  _isRegistering
                      ? 'Crea tu perfil de innovación'
                      : 'Bienvenido de nuevo',
                  style: AppText.screenTitle,
                ),
                const SizedBox(height: 6),
                Text(
                  _isRegistering
                      ? 'Completa tus datos para conectar con otros estudiantes.'
                      : 'Ingresa tus datos para continuar.',
                  style: AppText.body,
                ),
                const SizedBox(height: 22),
                if (_isRegistering) ...[
                  _input(
                    _nameController,
                    'Nombre completo',
                    Icons.person_outline,
                    action: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                ],
                _input(
                  _emailController,
                  'Correo electrónico',
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                if (_isRegistering) ...[
                  _input(
                    _programController,
                    'Programa académico',
                    Icons.school_outlined,
                    action: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  _input(
                    _semesterController,
                    'Semestre',
                    Icons.calendar_today_outlined,
                    action: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                ],
                _input(
                  _passwordController,
                  'Contraseña',
                  Icons.lock_outline,
                  obscureText: _hidePassword,
                  suffix: IconButton(
                    tooltip: _hidePassword
                        ? 'Mostrar contraseña'
                        : 'Ocultar contraseña',
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  _ErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isRegistering ? 'Crear cuenta' : 'Iniciar sesión'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _isSubmitting ? null : _toggleMode,
                  child: Text(
                    _isRegistering
                        ? 'Ya tengo una cuenta'
                        : '¿Aún no tienes cuenta? Crear una',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? action,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: action,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  final bool isRegistering;

  const _AuthHeader({required this.isRegistering});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Volver',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isRegistering
                            ? Icons.person_add_alt_1_outlined
                            : Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'UNIVERSIDAD DEL NORTE',
                            style: TextStyle(
                              color: Color(0xFFD3DEF2),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isRegistering ? 'Crear cuenta' : 'Iniciar sesión',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.dangerFg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.dangerFg, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
