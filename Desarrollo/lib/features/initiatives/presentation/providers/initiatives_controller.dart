import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/app_exception.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../domain/entities/initiative.dart';
import '../../domain/entities/initiative_application.dart';
import '../../domain/services/initiative_insights.dart';
import '../../domain/usecases/create_initiative.dart';
import '../../domain/usecases/delete_initiative.dart';
import '../../domain/usecases/get_applications.dart';
import '../../domain/usecases/get_initiatives.dart';
import '../../domain/usecases/save_initiative_views.dart';
import '../../domain/usecases/submit_application.dart';
import '../../domain/usecases/update_application_status.dart';
import '../../domain/usecases/update_initiative.dart';

enum InitiativeSort { recent, popular, availableSlots }

/// Estado de iniciativas y postulaciones. Las pantallas lo observan con
/// Provider y nunca hablan directamente con la capa de datos.
class InitiativesController extends ChangeNotifier {
  static const allFilter = 'Todos';

  final GetInitiatives _getInitiatives;
  final CreateInitiative _createInitiative;
  final UpdateInitiative _updateInitiative;
  final DeleteInitiative _deleteInitiative;
  final SaveInitiativeViews _saveViews;
  final GetApplications _getApplications;
  final SubmitApplication _submitApplication;
  final UpdateApplicationStatus _updateApplicationStatus;

  InitiativesController({
    required GetInitiatives getInitiatives,
    required CreateInitiative createInitiative,
    required UpdateInitiative updateInitiative,
    required DeleteInitiative deleteInitiative,
    required SaveInitiativeViews saveViews,
    required GetApplications getApplications,
    required SubmitApplication submitApplication,
    required UpdateApplicationStatus updateApplicationStatus,
  }) : _getInitiatives = getInitiatives,
       _createInitiative = createInitiative,
       _updateInitiative = updateInitiative,
       _deleteInitiative = deleteInitiative,
       _saveViews = saveViews,
       _getApplications = getApplications,
       _submitApplication = submitApplication,
       _updateApplicationStatus = updateApplicationStatus;

  List<Initiative> _initiatives = [];
  List<InitiativeApplication> _applications = [];
  final Set<String> _savedIds = {};
  String _filter = allFilter;
  String _query = '';
  InitiativeSort _sort = InitiativeSort.recent;
  bool _isLoading = true;
  String? _error;
  SessionStatus? _lastSessionStatus;

  // ---------------------------------------------------------------- lectura

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filter => _filter;
  String get query => _query;
  InitiativeSort get sort => _sort;
  List<Initiative> get initiatives => List.unmodifiable(_initiatives);
  List<InitiativeApplication> get applications =>
      List.unmodifiable(_applications);

  List<Initiative> get activeInitiatives =>
      _initiatives.where((item) => item.isActive).toList();

  List<Initiative> get popularInitiatives =>
      activeInitiatives.where((item) => item.isPopular).toList();

  /// Selección breve para Inicio basada en popularidad, actividad y plazas.
  List<Initiative> get recommendedInitiatives {
    return InitiativeInsights.recommended(_initiatives);
  }

  /// Las más recientes primero (Roble las devuelve en orden de creación).
  List<Initiative> get recentInitiatives =>
      activeInitiatives.reversed.take(3).toList();

  List<Initiative> get myInitiatives =>
      _initiatives.where((item) => item.isMine).toList();

  List<Initiative> get savedInitiatives =>
      _initiatives.where((item) => _savedIds.contains(item.id)).toList();

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

  int get openSlotsCount =>
      InitiativeInsights.openSlotsCount(activeInitiatives);

  List<RoleDemand> get roleDemand =>
      InitiativeInsights.roleDemand(activeInitiatives);

  /// Categorías disponibles para intereses y tipos de proyecto.
  List<String> get categoryOptions {
    final options = <String>{};
    for (final initiative in _initiatives) {
      options.addAll(initiative.categories);
    }
    return _sortedFilterOptions(options);
  }

  /// Roles disponibles en las iniciativas activas.
  List<String> get roleOptions {
    final options = <String>{};
    for (final initiative in _initiatives) {
      options.addAll(initiative.roles.map((role) => role.name));
    }
    return _sortedFilterOptions(options);
  }

