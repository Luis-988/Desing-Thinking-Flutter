import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ProfileUser {
  final String name;
  final String email;
  final String program;
  final String semester;
  final String password;

  const ProfileUser({
    required this.name,
    required this.email,
    required this.program,
    required this.semester,
    required this.password,
  });
}

class AuthResult {
  final ProfileUser? user;
  final String? error;

  const AuthResult.success(this.user) : error = null;
  const AuthResult.failure(this.error) : user = null;
}

class ProfilePage extends StatelessWidget {
  final ProfileUser? user;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.user,
    required this.onLogin,
    required this.onRegister,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = user;
    if (currentUser == null) {
      return _GuestProfile(onLogin: onLogin, onRegister: onRegister);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      children: [
        const Text(
          'Mi perfil',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 22),
        Center(
          child: CircleAvatar(
            radius: 38,
            backgroundColor: const Color(0xFFE4ECF8),
            child: Text(
              _initials(currentUser.name),
              style: const TextStyle(
                color: AppTheme.navy,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            currentUser.name,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            currentUser.email,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Información académica',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _InfoTile(
          icon: Icons.school_outlined,
          label: 'Programa académico',
          value: currentUser.program,
        ),
        _InfoTile(
          icon: Icons.calendar_today_outlined,
          label: 'Semestre',
          value: currentUser.semester,
        ),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFB42318),
            side: const BorderSide(color: Color(0xFFB42318)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _GuestProfile extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const _GuestProfile({required this.onLogin, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 58, color: AppTheme.navy),
            const SizedBox(height: 16),
            const Text(
              'Tu perfil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Inicia sesión para postularte a iniciativas y gestionar tus proyectos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onLogin,
                icon: const Icon(Icons.login),
                label: const Text('Iniciar sesión'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.navy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRegister,
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Crear cuenta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.navy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.navy),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

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
