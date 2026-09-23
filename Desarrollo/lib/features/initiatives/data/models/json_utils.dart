import 'dart:convert';

/// Lee una lista guardada como texto JSON en Roble (o ya decodificada).
List<dynamic> decodeJsonList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value;
  try {
    final decoded = jsonDecode(value.toString());
    return decoded is List ? decoded : [];
  } catch (_) {
    return [];
  }
}

bool toBool(dynamic value) =>
    value == true || value.toString().toLowerCase() == 'true' || value == 1;
