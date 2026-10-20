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
import '../../domain/entities/project_sprint.dart';
import '../../domain/entities/workspace_publication.dart';
import '../../domain/entities/sprint_feedback.dart';
import '../../domain/entities/workspace_member.dart';
import '../providers/initiatives_controller.dart';
import '../providers/project_activities_controller.dart';
import '../providers/project_sprints_controller.dart';
import '../providers/sprint_feedback_controller.dart';
import '../providers/workspace_controller.dart';

void openProjectWorkspace(BuildContext context, String initiativeId) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) =>
                context
                    .read<AppDependencies>()
                    .createProjectActivitiesController()
                  ..load(initiativeId),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                context.read<AppDependencies>().createSprintFeedbackController()
                  ..load(initiativeId),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                context.read<AppDependencies>().createProjectSprintsController()
                  ..load(initiativeId),
          ),
          ChangeNotifierProvider(
            create: (context) {
              final initiatives = context.read<InitiativesController>();
              final initiative = initiatives.initiativeById(initiativeId);
              final initialMembers = [
                if (initiative != null)
                  WorkspaceMember(
                    id: 'leader-${initiative.id}',
                    initiativeId: initiative.id,
                    name: initiative.leader,
                    roleName: 'Líder',
                    role: WorkspaceMemberRole.leader,
                    canManageTasks: true,
                    canComment: true,
                    canChat: true,
                  ),
                ...initiatives
                    .acceptedMembersFor(initiativeId)
                    .map(
                      (member) => WorkspaceMember(
                        id: member.id,
                        initiativeId: initiativeId,
                        name: member.applicantName,
                        roleName: member.roleName,
                        role: WorkspaceMemberRole.collaborator,
                        canManageTasks: false,
                        canComment: true,
                        canChat: true,
                      ),
                    ),
              ];
              return context.read<AppDependencies>().createWorkspaceController()
                ..load(initiativeId, initialMembers: initialMembers);
            },
          ),
        ],
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
  late final TextEditingController _chatController;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
    _chatController = TextEditingController();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  DateTime get _selectedWeek => _weekStart(_selectedDate);

  @override
  Widget build(BuildContext context) {
    final initiatives = context.watch<InitiativesController>();
    final activities = context.watch<ProjectActivitiesController>();
    final sprints = context.watch<ProjectSprintsController>();
    final initiative = initiatives.initiativeById(widget.initiativeId);

    if (initiative == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ruta de trabajo')),
        body: const Center(
          child: Text('Esta iniciativa ya no está disponible.'),
        ),
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
          child: Text(
            'Esta ruta solo está disponible para el equipo del proyecto.',
          ),
        ),
      );
    }

    final completed = activities.activities
        .where((item) => item.isCompleted)
        .length;

    return DefaultTabController(
      length: 4,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ruta de trabajo'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Detalles'),
              Tab(text: 'Sprints'),
              Tab(text: 'Chat'),
              Tab(text: 'Avances'),
            ],
          ),
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
        body: TabBarView(
          children: [
            _WorkspaceDetailsTab(
              initiative: initiative,
              members: acceptedMembers,
              completed: completed,
              total: activities.activities.length,
              onAddComment: (text) => _addComment(text),
              onManageTeam: isLeader ? () => _manageTeam(initiative) : null,
            ),
            _buildTimeline(
              initiative,
              activities,
              sprints,
              isTeamMember,
              acceptedMembers,
              completed,
            ),
            _WorkspaceChatTab(
              controller: context.watch<WorkspaceController>(),
              inputController: _chatController,
              onSend: _sendMessage,
            ),
            _WorkspacePublicationsTab(
              controller: context.watch<WorkspaceController>(),
              initiativeId: widget.initiativeId,
              canPublish: isLeader,
              onCreate: () => _createPublication(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(
    Initiative initiative,
    ProjectActivitiesController activities,
    ProjectSprintsController sprints,
    bool isTeamMember,
    List<InitiativeApplication> acceptedMembers,
    int completed,
  ) {
    final activitiesInWeek =
        activities.activities
            .where((activity) => _weekStart(activity.dueDate) == _selectedWeek)
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final isLeader = initiative.isMine;
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          activities.load(initiative.id),
          sprints.load(initiative.id),
        ]);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text('Sprint actual', style: AppText.screenTitle),
          const SizedBox(height: 6),
          Text(
            '${activities.activities.length} actividades · $completed realizadas',
            style: AppText.caption,
          ),
          const SizedBox(height: 20),
          _TeamSection(initiative: initiative, members: acceptedMembers),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text('Plan de trabajo', style: AppText.sectionTitle),
              ),
              if (isLeader)
                IconButton(
                  tooltip: 'Crear sprint',
                  onPressed: () => _createSprint(initiative, sprints),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              IconButton(
                tooltip: 'Periodo anterior',
                onPressed: () => _moveWeek(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                tooltip: 'Periodo siguiente',
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
          if (sprints.isLoading)
            const LinearProgressIndicator()
          else if (sprints.error != null)
            _LoadError(
              message: sprints.error!,
              onRetry: () => sprints.load(initiative.id),
            )
          else if (sprints.sprints.isNotEmpty) ...[
            Text('Sprints del proyecto', style: AppText.sectionTitle),
            const SizedBox(height: 10),
            for (final sprint in sprints.sprints)
              _SprintSummary(
                sprint: sprint,
                activities: activities.activities,
                onAddFeedback: (text) => _addSprintFeedback(sprint, text),
              ),
            const SizedBox(height: 12),
          ],
          Text(
            'Sprint del ${_formatDate(_selectedWeek)} al ${_formatDate(_selectedWeek.add(const Duration(days: 6)))}',
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
                onEdit: () => _editActivity(initiative, activities, activity),
                onDelete: () =>
                    _deleteActivity(initiative, activities, activity),
              ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await context.read<WorkspaceController>().sendMessage(
        initiativeId: widget.initiativeId,
        author: 'Tú',
        text: text.trim(),
      );
      _chatController.clear();
    } catch (error) {
      if (mounted) showAppSnack(context, messageOf(error));
    }
  }

  Future<void> _createPublication() async {
    final titleController = TextEditingController();
    final textController = TextEditingController();
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publicar avance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: '¿Qué cambió?'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              final text = textController.text.trim();
              if (title.isNotEmpty && text.isNotEmpty) {
                Navigator.pop(context, (title, text));
              }
            },
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
    titleController.dispose();
    textController.dispose();
    if (result == null || !mounted) return;
    try {
      await context.read<WorkspaceController>().createPublication(
        initiativeId: widget.initiativeId,
        author: 'Tú',
        title: result.$1,
        text: result.$2,
      );
      if (mounted) showAppSnack(context, 'Avance publicado.');
    } catch (error) {
      if (mounted) showAppSnack(context, messageOf(error));
    }
  }

  Future<void> _addComment(String text) async {
    if (text.trim().isEmpty) return;
    await context.read<WorkspaceController>().addComment(
      initiativeId: widget.initiativeId,
      author: 'Tú',
      text: text.trim(),
    );
    if (mounted) showAppSnack(context, 'Comentario añadido.');
  }

  Future<void> _manageTeam(Initiative initiative) async {
    final workspaceController = context.read<WorkspaceController>();
    await showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: workspaceController,
        child: _ManageTeamDialog(initiative: initiative),
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
      builder: (_) => _AddActivityDialog(
        initiativeId: initiative.id,
        sprints: context.read<ProjectSprintsController>().sprints,
      ),
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

  Future<void> _createSprint(
    Initiative initiative,
    ProjectSprintsController controller,
  ) async {
    final sprint = await showDialog<ProjectSprint>(
      context: context,
      builder: (_) => _AddSprintDialog(
        initiativeId: initiative.id,
        order: controller.sprints.length + 1,
      ),
    );
    if (sprint == null || !mounted) return;
    try {
      await controller.create(sprint);
      if (mounted) showAppSnack(context, 'Sprint creado.');
    } catch (error) {
      if (mounted) showAppSnack(context, messageOf(error));
    }
  }

  Future<void> _addSprintFeedback(ProjectSprint sprint, String text) async {
    final feedback = SprintFeedback(
      id: '',
      initiativeId: widget.initiativeId,
      sprintId: sprint.id,
      author: 'Tú',
      text: text,
      createdAt: DateTime.now(),
    );
    try {
      await context.read<SprintFeedbackController>().create(feedback);
      if (mounted) showAppSnack(context, 'Feedback añadido.');
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
        sprints: context.read<ProjectSprintsController>().sprints,
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
      await controller.setCompleted(activity, isCompleted, isTeamMember: true);
      if (mounted) {
        showAppSnack(
          context,
          isCompleted
              ? 'Actividad marcada como realizada.'
              : 'Actividad reabierta.',
        );
      }
    } catch (error) {
      if (mounted) showAppSnack(context, messageOf(error));
    }
  }
}

class _WorkspaceDetailsTab extends StatefulWidget {
  final Initiative initiative;
  final List<InitiativeApplication> members;
  final int completed;
  final int total;
  final ValueChanged<String> onAddComment;
  final VoidCallback? onManageTeam;

  const _WorkspaceDetailsTab({
    required this.initiative,
    required this.members,
    required this.completed,
    required this.total,
    required this.onAddComment,
    required this.onManageTeam,
  });

  @override
  State<_WorkspaceDetailsTab> createState() => _WorkspaceDetailsTabState();
}

class _WorkspaceDetailsTabState extends State<_WorkspaceDetailsTab> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceController>();
    final progress = widget.total == 0
        ? 0
        : ((widget.completed / widget.total) * 100).round();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(widget.initiative.title, style: AppText.screenTitle),
            ),
            const _WorkspacePill(label: 'Proyecto en curso'),
          ],
        ),
        const SizedBox(height: 8),
        Text(widget.initiative.description, style: AppText.body),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Progreso del sprint',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text('$progress%', style: AppText.sectionTitle),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: progress / 100),
                const SizedBox(height: 8),
                Text(
                  '${widget.completed} de ${widget.total} tareas realizadas',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Objetivo actual'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Organizar y validar la siguiente entrega con el equipo.',
                style: AppText.body,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: _WorkspaceMembersSection(
            initiative: widget.initiative,
            fallbackMembers: widget.members,
            onManageTeam: widget.onManageTeam,
          ),
        ),
        const SizedBox(height: 20),
        Text('Feedback del equipo', style: AppText.sectionTitle),
        const SizedBox(height: 8),
        if (workspace.comments.isEmpty)
          const Text('Aún no hay comentarios. Comparte el primer feedback.')
        else
          for (final comment in workspace.comments)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: InitialsAvatar(name: comment.author, radius: 16),
              title: Text(comment.author),
              subtitle: Text(comment.text),
            ),
        const SizedBox(height: 8),
        TextField(
          controller: _commentController,
          minLines: 1,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Escribe un comentario para el equipo',
            suffixIcon: IconButton(
              tooltip: 'Enviar comentario',
              onPressed: () {
                final text = _commentController.text.trim();
                if (text.isEmpty) return;
                widget.onAddComment(text);
                _commentController.clear();
              },
              icon: const Icon(Icons.send),
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkspaceChatTab extends StatelessWidget {
  final WorkspaceController controller;
  final TextEditingController inputController;
  final ValueChanged<String> onSend;

  const _WorkspaceChatTab({
    required this.controller,
    required this.inputController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: controller.messages.isEmpty
              ? const Center(child: Text('El chat del equipo comenzará aquí.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.messages.length,
                  itemBuilder: (_, index) {
                    final message = controller.messages[index];
                    return Align(
                      alignment: message.author == 'Tú'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Card(
                        color: message.author == 'Tú' ? AppColors.navy : null,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.author,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: message.author == 'Tú'
                                      ? Colors.white
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message.text,
                                style: TextStyle(
                                  color: message.author == 'Tú'
                                      ? Colors.white
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: inputController,
              textInputAction: TextInputAction.send,
              onSubmitted: onSend,
              decoration: InputDecoration(
                hintText: 'Escribe al equipo',
                suffixIcon: IconButton(
                  tooltip: 'Enviar mensaje',
                  onPressed: () => onSend(inputController.text),
                  icon: const Icon(Icons.send),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkspacePublicationsTab extends StatefulWidget {
  final WorkspaceController controller;
  final String initiativeId;
  final bool canPublish;
  final VoidCallback onCreate;

  const _WorkspacePublicationsTab({
    required this.controller,
    required this.initiativeId,
    required this.canPublish,
    required this.onCreate,
  });

  @override
  State<_WorkspacePublicationsTab> createState() =>
      _WorkspacePublicationsTabState();
}

class _WorkspacePublicationsTabState
    extends State<_WorkspacePublicationsTab> {
  Future<void> _comment(WorkspacePublication publication) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comentar avance'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Escribe tu comentario'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (text == null || !mounted) return;
    try {
      await widget.controller.addPublicationComment(
        initiativeId: widget.initiativeId,
        publicationId: publication.id,
        author: 'Tú',
        text: text,
      );
    } catch (error) {
      if (mounted) showAppSnack(context, messageOf(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Avances del proyecto', style: AppText.sectionTitle),
            ),
            if (widget.canPublish)
              FilledButton.icon(
                onPressed: widget.onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Publicar'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.controller.publications.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Todavía no hay avances publicados. Comparte los cambios '
                'importantes del proyecto con la comunidad.',
              ),
            ),
          )
        else
          for (final publication in widget.controller.publications)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      publication.title,
                      style: AppText.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(publication.text, style: AppText.body),
                    const SizedBox(height: 10),
                    Text(
                      'Publicado por ${publication.author}',
                      style: AppText.caption,
                    ),
                    const SizedBox(height: 10),
                    for (final comment in widget.controller
                        .commentsForPublication(publication.id))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('${comment.author}: ${comment.text}'),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _comment(publication),
                        icon: const Icon(Icons.comment_outlined),
                        label: const Text('Comentar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _WorkspacePill extends StatelessWidget {
  final String label;

  const _WorkspacePill({required this.label});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.navy.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _WorkspaceMembersSection extends StatelessWidget {
  final Initiative initiative;
  final List<InitiativeApplication> fallbackMembers;
  final VoidCallback? onManageTeam;

  const _WorkspaceMembersSection({
    required this.initiative,
    required this.fallbackMembers,
    required this.onManageTeam,
  });

  @override
  Widget build(BuildContext context) {
    final workspace = context.watch<WorkspaceController>();
    final members = workspace.members;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Equipo', style: AppText.sectionTitle)),
              if (onManageTeam != null)
                TextButton.icon(
                  onPressed: onManageTeam,
                  icon: const Icon(Icons.manage_accounts_outlined),
                  label: const Text('Gestionar'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (members.isEmpty)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MemberLabel(name: initiative.leader, role: 'Líder'),
                for (final member in fallbackMembers)
                  _MemberLabel(
                    name: member.applicantName,
                    role: member.roleName,
                  ),
              ],
            )
          else
            for (final member in members)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: InitialsAvatar(name: member.name, radius: 18),
                title: Text(
                  member.name,
                  style: AppText.body.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(member.roleName),
                trailing: member.role == WorkspaceMemberRole.leader
                    ? const _WorkspacePill(label: 'Líder')
                    : null,
              ),
        ],
      ),
    );
  }
}

class _SprintSummary extends StatelessWidget {
  final ProjectSprint sprint;
  final List<ProjectActivity> activities;
  final ValueChanged<String> onAddFeedback;

  const _SprintSummary({
    required this.sprint,
    required this.activities,
    required this.onAddFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final sprintActivities = activities.where((activity) {
      if (activity.sprintId != null) {
        return activity.sprintId == sprint.id;
      }
      final date = _dateOnly(activity.dueDate);
      return !date.isBefore(_dateOnly(sprint.startDate)) &&
          !date.isAfter(_dateOnly(sprint.endDate));
    }).toList();
    final completed = sprintActivities
        .where((activity) => activity.isCompleted)
        .length;
    final progress = sprintActivities.isEmpty
        ? 0.0
        : completed / sprintActivities.length;
    final feedback = context.watch<SprintFeedbackController>().forSprint(
      sprint.id,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    sprint.name,
                    style: AppText.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text('${(progress * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${_formatDate(sprint.startDate)} - ${_formatDate(sprint.endDate)}',
              style: AppText.caption,
            ),
            if (sprint.objective.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(sprint.objective, style: AppText.body),
            ],
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 6),
            Text(
              '$completed de ${sprintActivities.length} actividades',
              style: AppText.caption,
            ),
            if (feedback.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final item in feedback)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${item.author}: ${item.text}'),
                ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  final controller = TextEditingController();
                  final text = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Feedback · ${sprint.name}'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Escribe feedback para este sprint',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () {
                            final value = controller.text.trim();
                            if (value.isNotEmpty) Navigator.pop(context, value);
                          },
                          child: const Text('Enviar'),
                        ),
                      ],
                    ),
                  );
                  controller.dispose();
                  if (text != null) onAddFeedback(text);
                },
                icon: const Icon(Icons.feedback_outlined),
                label: const Text('Dar feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSprintDialog extends StatefulWidget {
  final String initiativeId;
  final int order;

  const _AddSprintDialog({required this.initiativeId, required this.order});

  @override
  State<_AddSprintDialog> createState() => _AddSprintDialogState();
}

class _AddSprintDialogState extends State<_AddSprintDialog> {
  final _nameController = TextEditingController();
  final _objectiveController = TextEditingController();
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = _dateOnly(DateTime.now());
    _endDate = _startDate.add(const Duration(days: 13));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _objectiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear sprint'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: _objectiveController,
              decoration: const InputDecoration(labelText: 'Objetivo'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Inicio'),
              subtitle: Text(_formatDate(_startDate)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () => _pickDate(isStart: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fin'),
              subtitle: Text(_formatDate(_endDate)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () => _pickDate(isStart: false),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _nameController.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(
                  ProjectSprint(
                    id: '',
                    initiativeId: widget.initiativeId,
                    name: _nameController.text.trim(),
                    objective: _objectiveController.text.trim(),
                    startDate: _startDate,
                    endDate: _endDate,
                    status: ProjectSprintStatus.planned,
                    order: widget.order,
                  ),
                ),
          child: const Text('Crear'),
        ),
      ],
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (selected == null) return;
    setState(() {
      if (isStart) {
        _startDate = _dateOnly(selected);
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 13));
        }
      } else if (!selected.isBefore(_startDate)) {
        _endDate = _dateOnly(selected);
      }
    });
  }
}

class _ManageTeamDialog extends StatefulWidget {
  final Initiative initiative;

  const _ManageTeamDialog({required this.initiative});

  @override
  State<_ManageTeamDialog> createState() => _ManageTeamDialogState();
}

class _ManageTeamDialogState extends State<_ManageTeamDialog> {
  final Map<String, WorkspaceMember> _drafts = {};

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<WorkspaceController>();
    final members = controller.members;
    return AlertDialog(
      title: const Text('Gestionar equipo'),
      content: SizedBox(
        width: 520,
        child: members.isEmpty
            ? const Text('Todavía no hay miembros registrados.')
            : ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    'El creador conserva el control principal. Puedes asignar '
                    'permisos a los demás integrantes.',
                  ),
                  const SizedBox(height: 16),
                  for (final member in members)
                    _MemberPermissionEditor(
                      member: _drafts[member.id] ?? member,
                      onChanged: (updated) =>
                          setState(() => _drafts[member.id] = updated),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: members.isEmpty
              ? null
              : () async {
                  for (final member in _drafts.values) {
                    await controller.updateMember(member);
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
          child: const Text('Guardar cambios'),
        ),
      ],
    );
  }
}

class _MemberPermissionEditor extends StatelessWidget {
  final WorkspaceMember member;
  final ValueChanged<WorkspaceMember> onChanged;

  const _MemberPermissionEditor({
    required this.member,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLeader = member.role == WorkspaceMemberRole.leader;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.name,
              style: AppText.body.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<WorkspaceMemberRole>(
              value: member.role,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: WorkspaceMemberRole.values
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Text(_roleLabel(role)),
                    ),
                  )
                  .toList(),
              onChanged: isLeader
                  ? null
                  : (role) {
                      if (role == null) return;
                      onChanged(
                        member.copyWith(role: role, roleName: _roleLabel(role)),
                      );
                    },
            ),
            if (!isLeader) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Gestionar tareas'),
                value: member.canManageTasks,
                onChanged: (value) =>
                    onChanged(member.copyWith(canManageTasks: value)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Comentar y dar feedback'),
                value: member.canComment,
                onChanged: (value) =>
                    onChanged(member.copyWith(canComment: value)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Participar en el chat'),
                value: member.canChat,
                onChanged: (value) =>
                    onChanged(member.copyWith(canChat: value)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _roleLabel(WorkspaceMemberRole role) {
  switch (role) {
    case WorkspaceMemberRole.leader:
      return 'Líder';
    case WorkspaceMemberRole.administrator:
      return 'Administrador';
    case WorkspaceMemberRole.collaborator:
      return 'Colaborador';
    case WorkspaceMemberRole.observer:
      return 'Observador';
  }
}

class _AddActivityDialog extends StatefulWidget {
  final String initiativeId;
  final ProjectActivity? activity;
  final List<ProjectSprint> sprints;

  const _AddActivityDialog({
    required this.initiativeId,
    required this.sprints,
    this.activity,
  });

  @override
  State<_AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<_AddActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _dueDate;
  String? _sprintId;

  @override
  void initState() {
    super.initState();
    final activity = widget.activity;
    _titleController.text = activity?.title ?? '';
    _descriptionController.text = activity?.description ?? '';
    _dueDate = _dateOnly(activity?.dueDate ?? DateTime.now());
    _sprintId = activity?.sprintId;
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
        sprintId: _sprintId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.activity == null ? 'Nueva actividad' : 'Editar actividad',
      ),
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
              if (widget.sprints.isNotEmpty) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: _sprintId,
                  decoration: const InputDecoration(labelText: 'Sprint'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Sin sprint'),
                    ),
                    if (_sprintId != null &&
                        !widget.sprints.any((sprint) => sprint.id == _sprintId))
                      DropdownMenuItem<String?>(
                        value: _sprintId,
                        enabled: false,
                        child: const Text('Sprint actual no disponible'),
                      ),
                    for (final sprint in widget.sprints)
                      DropdownMenuItem<String?>(
                        value: sprint.id,
                        child: Text(sprint.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _sprintId = value),
                ),
              ],
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
            onChanged: isTeamMember
                ? (value) => onChanged(value ?? false)
                : null,
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
