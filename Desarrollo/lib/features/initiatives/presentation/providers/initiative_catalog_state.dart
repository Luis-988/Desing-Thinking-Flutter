import '../../domain/entities/initiative.dart';
import '../../domain/services/initiative_insights.dart';

enum InitiativeSort { recent, popular, availableSlots }

class InitiativeCatalogState {
  static const allFilter = 'Todos';

  List<Initiative> _initiatives = [];
  final Set<String> _savedIds = {};
  String _filter = allFilter;
  String _query = '';
  InitiativeSort _sort = InitiativeSort.recent;

  List<Initiative> get initiatives => List.unmodifiable(_initiatives);
  String get filter => _filter;
  String get query => _query;
  InitiativeSort get sort => _sort;

  List<Initiative> get activeInitiatives =>
      _initiatives.where((item) => item.isActive).toList();

  List<Initiative> get availableInitiatives =>
      activeInitiatives.where((item) => item.openSlots > 0).toList();

  List<Initiative> get popularInitiatives =>
      availableInitiatives.where((item) => item.isPopular).toList();

  List<Initiative> get recommendedInitiatives =>
      InitiativeInsights.recommended(availableInitiatives);

  List<Initiative> get recentInitiatives =>
      availableInitiatives.reversed.take(3).toList();

  List<Initiative> get myInitiatives =>
      _initiatives.where((item) => item.isMine).toList();

  List<Initiative> get savedInitiatives =>
      _initiatives.where((item) => _savedIds.contains(item.id)).toList();

  int get openSlotsCount =>
      InitiativeInsights.openSlotsCount(activeInitiatives);

  List<RoleDemand> get roleDemand =>
      InitiativeInsights.roleDemand(availableInitiatives);

  List<String> get categoryOptions {
    final options = <String>{};
    for (final initiative in _initiatives) {
      options.addAll(initiative.categories);
    }
    return _sortedFilterOptions(options);
  }

  List<String> get roleOptions {
    final options = <String>{};
    for (final initiative in _initiatives) {
      options.addAll(initiative.roles.map((role) => role.name));
    }
    return _sortedFilterOptions(options);
  }

  List<String> get filterOptions => [
    allFilter,
    ...{...categoryOptions, ...roleOptions},
  ];

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

  Initiative? initiativeById(String id) {
    for (final initiative in _initiatives) {
      if (initiative.id == id) return initiative;
    }
    return null;
  }

  bool isSaved(String initiativeId) => _savedIds.contains(initiativeId);

  void setInitiatives(List<Initiative> initiatives) {
    _initiatives = List.of(initiatives);
  }

  void add(Initiative initiative) {
    _initiatives = [..._initiatives, initiative];
  }

  void replace(Initiative updated) {
    _initiatives = [
      for (final item in _initiatives) item.id == updated.id ? updated : item,
    ];
  }

  void remove(Initiative initiative) {
    _initiatives = _initiatives.where((i) => i.id != initiative.id).toList();
    _savedIds.remove(initiative.id);
  }

  void clearSaved() => _savedIds.clear();

  void setSaved(Iterable<String> initiativeIds) {
    _savedIds
      ..clear()
      ..addAll(initiativeIds);
  }

  void toggleSaved(String initiativeId) {
    if (!_savedIds.remove(initiativeId)) _savedIds.add(initiativeId);
  }

  void setFilter(String value) => _filter = value;

  void setQuery(String value) => _query = value;

  void setSort(InitiativeSort value) => _sort = value;

  void clearFilters() {
    _filter = allFilter;
    _query = '';
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

  List<String> _sortedFilterOptions(Set<String> options) {
    return options.where((item) => item.isNotEmpty).toList()..sort();
  }
}
