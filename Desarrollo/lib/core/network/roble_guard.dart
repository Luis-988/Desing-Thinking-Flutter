import 'package:roble/roble.dart';

import '../error/app_exception.dart';

/// Ejecuta una llamada a Roble y traduce sus errores a [AppException].
///
/// Roble es un servicio en evolución: centralizar aquí la traducción permite
/// ajustar los mensajes (o el contrato) en un solo lugar.
Future<T> guardRoble<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on AppException {
    rethrow;
  } on RobleApiNetworkException {
    throw const AppException(
      'Sin conexión con Roble. Revisa tu internet e inténtalo de nuevo.',
    );
  } on RobleApiHttpException catch (e) {
    if (e.statusCode == 401) {
      throw const AppException('Tu sesión expiró. Inicia sesión otra vez.');
    }
    if (e.statusCode == 403) {
      throw const AppException('No tienes permiso para hacer esta acción.');
    }
    throw AppException('Roble respondió con un error (${e.statusCode}).');
  } on RobleApiException catch (e) {
    throw AppException('Error con Roble: ${e.message}');
  }
}
