import '../models/initiative.dart';

const localInitiatives = <Initiative>[
  Initiative(
    id: 'unisports',
    title: 'Unisports',
    category: 'Ingeniería',
    description: 'Plataforma para conectar estudiantes mediante actividades deportivas y proyectos relacionados con el deporte universitario.',
    leader: 'Equipo Uninorte',
    isFeatured: true,
    isActive: true,
    roles: [
      InitiativeRole(name: 'Diseñador UX/UI', availablePlaces: 1),
      InitiativeRole(name: 'Desarrollador Frontend', availablePlaces: 2),
      InitiativeRole(name: 'Marketing', availablePlaces: 1),
    ],
  ),
  Initiative(
    id: 'ecotrack',
    title: 'EcoTrack Uninorte',
    category: 'Sostenibilidad',
    description: 'Sistema de reciclaje e incentivos dinámicos dentro de la universidad mediante código QR.',
    leader: 'Equipo Uninorte',
    isFeatured: true,
    isActive: true,
    roles: [InitiativeRole(name: 'Desarrollador Frontend', availablePlaces: 2)],
  ),
];
