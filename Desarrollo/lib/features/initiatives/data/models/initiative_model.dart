import 'dart:convert';

import '../../domain/entities/initiative.dart';
import 'json_utils.dart';

/// Traduce entre la entidad [Initiative] y las filas de la tabla `iniciativas`.
class InitiativeModel {
  const InitiativeModel._();

  static Map<String, dynamic> toRow(Initiative initiative) => {
    'titulo': initiative.title,
    'descripcion': initiative.description,
    'categorias': jsonEncode(initiative.categories),
    'lider': initiative.leader,
    'popular_manual': initiative.isPopularManually,
    'activa': initiative.isActive,
    'vacantes': jsonEncode(
      initiative.roles
          .map((role) => {'name': role.name, 'description': role.description})
          .toList(),
    ),
    'visitas': initiative.views,
  };

  static Initiative fromRow(Map<String, dynamic> row, {bool isMine = false}) {
    return Initiative(
      id: row['_id'].toString(),
      title: (row['titulo'] ?? '').toString(),
      categories: decodeJsonList(row['categorias'])
          .map((e) => e.toString())
          .toList(),
      description: (row['descripcion'] ?? '').toString(),
      leader: (row['lider'] ?? 'Equipo Uninorte').toString(),
      isPopularManually: toBool(row['popular_manual']),
      isActive: row['activa'] == null ? true : toBool(row['activa']),
      roles: decodeJsonList(row['vacantes'])
          .whereType<Map>()
          .map(
            (e) => InitiativeRole(
              name: (e['name'] ?? '').toString(),
              description: (e['description'] ?? '').toString(),
            ),
          )
          .toList(),
      views: int.tryParse('${row['visitas'] ?? 0}') ?? 0,
      isMine: isMine,
    );
  }
}
