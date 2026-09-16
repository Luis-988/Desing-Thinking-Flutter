import '../models/initiative.dart';

final localInitiatives = <Initiative>[
  Initiative(
    id: 'unisports',
    title: 'Unisports',
    categories: ['Ingeniería', 'Tecnología'],
    description: 'Plataforma para conectar estudiantes mediante actividades deportivas y proyectos relacionados con el deporte universitario.',
    leader: 'Equipo Uninorte',
    isPopularManually: false,
    isActive: true,
    roles: [
      InitiativeRole(name: 'Diseñador UX/UI', description: 'Diseñar la experiencia y las pantallas de la plataforma.'),
      InitiativeRole(name: 'Desarrollador Frontend', description: 'Construir la interfaz web y conectar sus componentes.'),
      InitiativeRole(name: 'Marketing', description: 'Crear la estrategia de comunicación del proyecto.'),
    ],
  ),
  Initiative(
    id: 'ecotrack',
    title: 'EcoTrack Uninorte',
    categories: ['Sostenibilidad', 'Tecnología'],
    description: 'Sistema de reciclaje e incentivos dinámicos dentro de la universidad mediante código QR.',
    leader: 'Equipo Uninorte',
    isPopularManually: false,
    isActive: true,
    roles: [InitiativeRole(name: 'Desarrollador Frontend', description: 'Construir la interfaz y las funciones principales.')],
  ),
];
