import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../domain/entities/initiative.dart';
import '../../domain/entities/initiative_application.dart';
import '../providers/initiatives_controller.dart';

void openProjectWorkspace(BuildContext context, String initiativeId) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ProjectWorkspacePage(initiativeId: initiativeId),
    ),
  );
}

class ProjectWorkspacePage extends StatefulWidget {
  final String initiativeId;

  const ProjectWorkspacePage({super.key, required this.initiativeId});

  @override
  State<ProjectWorkspacePage> createState() => _ProjectWorkspacePageState();
}

class _ProjectWorkspacePageState extends State<ProjectWorkspacePage> {
  final Map<String, TextEditingController> _controllers = {};
  Timer? _saveTimer;
  int _selectedWeek = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    Map<String, dynamic> saved = {};
    try {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(_storageKey);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) saved = decoded;
      }
    } catch (_) {
      _saveError = 'No se pudo cargar el borrador de este dispositivo.';
    }

    for (final week in _weeks) {
      for (final artifact in week.artifacts) {
        for (final field in artifact.fields) {
          final key = '${artifact.id}.${field.id}';
          _controllers[key] = TextEditingController(
            text: (saved[key] ?? '').toString(),
          );
        }
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String get _storageKey => 'workspace_${widget.initiativeId}';

  Future<void> _saveDraft() async {
    _saveTimer?.cancel();
    if (mounted) setState(() => _isSaving = true);
    try {
      await _persistDraft(_draftValues());
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = 'No se pudo guardar. Intenta de nuevo.';
        });
      }
    }
  }

  Map<String, String> _draftValues() => {
    for (final entry in _controllers.entries) entry.key: entry.value.text,
  };

  Future<void> _persistDraft(Map<String, String> values) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(values));
  }

  Future<void> _persistDraftOnClose() async {
    try {
      await _persistDraft(_draftValues());
    } catch (_) {}
  }

  void _scheduleSave() {
    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 650), _saveDraft);
  }

  int get _completedArtifacts =>
      _weeks.expand((week) => week.artifacts).where(_hasContent).length;

  bool _hasContent(WorkspaceArtifact artifact) => artifact.fields.any((field) {
    return _controllers['${artifact.id}.${field.id}']?.text.trim().isNotEmpty ??
        false;
  });

  @override
  void dispose() {
    _saveTimer?.cancel();
    unawaited(_persistDraftOnClose());
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initiatives = context.watch<InitiativesController>();
    final initiative = initiatives.initiativeById(widget.initiativeId);
    if (initiative == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Espacio de trabajo')),
        body: const Center(child: Text('Este proyecto ya no está disponible.')),
      );
    }

    final accepted = initiatives.acceptedMembersFor(initiative.id);
    final totalArtifacts = _weeks.fold<int>(
      0,
      (total, week) => total + week.artifacts.length,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espacio de trabajo'),
        actions: [
          IconButton(
            tooltip: 'Guardar avances',
            onPressed: _isLoading ? null : _saveDraft,
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _ProjectHeading(
                  initiative: initiative,
                  completed: _completedArtifacts,
                  total: totalArtifacts,
                ),
                const SizedBox(height: 24),
                _TeamSection(initiative: initiative, members: accepted),
                const SizedBox(height: 24),
                Text('Ruta de trabajo', style: AppText.sectionTitle),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var index = 0; index < _weeks.length; index++)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('Semana ${index + 1}'),
                            selected: _selectedWeek == index,
                            onSelected: (_) =>
                                setState(() => _selectedWeek = index),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _WeekContent(
                  week: _weeks[_selectedWeek],
                  controllers: _controllers,
                  onChanged: _scheduleSave,
                  hasContent: _hasContent,
                ),
              ],
            ),
      bottomNavigationBar: _isLoading
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _saveError ??
                          (_isSaving
                              ? 'Guardando en este dispositivo…'
                              : 'Avances guardados en este dispositivo'),
                      style: AppText.caption.copyWith(
                        color: _saveError == null
                            ? AppColors.muted
                            : AppColors.dangerFg,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _saveDraft,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProjectHeading extends StatelessWidget {
  final Initiative initiative;
  final int completed;
  final int total;

  const _ProjectHeading({
    required this.initiative,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EQUIPO COMPLETO · PROYECTO EN MARCHA',
          style: AppText.label,
        ),
        const SizedBox(height: 8),
        Text(initiative.title, style: AppText.screenTitle),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : completed / total,
                  minHeight: 7,
                  backgroundColor: AppColors.secondary,
                  color: AppColors.orange,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('$completed de $total entregables', style: AppText.caption),
          ],
        ),
      ],
    );
  }
}

class _TeamSection extends StatelessWidget {
  final Initiative initiative;
  final List<InitiativeApplication> members;

