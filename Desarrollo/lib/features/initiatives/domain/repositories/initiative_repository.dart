import '../entities/initiative.dart';
import '../entities/initiative_application.dart';

/// Contrato del dominio. La capa data lo implementa (hoy con Roble).
abstract class InitiativeRepository {
  Future<List<Initiative>> getInitiatives();
  Future<Initiative> createInitiative(Initiative initiative);
  Future<void> updateInitiative(Initiative initiative);
  Future<void> deleteInitiative(Initiative initiative);
  Future<void> saveViews(Initiative initiative);

  Future<List<InitiativeApplication>> getApplications();
  Future<InitiativeApplication> submitApplication(
    InitiativeApplication application,
  );
  Future<void> updateApplicationStatus(
    InitiativeApplication application,
    ApplicationStatus status,
  );
}
