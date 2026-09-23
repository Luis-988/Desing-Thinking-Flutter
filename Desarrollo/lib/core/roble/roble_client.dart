import 'package:roble/roble.dart';

/// Conexión única a Roble para toda la app.
/// Cambia [contractId] por el id del proyecto que aparece en la consola de Roble.
class RobleClient {
  RobleClient._();

  static const String baseUrl = 'https://roble-api.test-openlab.uninorte.edu.co';
  static const String contractId = 'flut_innovation_hub_77a7800a82';

  static const String tablaIniciativas = 'iniciativas';
  static const String tablaPostulaciones = 'postulaciones';

  static final RobleApiDataBase db = RobleApiDataBase(
    config: RobleApiConfig.fromContract(
      baseUrl: baseUrl,
      contractId: contractId,
    ),
  );
}