  const _TeamSection({required this.initiative, required this.members});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Equipo', style: AppText.sectionTitle)),
            Text('${members.length + 1} integrantes', style: AppText.caption),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MemberLabel(name: initiative.leader, role: 'Líder'),
            for (final member in members)
              _MemberLabel(name: member.applicantName, role: member.roleName),
          ],
        ),
      ],
    );
  }
}

class _MemberLabel extends StatelessWidget {
  final String name;
  final String role;

  const _MemberLabel({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InitialsAvatar(name: name, radius: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: AppText.body.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(role, style: AppText.caption),
          ],
        ),
      ],
    );
  }
}

class _WeekContent extends StatelessWidget {
  final WorkspaceWeek week;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onChanged;
  final bool Function(WorkspaceArtifact) hasContent;

  const _WeekContent({
    required this.week,
    required this.controllers,
    required this.onChanged,
    required this.hasContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(week.title, style: AppText.sectionTitle),
        const SizedBox(height: 4),
        Text(week.goal, style: AppText.body),
        const SizedBox(height: 16),
        for (final artifact in week.artifacts) ...[
          Row(
            children: [
              Expanded(child: Text(artifact.title, style: AppText.bodyLarge)),
              Icon(
                hasContent(artifact)
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                size: 18,
                color: hasContent(artifact)
                    ? AppColors.successFg
                    : AppColors.muted,
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final field in artifact.fields) ...[
            Text(field.label, style: AppText.label),
            const SizedBox(height: 5),
            TextField(
              controller: controllers['${artifact.id}.${field.id}'],
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: field.hint,
                alignLabelWithHint: true,
                filled: true,
                fillColor: AppColors.surface,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 12),
          ],
          const Divider(height: 28),
        ],
      ],
    );
  }
}

class WorkspaceWeek {
  final String title;
  final String goal;
  final List<WorkspaceArtifact> artifacts;

  const WorkspaceWeek(this.title, this.goal, this.artifacts);
}

class WorkspaceArtifact {
  final String id;
  final String title;
  final List<WorkspaceField> fields;

  const WorkspaceArtifact(this.id, this.title, this.fields);
}

class WorkspaceField {
  final String id;
  final String label;
  final String hint;

