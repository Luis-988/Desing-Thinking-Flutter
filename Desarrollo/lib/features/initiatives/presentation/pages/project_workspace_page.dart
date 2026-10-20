import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_snack.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../domain/entities/initiative.dart';
import '../../domain/entities/initiative_application.dart';
import '../../domain/entities/project_activity.dart';
import '../providers/initiatives_controller.dart';
import '../providers/project_activities_controller.dart';

void openProjectWorkspace(BuildContext context, String initiativeId) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider(
        create: (_) =>
            Injection.createProjectActivitiesController()
              ..load(initiativeId),
        child: ProjectWorkspacePage(initiativeId: initiativeId),
      ),
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
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
  }

  DateTime get _selectedWeek => _weekStart(_selectedDate);

  @override
  Widget build(BuildContext context) {
    final initiatives = context.watch<InitiativesController>();
    final activities = context.watch<ProjectActivitiesController>();
    final initiative = initiatives.initiativeById(widget.initiativeId);

    if (initiative == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ruta de trabajo')),
        body: const Center(child: Text('Esta iniciativa ya no está disponible.')),
      );
    }

    final acceptedMembers = initiatives.acceptedMembersFor(initiative.id);
    final isLeader = initiative.isMine;
    final isTeamMember =
        isLeader || acceptedMembers.any((member) => member.isMine);
    if (!isTeamMember) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ruta de trabajo')),
        body: const Center(
          child: Text('Esta ruta solo está disponible para el equipo del proyecto.'),
        ),
      );
    }

    final activitiesInWeek = activities.activities
        .where((activity) => _weekStart(activity.dueDate) == _selectedWeek)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final completed = activities.activities.where((item) => item.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta de trabajo'),
        actions: [
          if (isLeader)
            IconButton(
              tooltip: 'Añadir actividad',
              onPressed: () => _addActivity(initiative, activities),
              icon: const Icon(Icons.add_task),
            ),
          IconButton(
            tooltip: 'Actualizar actividades',
            onPressed: activities.isLoading
                ? null
                : () => activities.load(initiative.id),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => activities.load(initiative.id),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(initiative.title, style: AppText.screenTitle),
            const SizedBox(height: 6),
            Text(
              '${activities.activities.length} actividades · $completed realizadas',
              style: AppText.caption,
            ),
            const SizedBox(height: 20),
            _TeamSection(
              initiative: initiative,
              members: acceptedMembers,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text('Calendario del proyecto', style: AppText.sectionTitle),
                ),
                IconButton(
                  tooltip: 'Semana anterior',
                  onPressed: () => _moveWeek(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  tooltip: 'Semana siguiente',
                  onPressed: () => _moveWeek(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Card(
              clipBehavior: Clip.antiAlias,
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                onDateChanged: (date) =>
                    setState(() => _selectedDate = _dateOnly(date)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Semana ${_formatDate(_selectedWeek)} – ${_formatDate(_selectedWeek.add(const Duration(days: 6)))}',
              style: AppText.sectionTitle,
            ),
            const SizedBox(height: 10),
            if (activities.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (activities.error != null)
              _LoadError(
                message: activities.error!,
                onRetry: () => activities.load(initiative.id),
              )
            else if (activitiesInWeek.isEmpty)
              _EmptyWeek(isLeader: isLeader)
            else
              for (final activity in activitiesInWeek)
                _ActivityCard(
                  activity: activity,
                  isTeamMember: isTeamMember,
                  isLeader: isLeader,
                  onChanged: (isCompleted) =>
                      _setCompleted(activities, activity, isCompleted),
                  onEdit: () =>
                      _editActivity(initiative, activities, activity),
                  onDelete: () =>
                      _deleteActivity(initiative, activities, activity),
                ),
          ],
        ),
      ),
    );
  }

  void _moveWeek(int amount) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: amount * 7));
    });
  }

  Future<void> _addActivity(
    Initiative initiative,
    ProjectActivitiesController controller,
  ) async {
    final activity = await showDialog<ProjectActivity>(
      context: context,
      builder: (_) => _AddActivityDialog(initiativeId: initiative.id),
    );
    if (activity == null || !mounted) return;
    try {
      await controller.create(activity, isLeader: initiative.isMine);
      setState(() => _selectedDate = _dateOnly(activity.dueDate));
      if (!mounted) return;
      showAppSnack(context, 'Actividad añadida al calendario.');
    } catch (error) {
      if (mounted) showAppSnack(context, messageOf(error));
    }
  }

  Future<void> _editActivity(
    Initiative initiative,
    ProjectActivitiesController controller,
    ProjectActivity activity,
  ) async {
    final updated = await showDialog<ProjectActivity>(
      context: context,
      builder: (_) => _AddActivityDialog(
        initiativeId: initiative.id,
        activity: activity,
      ),
    );
    if (updated == null || !mounted) return;
    try {
      await controller.update(updated, isLeader: initiative.isMine);
      setState(() => _selectedDate = _dateOnly(updated.dueDate));
      if (mounted) showAppSnack(context, 'Actividad actualizada.');
    } catch (error) {
      if (mounted) showAppSnack(context, messageOf(error));
    }
  }

  Future<void> _deleteActivity(
    Initiative initiative,
    ProjectActivitiesController controller,
    ProjectActivity activity,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar actividad'),
        content: Text('¿Quieres eliminar "${activity.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await controller.delete(activity, isLeader: initiative.isMine);
      if (mounted) showAppSnack(context, 'Actividad eliminada.');
    } catch (error) {
      if (mounted) showAppSnack(context, messageOf(error));
    }
  }

  Future<void> _setCompleted(
    ProjectActivitiesController controller,
    ProjectActivity activity,
    bool isCompleted,
  ) async {
    try {
      await controller.setCompleted(
        activity,
        isCompleted,
        isTeamMember: true,
      );
      if (mounted) {
        showAppSnack(
          context,
          isCompleted ? 'Actividad marcada como realizada.' : 'Actividad reabierta.',
        );
      }
    } catch (error) {
      if (mounted) showAppSnack(context, messageOf(error));
    }
  }
}