  /// Filtros disponibles combinados, conservado para accesos existentes.
  List<String> get filterOptions => [
    allFilter,
    ...{...categoryOptions, ...roleOptions},
  ];

  List<String> _sortedFilterOptions(Set<String> options) {
    return options.where((item) => item.isNotEmpty).toList()..sort();
  }

  List<Initiative> get filteredInitiatives {
    final text = _query.trim().toLowerCase();
    final filtered = activeInitiatives.where((initiative) {
      final matchesFilter =
          _filter == allFilter ||
          initiative.categories.contains(_filter) ||
          initiative.roles.any((role) => role.name == _filter);
      if (!matchesFilter) return false;
      if (text.isEmpty) return true;
      return initiative.title.toLowerCase().contains(text) ||
          initiative.description.toLowerCase().contains(text) ||
          initiative.leader.toLowerCase().contains(text) ||
          initiative.categories.any((c) => c.toLowerCase().contains(text)) ||
          initiative.roles.any((r) => r.name.toLowerCase().contains(text));
    }).toList();
    filtered.sort(_compareBySort);
    return filtered;
  }

  int _compareBySort(Initiative a, Initiative b) {
    switch (_sort) {
      case InitiativeSort.popular:
        return _popularityScore(b).compareTo(_popularityScore(a));
      case InitiativeSort.availableSlots:
        return b.openSlots.compareTo(a.openSlots);
      case InitiativeSort.recent:
        return _initiatives.indexOf(b).compareTo(_initiatives.indexOf(a));
    }
  }

  int _popularityScore(Initiative initiative) =>
      (initiative.isPopular ? 1000000 : 0) + initiative.views;

  Initiative? initiativeById(String id) {
    for (final initiative in _initiatives) {
      if (initiative.id == id) return initiative;
    }
    return null;
  }

  bool isSaved(String initiativeId) => _savedIds.contains(initiativeId);

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
      _savedIds.clear();
    }
    // Se difiere para no notificar mientras el árbol de widgets se construye.
    scheduleMicrotask(load);
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _initiatives = await _getInitiatives();
      _applications = await _getApplications();
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
    _filter = value;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setSort(InitiativeSort value) {
    if (_sort == value) return;
    _sort = value;
    notifyListeners();
  }

  void clearFilters() {
    _filter = allFilter;
    _query = '';
    notifyListeners();
  }

  // --------------------------------------------------------------- guardados

  /// Por ahora los guardados viven en memoria; la fase de Roble los
  /// persistirá en una tabla propia sin cambiar esta interfaz.
  void toggleSaved(String initiativeId) {
    if (!_savedIds.remove(initiativeId)) _savedIds.add(initiativeId);
    notifyListeners();
  }

  // ------------------------------------------------------------ iniciativas

  Future<void> create(Initiative initiative) async {
    final saved = await _createInitiative(initiative);
    _initiatives = [..._initiatives, saved];
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
    _initiatives = _initiatives.where((i) => i.id != initiative.id).toList();
    _savedIds.remove(initiative.id);
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
    } catch (_) {
      // Las visitas son secundarias: si falla el guardado quedan en local.
    }
  }

  // ----------------------------------------------------------- postulaciones

  Future<InitiativeApplication> apply(InitiativeApplication application) async {
    final initiative = initiativeById(application.initiativeId);
    if (initiative != null && initiative.isMine) {
      throw const AppException('No puedes postularte a tu propia iniciativa.');
    }
    if (myApplicationFor(application.initiativeId, application.roleName) !=
        null) {
      throw const AppException('Ya te postulaste a esta vacante.');
    }
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
        final updatedInitiative = _consumeAcceptedRoleSlot(
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

  Initiative _consumeAcceptedRoleSlot(Initiative initiative, String roleName) {
    final updatedRoles = initiative.roles.map((role) {
      if (role.name != roleName) return role;
      final nextSlots = role.slots > 0 ? role.slots - 1 : 0;
      return InitiativeRole(
        name: role.name,
        description: role.description,
        slots: nextSlots,
        skills: role.skills,
      );
    }).toList();

    return initiative.copyWith(roles: updatedRoles);
  }

  void _replace(Initiative updated) {
    _initiatives = [
      for (final item in _initiatives) item.id == updated.id ? updated : item,
    ];
    notifyListeners();
  }
}
