import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/app_exception.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../domain/entities/initiative.dart';
import '../../domain/entities/initiative_application.dart';
import '../../domain/services/initiative_insights.dart';
import '../../domain/services/initiative_policy.dart';
import '../../domain/usecases/create_initiative.dart';
import '../../domain/usecases/delete_initiative.dart';
import '../../domain/usecases/get_applications.dart';
import '../../domain/usecases/get_initiatives.dart';
import '../../domain/usecases/save_initiative_views.dart';
import '../../domain/usecases/submit_application.dart';
import '../../domain/usecases/update_application_status.dart';
import '../../domain/usecases/update_initiative.dart';
import '../../domain/repositories/saved_initiative_repository.dart';
import 'initiative_catalog_state.dart';

export 'initiative_catalog_state.dart' show InitiativeSort;

/// Estado de iniciativas y postulaciones. Las pantallas lo observan con
/// Provider y nunca hablan directamente con la capa de datos.
class InitiativesController extends ChangeNotifier {
  static const allFilter = InitiativeCatalogState.allFilter;

  final GetInitiatives _getInitiatives;
  final CreateInitiative _createInitiative;
  final UpdateInitiative _updateInitiative;
  final DeleteInitiative _deleteInitiative;
  final SaveInitiativeViews _saveViews;
  final GetApplications _getApplications;
  final SubmitApplication _submitApplication;
  final UpdateApplicationStatus _updateApplicationStatus;
  final SavedInitiativeRepository? _savedRepository;

  InitiativesController({
    required GetInitiatives getInitiatives,
    required CreateInitiative createInitiative,
    required UpdateInitiative updateInitiative,
    required DeleteInitiative deleteInitiative,
    required SaveInitiativeViews saveViews,
    required GetApplications getApplications,
    required SubmitApplication submitApplication,
    required UpdateApplicationStatus updateApplicationStatus,
    SavedInitiativeRepository? savedInitiativeRepository,
  }) : _getInitiatives = getInitiatives,
       _createInitiative = createInitiative,
       _updateInitiative = updateInitiative,
       _deleteInitiative = deleteInitiative,
       _saveViews = saveViews,
       _getApplications = getApplications,
       _submitApplication = submitApplication,
       _updateApplicationStatus = updateApplicationStatus,
       _savedRepository = savedInitiativeRepository;

  final InitiativeCatalogState _catalog = InitiativeCatalogState();
  List<InitiativeApplication> _applications = [];
  bool _isLoading = true;
  String? _error;
  SessionStatus? _lastSessionStatus;

  // ---------------------------------------------------------------- lectura

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filter => _catalog.filter;
  String get query => _catalog.query;
  InitiativeSort get sort => _catalog.sort;
  List<Initiative> get initiatives => _catalog.initiatives;
  List<InitiativeApplication> get applications =>
      List.unmodifiable(_applications);

  List<Initiative> get activeInitiatives => _catalog.activeInitiatives;
  List<Initiative> get availableInitiatives => _catalog.availableInitiatives;
  List<Initiative> get popularInitiatives => _catalog.popularInitiatives;
  List<Initiative> get recommendedInitiatives =>
      _catalog.recommendedInitiatives;
  List<Initiative> get recentInitiatives => _catalog.recentInitiatives;
  List<Initiative> get myInitiatives => _catalog.myInitiatives;
  List<Initiative> get savedInitiatives => _catalog.savedInitiatives;

  List<InitiativeApplication> get myApplications =>
      _applications.where((item) => item.isMine).toList();

  /// Postulaciones a iniciativas del usuario, hechas por otras personas.
  List<InitiativeApplication> get receivedApplications {
    final myIds = myInitiatives.map((item) => item.id).toSet();
    return _applications
        .where((item) => myIds.contains(item.initiativeId) && !item.isMine)
        .toList();
  }

  List<InitiativeApplication> acceptedMembersFor(String initiativeId) =>
      _applications
          .where(
            (item) =>
                item.initiativeId == initiativeId &&
                item.status == ApplicationStatus.accepted,
          )
          .toList();

  int get pendingReceivedCount => receivedApplications
      .where((item) => item.status == ApplicationStatus.pending)
      .length;

  int get openSlotsCount => _catalog.openSlotsCount;
  List<RoleDemand> get roleDemand => _catalog.roleDemand;
  List<String> get categoryOptions => _catalog.categoryOptions;
  List<String> get roleOptions => _catalog.roleOptions;
  List<String> get filterOptions => _catalog.filterOptions;
  List<Initiative> get filteredInitiatives => _catalog.filteredInitiatives;

  Initiative? initiativeById(String id) {
    return _catalog.initiativeById(id);
  }

  bool isSaved(String initiativeId) => _catalog.isSaved(initiativeId);

  /// Mi postulación a un rol concreto, si existe.
  InitiativeApplication? myApplicationFor(String initiativeId, String role) {
    for (final application in _applications) {
      if (application.isMine &&
          application.initiativeId == initiativeId &&
          application.roleName == role) {
        return application;
      }
    }
    return null;
  }

