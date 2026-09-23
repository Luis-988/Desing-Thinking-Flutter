import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/auth_result.dart';

class AuthPage extends StatefulWidget {
  final bool startInRegisterMode;
  final Future<AuthResult> Function({
    required bool isRegistering,
    required String name,
    required String email,
    required String program,
    required String semester,
    required String password,
  }) onSubmit;

  const AuthPage({
    super.key,
    required this.startInRegisterMode,
    required this.onSubmit,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late bool isRegistering = widget.startInRegisterMode;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final programController = TextEditingController();
  final semesterController = TextEditingController();
  final passwordController = TextEditingController();
  bool isSubmitting = false;
  String? errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    programController.dispose();
    semesterController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
    if (email.isEmpty || !email.contains('@')) {
      setState(() => errorMessage = 'Escribe un correo electrónico válido.');
      return;
    }
    if (password.length < 6) {
      setState(() => errorMessage = 'La contraseña debe tener al menos 6 caracteres.');
      return;
    }
    if (isRegistering && nameController.text.trim().isEmpty) {
      setState(() => errorMessage = 'Escribe tu nombre completo.');
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });
    final result = await widget.onSubmit(
      isRegistering: isRegistering,
      name: nameController.text.trim(),
      email: email,
      program: programController.text.trim(),
      semester: semesterController.text.trim(),
      password: password,
    );
    if (!mounted) return;
    setState(() {
      isSubmitting = false;
      errorMessage = result.error;
    });
    if (result.user != null) Navigator.pop(context, result.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isRegistering ? 'Crear cuenta' : 'Iniciar sesión')),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Text(
              isRegistering ? 'Crea tu perfil de innovación' : 'Bienvenido de nuevo',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isRegistering
                  ? 'Completa tus datos para conectar con otros estudiantes.'
                  : 'Ingresa tus datos para continuar.',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            if (isRegistering) ...[
              _input(nameController, 'Nombre completo', Icons.person_outline),
              const SizedBox(height: 12),
            ],
            _input(emailController, 'Correo electrónico', Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            if (isRegistering) ...[
              _input(programController, 'Programa académico', Icons.school_outlined),
              const SizedBox(height: 12),
              _input(semesterController, 'Semestre', Icons.calendar_today_outlined),
              const SizedBox(height: 12),
            ],
            _input(passwordController, 'Contraseña', Icons.lock_outline, obscureText: true),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(errorMessage!, style: const TextStyle(color: Color(0xFFB42318))),
            ],
            const SizedBox(height: 22),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(backgroundColor: AppTheme.navy),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isRegistering ? 'Crear cuenta' : 'Iniciar sesión'),
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () => setState(() {
                        isRegistering = !isRegistering;
                        errorMessage = null;
                      }),
              child: Text(
                isRegistering
                    ? 'Ya tengo una cuenta'
                    : '¿Aún no tienes cuenta? Crear una',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
