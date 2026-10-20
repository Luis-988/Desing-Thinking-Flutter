abstract class SavedInitiativeRepository {
  Future<Set<String>> getSavedInitiativeIds();
  Future<void> saveInitiative(String initiativeId);
  Future<void> removeInitiative(String initiativeId);
}