  const WorkspaceField(this.id, this.label, this.hint);
}

const _weeks = <WorkspaceWeek>[
  WorkspaceWeek(
    'Comprender a las personas',
    'Investigar antes de proponer soluciones.',
    [
      WorkspaceArtifact('entrevista_1', 'Entrevista 1', [
        WorkspaceField(
          'objetivo',
          'Objetivo y perfil',
          '¿Por qué eligieron a esta persona y qué esperan aprender?',
        ),
        WorkspaceField(
          'contexto',
          'Contexto',
          'Fecha, lugar o medio y duración.',
        ),
        WorkspaceField(
          'preguntas',
          'Preguntas realizadas',
          'Anota las preguntas principales de la conversación.',
        ),
        WorkspaceField(
          'respuestas',
          'Respuestas y frases clave',
          'Resume respuestas y registra citas sin datos identificables.',
        ),
        WorkspaceField(
          'necesidades',
          'Necesidades y dificultades',
          '¿Qué necesita la persona y qué obstáculos enfrenta?',
        ),
        WorkspaceField(
          'hallazgos',
          'Hallazgos y conclusión',
          '¿Qué sorprendió al equipo y qué aprendieron?',
        ),
      ]),
      WorkspaceArtifact('entrevista_2', 'Entrevista 2', [
        WorkspaceField(
          'objetivo',
          'Objetivo y perfil',
          '¿Por qué eligieron a esta persona y qué esperan aprender?',
        ),
        WorkspaceField(
          'contexto',
          'Contexto',
          'Fecha, lugar o medio y duración.',
        ),
        WorkspaceField(
          'preguntas',
          'Preguntas realizadas',
          'Anota las preguntas principales de la conversación.',
        ),
        WorkspaceField(
          'respuestas',
          'Respuestas y frases clave',
          'Resume respuestas y registra citas sin datos identificables.',
        ),
        WorkspaceField(
          'necesidades',
          'Necesidades y dificultades',
          '¿Qué necesita la persona y qué obstáculos enfrenta?',
        ),
        WorkspaceField(
          'hallazgos',
          'Hallazgos y conclusión',
          '¿Qué sorprendió al equipo y qué aprendieron?',
        ),
      ]),
      WorkspaceArtifact('observacion', 'Historia de innovación y observación', [
        WorkspaceField(
          'iniciativa',
          'Iniciativa y persona',
          'Nombre del proyecto, seudónimo y rol.',
        ),
        WorkspaceField(
          'origen',
          'Origen y problema',
          '¿Cómo nació la idea y qué problema busca resolver?',
        ),
        WorkspaceField(
          'validacion',
          'Validación y aprendizajes',
          '¿Cómo supieron que el problema existía? ¿Qué aprendieron?',
        ),
        WorkspaceField(
          'equipo',
          'Equipo y retos',
          '¿Cómo se formó el equipo y cuáles han sido sus retos?',
        ),
        WorkspaceField(
          'oportunidades',
          'Oportunidades y reflexión',
          '¿Qué harían distinto y qué apoyo necesita el proyecto?',
        ),
      ]),
    ],
  ),
  WorkspaceWeek(
    'Definir el problema',
    'Conectar los hallazgos con una necesidad prioritaria.',
    [
      WorkspaceArtifact('mapa_insights', 'Mapa de insights', [
        WorkspaceField(
          'usuarios',
          'Usuarios analizados',
          '¿Qué perfiles de usuario revisaron?',
        ),
        WorkspaceField(
          'hallazgos',
          'Hallazgos repetidos',
          '¿Qué observamos y por qué importa?',
        ),
        WorkspaceField(
          'tensiones',
          'Tensiones o contradicciones',
          '¿Qué prioridades difieren entre usuarios?',
        ),
        WorkspaceField(
          'necesidades',
          'Necesidades detectadas',
          'Completa: Los usuarios necesitan…',
        ),
        WorkspaceField(
          'barreras',
          'Barreras actuales',
          '¿Qué impide resolver bien el problema hoy?',
        ),
        WorkspaceField(
          'insight',
          'Insight principal',
          'Conecta comportamiento, necesidad y oportunidad.',
        ),
      ]),
      WorkspaceArtifact('pov', 'Punto de vista del equipo (POV)', [
        WorkspaceField(
          'usuario',
          'Usuario principal',
          '¿Quién es y qué caracteriza su contexto?',
        ),
        WorkspaceField(
          'objetivo',
          'Qué intenta lograr',
          '¿Cuál es su meta principal?',
        ),
        WorkspaceField(
          'dificultad',
          'Qué le cuesta hoy',
          'Describe la dificultad concreta.',
        ),
        WorkspaceField(
          'necesidad',
          'Necesidad prioritaria',
          '¿Qué necesita resolver primero?',
        ),
        WorkspaceField(
          'insight',
          'Insight clave',
          '¿Qué comprendieron que antes no veían?',
        ),
        WorkspaceField(
          'declaracion',
          'Declaración POV',
          'Usuario necesita… porque…',
        ),
        WorkspaceField(
          'criterios',
          'Criterios de solución',
          '¿Qué debería permitir una buena solución?',
        ),
        WorkspaceField(
          'fuera',
          'Fuera de alcance',
          '¿Qué no resolverán en esta etapa?',
        ),
      ]),
    ],
  ),
  WorkspaceWeek(
    'Idear y elegir una dirección',
    'Explorar alternativas antes de seleccionar un concepto.',
    [
      WorkspaceArtifact('ideacion', 'Ideación y flujos prioritarios', [
        WorkspaceField(
          'problema',
          'Recordatorio del problema',
          'Resume el POV que guía esta ideación.',
        ),
        WorkspaceField('pregunta', 'Pregunta guía', '¿Cómo podríamos…?'),
        WorkspaceField(
          'alternativas',
          'Flujos posibles',
          'Anota las alternativas de solución que exploraron.',
        ),
        WorkspaceField(
          'priorizados',
          'Flujos priorizados',
          '¿Qué quiere lograr el usuario en cada flujo?',
        ),
        WorkspaceField(
          'razones',
          'Importancia y riesgos',
          '¿Por qué priorizaron estos flujos y qué pasaría si fallan?',
        ),
      ]),
      WorkspaceArtifact('prototipos', 'Prototipos por flujo', [
        WorkspaceField(
          'objetivo',
          'Objetivo del flujo',
          '¿Qué quiere lograr la persona?',
        ),
        WorkspaceField(
          'version_a',
          'Versión A',
          'Describe los pasos y pantallas clave de la primera alternativa.',
        ),
        WorkspaceField(
          'version_b',
          'Versión B',
          'Describe los pasos y pantallas clave de la segunda alternativa.',
        ),
        WorkspaceField(
          'evidencia',
          'Evidencia exploratoria',
          '¿Con quién probaron y qué reacción generó cada versión?',
        ),
        WorkspaceField(
          'seleccion',
          'Versión seleccionada',
          '¿Cuál avanza y por qué?',
        ),
        WorkspaceField(
          'aprendizajes',
          'Aprendizajes y dudas',
          '¿Qué funcionó y qué necesitan seguir validando?',
        ),
      ]),
      WorkspaceArtifact('seleccion_concepto', 'Selección de concepto', [
        WorkspaceField(
          'flujos',
          'Flujos seleccionados',
          'Registra los flujos que decidieron trabajar.',
        ),
        WorkspaceField(
          'prioridad',
          'Razones de prioridad',
          '¿Por qué merece prioridad cada flujo?',
        ),
        WorkspaceField(
          'validacion',
          'Validación exploratoria',
          'Participantes, aprendizajes y versiones elegidas.',
        ),
        WorkspaceField(
          'hipotesis',
          'Hipótesis y riesgos',
          '¿Qué esperan validar y qué sigue sin estar claro?',
        ),
      ]),
    ],
  ),
  WorkspaceWeek(
    'Prototipar y probar',
    'Integrar los flujos y observar cómo los usan las personas.',
    [
      WorkspaceArtifact('guion_prueba', 'Guion de prueba con usuarios', [
        WorkspaceField(
          'objetivo',
          'Objetivo de la prueba',
          '¿Qué aspectos de la experiencia quieren validar?',
        ),
        WorkspaceField(
          'muestra',
          'Tipo y cantidad de participantes',
          '¿A quiénes invitarán y cuántas personas?',
        ),
        WorkspaceField(
          'escenario',
          'Escenario',
          'Escribe el contexto que presentarás al participante.',
        ),
        WorkspaceField(
          'tareas',
          'Tareas y preguntas',
          'Define entre tres y cinco tareas observables.',
        ),
        WorkspaceField(
          'observacion',
          'Qué observar y registrar',
          'Dudas, errores, comentarios y evidencia.',
        ),
        WorkspaceField(
          'exito',
          'Criterios de éxito',
          '¿Qué debe ocurrir para considerar que funciona?',
        ),
        WorkspaceField(
          'resultados',
          'Aplicación y resultados',
          '¿Cuántas pruebas realizaron y qué ocurrió?',
        ),
      ]),
      WorkspaceArtifact(
        'prototipo_integrado',
        'Planeación del prototipo integrado',
        [
          WorkspaceField(
            'flujos',
            'Flujos que integrarán',
            'Describe los flujos aprobados y sus versiones.',
          ),
          WorkspaceField(
            'objetivo',
            'Objetivo y alcance',
            '¿Qué comprobará el prototipo y qué queda fuera?',
          ),
          WorkspaceField(
            'pantallas',
            'Pantallas y conexiones',
            'Enumera las pantallas y cómo se conectan.',
          ),
          WorkspaceField(
            'herramienta',
            'Herramienta y evidencia',
            '¿Dónde se construye y dónde se consulta?',
          ),
          WorkspaceField(
            'hipotesis',
            'Hipótesis a validar',
            '¿Qué creen que ocurrirá cuando alguien use el prototipo?',
          ),
        ],
      ),
    ],
  ),
  WorkspaceWeek(
    'Iterar y preparar la implementación',
    'Convertir los resultados de validación en decisiones.',
    [
      WorkspaceArtifact('plan_iteracion', 'Plan de iteración', [
        WorkspaceField(
          'cambios',
          'Qué debemos cambiar',
          'Anota los ajustes identificados tras las pruebas.',
        ),
        WorkspaceField(
          'prioridades',
          'Prioridades',
          'Separa cambios urgentes, importantes y futuros.',
        ),
        WorkspaceField(
          'decision',
          'Decisión del equipo',
          '¿Mantendrán, ajustarán o replantearán la propuesta?',
        ),
        WorkspaceField(
          'proximo',
          'Próximo paso',
          '¿Qué hará el equipo en la siguiente etapa?',
        ),
        WorkspaceField(
          'preparacion',
          'Preparación para implementar',
          '¿Qué está listo y qué falta resolver?',
        ),
      ]),
      WorkspaceArtifact('resultados_validacion', 'Resultados de validación', [
        WorkspaceField(
          'pruebas',
          'Pruebas realizadas',
          'Participantes, perfiles y fechas.',
        ),
        WorkspaceField(
          'prototipo',
          'Qué se probó',
          'Describe la versión y los cambios incorporados.',
        ),
        WorkspaceField(
          'hallazgos',
          'Hallazgos principales',
          'Registra los tres aprendizajes más importantes.',
        ),
        WorkspaceField(
          'dificultades',
          'Dificultades y reacciones',
          '¿Dónde hubo dudas y qué valoraron las personas?',
        ),
        WorkspaceField(
          'citas',
          'Citas y evidencia',
          'Anota frases sin información que identifique a participantes.',
        ),
        WorkspaceField(
          'hipotesis',
          'Hipótesis',
          '¿Cuáles se confirmaron y cuáles no?',
        ),
        WorkspaceField(
          'comparacion',
          'Comparación y problemas abiertos',
          '¿Qué mejoró y qué necesita otra iteración?',
        ),
      ]),
    ],
  ),
];
