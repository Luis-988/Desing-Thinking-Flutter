/// Error de negocio o de red con un mensaje listo para mostrarse al usuario.
///
/// La capa `data` convierte las excepciones de Roble en [AppException], de
/// modo que `domain` y `presentation` nunca dependen del paquete `roble`.
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

/// Devuelve un texto apto para el usuario a partir de cualquier error.
String messageOf(Object error) {
  if (error is AppException) return error.message;
  return 'Ocurrió un error inesperado. Inténtalo de nuevo.';
}
