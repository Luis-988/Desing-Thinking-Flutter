import '../../domain/repositories/saved_initiative_repository.dart';

class InMemorySavedInitiativeRepository implements SavedInitiativeRepository {
  final Set<String> _savedIds = {};

  @override
  Future<Set<String>> getSavedInitiativeIds() async => Set.of(_savedIds);

  @override
  Future<void> saveInitiative(String initiativeId) async {
    _savedIds.add(initiativeId);
  }

  @override
  Future<void> removeInitiative(String initiativeId) async {
    _savedIds.remove(initiativeId);
  }
}