class _AddActivityDialog extends StatefulWidget {
  final String initiativeId;
  final ProjectActivity? activity;

  const _AddActivityDialog({required this.initiativeId, this.activity});

  @override
  State<_AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<_AddActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    final activity = widget.activity;
    _titleController.text = activity?.title ?? '';
    _descriptionController.text = activity?.description ?? '';
    _dueDate = _dateOnly(activity?.dueDate ?? DateTime.now());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Selecciona la fecha límite de la actividad',
    );
    if (date != null) setState(() => _dueDate = _dateOnly(date));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ProjectActivity(
        id: widget.activity?.id ?? '',
        initiativeId: widget.initiativeId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        isCompleted: widget.activity?.isCompleted ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.activity == null ? 'Nueva actividad' : 'Editar actividad'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Actividad'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escribe el nombre de la actividad.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Fecha límite'),
                subtitle: Text(_formatDate(_dueDate)),
                onTap: _selectDate,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(widget.activity == null ? 'Añadir' : 'Guardar cambios'),
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
  Widget build(BuildContext context) => Column(
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
        spacing: 12,
        runSpacing: 12,
        children: [
          _MemberLabel(name: initiative.leader, role: 'Líder'),
          for (final member in members)
            _MemberLabel(name: member.applicantName, role: member.roleName),
        ],
      ),
    ],
  );
}

class _MemberLabel extends StatelessWidget {
  final String name;
  final String role;

  const _MemberLabel({required this.name, required this.role});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      InitialsAvatar(name: name, radius: 18),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: AppText.body.copyWith(fontWeight: FontWeight.w700)),
          Text(role, style: AppText.caption),
        ],
      ),
    ],
  );
}

class _ActivityCard extends StatelessWidget {
  final ProjectActivity activity;
  final bool isTeamMember;
  final bool isLeader;
  final ValueChanged<bool> onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActivityCard({
    required this.activity,
    required this.isTeamMember,
    required this.isLeader,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: activity.isCompleted,
            onChanged: isTeamMember ? (value) => onChanged(value ?? false) : null,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: activity.isCompleted
                        ? AppText.body.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.muted,
                          )
                        : AppText.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fecha límite: ${_formatDate(activity.dueDate)}',
                    style: AppText.caption,
                  ),
                  if (activity.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(activity.description, style: AppText.body),
                  ],
                  if (activity.isCompleted)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Realizada',
                        style: TextStyle(color: AppColors.successFg),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isLeader)
            PopupMenuButton<String>(
              tooltip: 'Opciones de actividad',
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar'),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline),
                    title: Text('Eliminar'),
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

class _EmptyWeek extends StatelessWidget {
  final bool isLeader;

  const _EmptyWeek({required this.isLeader});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      children: [
        const Icon(Icons.event_note_outlined, size: 36, color: AppColors.muted),
        const SizedBox(height: 8),
        Text(
          isLeader
              ? 'No hay actividades esta semana. Añade una para organizar el trabajo.'
              : 'El líder aún no ha añadido actividades para esta semana.',
          textAlign: TextAlign.center,
          style: AppText.body,
        ),
      ],
    ),
  );
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(message, style: AppText.body.copyWith(color: AppColors.dangerFg)),
      TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Reintentar'),
      ),
    ],
  );
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _weekStart(DateTime date) {
  final day = _dateOnly(date);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