  // ----------------------------------------------------------------- carga

  /// Recarga datos cuando cambia la sesión (entrar o salir).
  void syncSession(SessionStatus status) {
    if (status == SessionStatus.unknown || status == _lastSessionStatus) return;
    final isFirstLoad = _lastSessionStatus == null;
    _lastSessionStatus = status;
    if (!isFirstLoad && status == SessionStatus.guest) {
      _catalog.clearSaved();
    }
    // Se difiere para no notificar mientras el árbol de widgets se construye.
    scheduleMicrotask(load);
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _catalog.setInitiatives(await _getInitiatives());
      _applications = await _getApplications();
      final savedRepository = _savedRepository;
      if (savedRepository != null) {
        try {
          _catalog.setSaved(await savedRepository.getSavedInitiativeIds());
        } catch (error, stackTrace) {
          debugPrint('No se pudieron cargar los guardados: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      }
    } on AppException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'No se pudieron cargar las iniciativas.';
    }
    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------- filtros

  void setFilter(String value) {
    _catalog.setFilter(value);
    notifyListeners();
  }

  void setQuery(String value) {
    _catalog.setQuery(value);
    notifyListeners();
  }

  void setSort(InitiativeSort value) {
    if (_catalog.sort == value) return;
    _catalog.setSort(value);
    notifyListeners();
  }

  void clearFilters() {
    _catalog.clearFilters();
    notifyListeners();
  }

  // --------------------------------------------------------------- guardados

  /// Persiste el cambio cuando existe un repositorio remoto configurado.
  Future<void> toggleSaved(String initiativeId) async {
    final wasSaved = _catalog.isSaved(initiativeId);
    _catalog.toggleSaved(initiativeId);
    notifyListeners();

    final savedRepository = _savedRepository;
    if (savedRepository == null) return;
    try {
      if (wasSaved) {
        await savedRepository.removeInitiative(initiativeId);
      } else {
        await savedRepository.saveInitiative(initiativeId);
      }
    } catch (error, stackTrace) {
      _catalog.toggleSaved(initiativeId);
      notifyListeners();
      debugPrint('No se pudo persistir el guardado de $initiativeId: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ------------------------------------------------------------ iniciativas

  Future<void> create(Initiative initiative) async {
    final saved = await _createInitiative(initiative);
    _catalog.add(saved);
    notifyListeners();
  }

  Future<void> update(Initiative initiative) async {
    await _updateInitiative(initiative);
    _replace(initiative);
  }

  Future<void> togglePopular(Initiative initiative) async {
    final updated = initiative.copyWith(
      isPopularManually: !initiative.isPopularManually,
    );
    await _updateInitiative(updated);
    _replace(updated);
  }

  Future<void> delete(Initiative initiative) async {
    await _deleteInitiative(initiative);
    _catalog.remove(initiative);
    notifyListeners();
  }

  /// Suma una visita (salvo la del propio líder) y la guarda sin bloquear.
  Future<void> registerView(String initiativeId) async {
    final current = initiativeById(initiativeId);
    if (current == null || current.isMine) return;
    final updated = current.copyWith(views: current.views + 1);
    _replace(updated);
    try {
      await _saveViews(updated);
    } catch (error, stackTrace) {
      // Las visitas son secundarias: si falla el guardado quedan en local.
      debugPrint('No se pudieron registrar las visitas: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ----------------------------------------------------------- postulaciones

  Future<InitiativeApplication> apply(InitiativeApplication application) async {
    final initiative = initiativeById(application.initiativeId);
    InitiativePolicy.requireCanApply(
      initiative: initiative,
      alreadyApplied:
          myApplicationFor(application.initiativeId, application.roleName) !=
          null,
    );
    final saved = await _submitApplication(application);
    _applications = [..._applications, saved];
    notifyListeners();
    return saved;
  }

  Future<void> setApplicationStatus(
    InitiativeApplication application,
    ApplicationStatus status,
  ) async {
    final wasAlreadyAccepted =
        application.status == ApplicationStatus.accepted ||
        _applications.any(
          (item) =>
              item.id == application.id &&
              item.status == ApplicationStatus.accepted,
        );

    await _updateApplicationStatus(application, status);
    _applications = [
      for (final item in _applications)
        item.id == application.id ? item.copyWith(status: status) : item,
    ];

    if (status == ApplicationStatus.accepted && !wasAlreadyAccepted) {
      final initiative = initiativeById(application.initiativeId);
      if (initiative != null) {
        final updatedInitiative = InitiativePolicy.consumeAcceptedRoleSlot(
          initiative,
          application.roleName,
        );
        await _updateInitiative(updatedInitiative);
        _replace(updatedInitiative);
      }
    }

    notifyListeners();
  }

  // --------------------------------------------------------------- internos

  void _replace(Initiative updated) {
    _catalog.replace(updated);
    notifyListeners();
  }
}
