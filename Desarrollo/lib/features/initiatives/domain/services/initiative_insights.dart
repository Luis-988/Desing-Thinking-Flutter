import '../entities/initiative.dart';

/// Datos derivados de iniciativas que pueden reutilizar distintas pantallas.
class InitiativeInsights {
  const InitiativeInsights._();

  static int openSlotsCount(Iterable<Initiative> initiatives) =>
      initiatives.fold(0, (total, initiative) => total + initiative.openSlots);

  static List<Initiative> recommended(Iterable<Initiative> initiatives) {
    final recommendations = initiatives.where((item) => item.isActive).toList()
      ..sort((a, b) {
        final scoreA = _recommendationScore(a);
        final scoreB = _recommendationScore(b);
        return scoreB.compareTo(scoreA);
      });
    return recommendations.take(3).toList();
  }

  static List<RoleDemand> roleDemand(Iterable<Initiative> initiatives) {
    final totals = <String, int>{};
    for (final initiative in initiatives) {
      if (!initiative.isActive) continue;
      for (final role in initiative.roles) {
        totals[role.name] = (totals[role.name] ?? 0) + role.slots;
      }
    }

    final entries = totals.entries
        .map((entry) => RoleDemand(role: entry.key, openSlots: entry.value))
        .toList()
      ..sort((a, b) => b.openSlots.compareTo(a.openSlots));
    return entries.take(5).toList();
  }

  static int _recommendationScore(Initiative initiative) =>
      (initiative.isPopular ? 3 : 0) + (initiative.openSlots > 0 ? 2 : 0);
}

class RoleDemand {
  final String role;
  final int openSlots;

  const RoleDemand({required this.role, required this.openSlots});
}
