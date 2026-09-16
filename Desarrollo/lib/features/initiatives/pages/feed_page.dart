import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/initiative.dart';
import 'initiative_pages.dart';

class FeedPage extends StatefulWidget {
  final List<Initiative> initiatives;

  const FeedPage({super.key, required this.initiatives});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  String selectedFilter = 'Todos';
  int selectedTab = 0;
  final List<Initiative> myInitiatives = [];
  final Set<String> savedInitiativeIds = {};
  final List<InitiativeApplication> applications = [
    InitiativeApplication(
      id: 'received-laura',
      initiativeId: 'unisports',
      applicantName: 'Laura Castillo',
      program: 'Diseño Industrial',
      semester: '6to semestre',
      roleName: 'Diseñador UX/UI',
      skills: 'Figma, User Research, Prototipado',
      message:
          'Me interesa mucho la iniciativa porque combina deporte con tecnología. Tengo experiencia en proyectos de rediseño de apps móviles.',
    ),
    InitiativeApplication(
      id: 'received-carlos',
      initiativeId: 'unisports',
      applicantName: 'Carlos Mendoza',
      program: 'Ingeniería de Sistemas',
      semester: '7mo semestre',
      roleName: 'Desarrollador Frontend',
      skills: 'React, TypeScript, Tailwind CSS',
      message:
          'He trabajado en dos proyectos web y me apasiona el deporte universitario. Quiero aportar mis conocimientos al equipo.',
    ),
    InitiativeApplication(
      id: 'received-sofia',
      initiativeId: 'unisports',
      applicantName: 'Sofía Herrera',
      program: 'Comunicación Social',
      semester: '5to semestre',
      roleName: 'Marketing',
      skills: 'Instagram, Copywriting, Canva, Estrategia de contenido',
      message:
          'Llevo un año manejando redes de organizaciones estudiantiles. Me gustaría aplicar esa experiencia en Unisports.',
    ),
  ];

  final filters = const [
    'Todos',
    'Diseñador UX/UI',
    'Desarrollador Frontend',
    'Ingeniería',
  ];

  List<Initiative> get allInitiatives => [
    ...widget.initiatives,
    ...myInitiatives,
  ];

  List<Initiative> get visibleInitiatives {
    if (selectedFilter == 'Todos') return allInitiatives;
    return allInitiatives.where((initiative) {
      return initiative.categories.contains(selectedFilter) ||
          initiative.roles.any((role) => role.name == selectedFilter);
    }).toList();
  }

  int _applicationCountFor(Initiative initiative) {
    return applications
        .where((application) => application.initiativeId == initiative.id)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(child: _selectedPage()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE4ECF8),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'Mis iniciativas',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Guardados',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _selectedPage() {
    if (selectedTab == 0 || selectedTab == 1) {
      return _feedContent();
    }

    if (selectedTab == 2) return _myInitiativesPage();
    if (selectedTab == 3) return _savedPage();

    final pages = [
      ('Perfil', Icons.person_outline, 'Tu perfil de innovación estará aquí.'),
    ];
    final page = pages[selectedTab - 4];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(page.$2, size: 52, color: AppTheme.navy),
            const SizedBox(height: 16),
            Text(
              page.$1,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              page.$3,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _savedPage() {
    final savedInitiatives = allInitiatives
        .where((initiative) => savedInitiativeIds.contains(initiative.id))
        .toList();

    return Column(
      children: [
        _header(),
        Expanded(
          child: savedInitiatives.isEmpty
              ? const Center(
                  child: Text(
                    'Aquí aparecerán los proyectos que guardes.',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  children: [
                    const Text(
                      'Guardados',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    ...savedInitiatives.map(
                      (initiative) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _initiativeCard(context, initiative),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _myInitiativesPage() {
    return Column(
      children: [
        _header(),
        Expanded(
          child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  children: [
                    const Text(
                      'Mis iniciativas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Postulaciones recibidas y proyectos publicados por ti',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    ),
                    const SizedBox(height: 18),
                    _applicationsSection(),
                    const SizedBox(height: 18),
                    if (myInitiatives.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: Text(
                          'Aquí aparecerán las iniciativas que publiques.',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    ...myInitiatives.map(
                      (initiative) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _initiativeCard(
                          context,
                          initiative,
                          onEdit: () => _editInitiative(initiative),
                          onDelete: () => _deleteInitiative(initiative),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _feedContent() {
    return Column(
      children: [
        _header(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              _intro(context),
              const SizedBox(height: 14),
              _filters(),
              const SizedBox(height: 18),
              ...visibleInitiatives.map(
                (initiative) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _initiativeCard(context, initiative),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _applicationsSection() {
    if (applications.isEmpty) return const SizedBox.shrink();

    final initiative = allInitiatives.firstWhere(
      (item) => item.id == applications.first.initiativeId,
    );
    final pendingApplications = applications
        .where((item) => item.status == ApplicationStatus.pending)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Postulaciones recibidas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                initiative.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            _tag('Mi iniciativa', const Color(0xFFE7EEF8), AppTheme.navy),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          '$pendingApplications pendientes · ${applications.length} en total',
          style: const TextStyle(color: Color(0xFF52627A), fontSize: 12),
        ),
        const SizedBox(height: 12),
        ...applications.map(_applicationCard),
      ],
    );
  }

  Widget _applicationCard(InitiativeApplication application) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFD9E1ED)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: const Color(0xFFEFF3F8),
                  child: Text(
                    application.applicantName
                        .split(' ')
                        .map((part) => part[0])
                        .take(2)
                        .join(),
                    style: const TextStyle(
                      color: AppTheme.navy,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.applicantName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${application.program} · ${application.semester}',
                        style: const TextStyle(
                          color: Color(0xFF52627A),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (application.status == ApplicationStatus.pending)
                  _tag(
                    'Pendiente',
                    const Color(0xFFFFF3B0),
                    const Color(0xFF9B6B00),
                  )
                else
                  _tag(
                    application.status == ApplicationStatus.accepted
                        ? 'Aceptada'
                        : 'Rechazada',
                    application.status == ApplicationStatus.accepted
                        ? const Color(0xFFD9F8E7)
                        : const Color(0xFFFDE2E1),
                    application.status == ApplicationStatus.accepted
                        ? const Color(0xFF0C8A4B)
                        : const Color(0xFFB42318),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: _tag(
                application.roleName,
                const Color(0xFFE8F4FF),
                const Color(0xFF0879B9),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'HABILIDADES',
              style: TextStyle(
                color: Color(0xFF52627A),
                fontSize: 10,
                letterSpacing: 1.1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              application.skills,
              style: const TextStyle(color: Color(0xFF304766), fontSize: 12),
            ),
            const SizedBox(height: 12),
            const Text(
              'MENSAJE',
              style: TextStyle(
                color: Color(0xFF52627A),
                fontSize: 10,
                letterSpacing: 1.1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              application.message,
              style: const TextStyle(
                color: Color(0xFF304766),
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            if (application.status == ApplicationStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showApplicantProfile(application),
                      icon: const Icon(Icons.person_outline, size: 16),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Ver perfil', maxLines: 1),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _updateApplication(
                        application,
                        ApplicationStatus.accepted,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 17),
                            SizedBox(width: 4),
                            Text('Aceptar', maxLines: 1),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateApplication(
                        application,
                        ApplicationStatus.rejected,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB42318),
                        side: const BorderSide(color: Color(0xFFFF8A8A)),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Rechazar', maxLines: 1),
                      ),
                    ),
                  ),
                ],
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: _tag(
                  application.status == ApplicationStatus.accepted
                      ? 'MATCH ACEPTADO'
                      : 'POSTULACIÓN RECHAZADA',
                  application.status == ApplicationStatus.accepted
                      ? const Color(0xFFD9F8E7)
                      : const Color(0xFFFDE2E1),
                  application.status == ApplicationStatus.accepted
                      ? const Color(0xFF0C8A4B)
                      : const Color(0xFFB42318),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showApplicantProfile(InitiativeApplication application) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(application.applicantName),
        content: Text(
          '${application.program} · ${application.semester}\n\nHabilidades: ${application.skills}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _updateApplication(
    InitiativeApplication application,
    ApplicationStatus status,
  ) {
    setState(() => application.status = status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == ApplicationStatus.accepted
              ? 'Postulación aceptada. ¡Hicieron match!'
              : 'Postulación rechazada.',
        ),
      ),
    );
  }

  Widget _header() => Container(
    width: double.infinity,
    color: AppTheme.navy,
    padding: const EdgeInsets.fromLTRB(16, 28, 16, 18),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UNIVERSIDAD DEL NORTE',
          style: TextStyle(
            color: Color(0xFFD8E4F7),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.7,
          ),
        ),
        SizedBox(height: 7),
        Text(
          'Sistema de Innovación',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  Widget _intro(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explora proyectos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 3),
            Text(
              '3 iniciativas activas',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ],
        ),
      ),
      ElevatedButton.icon(
        onPressed: () async {
          final initiative = await Navigator.push<Initiative>(
            context,
            MaterialPageRoute(builder: (_) => const PublishInitiativePage()),
          );
          if (initiative != null && mounted) {
            setState(() => myInitiatives.add(initiative));
          }
        },
        icon: const Icon(Icons.add, size: 17),
        label: const Text('Publicar proyecto'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.navy,
          foregroundColor: Colors.white,
        ),
      ),
    ],
  );

  Widget _filters() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: filters.map((filter) {
        final selected = selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) => setState(() => selectedFilter = filter),
            selectedColor: AppTheme.navy,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppTheme.navy,
              fontSize: 11,
            ),
            side: BorderSide(
              color: selected ? AppTheme.navy : const Color(0xFFC7D2E2),
            ),
            showCheckmark: false,
          ),
        );
      }).toList(),
    ),
  );

  Widget _initiativeCard(
    BuildContext context,
    Initiative initiative, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) => Card(
    elevation: 0,
    margin: EdgeInsets.zero,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: const BorderSide(color: AppTheme.navy),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_applicationCountFor(initiative) > 3)
                _tag('MÁS POPULAR', const Color(0xFFE8530A), Colors.white),
              const Spacer(),
              if (onDelete != null)
                IconButton(
                  onPressed: onEdit,
                  tooltip: 'Editar proyecto',
                  icon: const Icon(Icons.edit_outlined),
                  color: AppTheme.navy,
                  visualDensity: VisualDensity.compact,
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Eliminar iniciativa',
                  icon: const Icon(Icons.delete_outline),
                  color: const Color(0xFFB42318),
                  visualDensity: VisualDensity.compact,
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: () => setState(
                    () => initiative.isPopularManually =
                        !initiative.isPopularManually,
                  ),
                  tooltip: initiative.isPopularManually
                      ? 'Quitar marca de popular'
                      : 'Marcar como popular',
                  icon: Icon(
                    initiative.isPopularManually
                        ? Icons.star
                        : Icons.star_border,
                  ),
                  color: const Color(0xFFE8530A),
                  visualDensity: VisualDensity.compact,
                ),
              IconButton(
                onPressed: () => setState(() {
                  if (savedInitiativeIds.contains(initiative.id)) {
                    savedInitiativeIds.remove(initiative.id);
                  } else {
                    savedInitiativeIds.add(initiative.id);
                  }
                }),
                tooltip: savedInitiativeIds.contains(initiative.id)
                    ? 'Quitar de guardados'
                    : 'Guardar iniciativa',
                icon: Icon(
                  savedInitiativeIds.contains(initiative.id)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                color: AppTheme.navy,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  initiative.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (initiative.isActive)
                _tag(
                  'Activa',
                  const Color(0xFFD9F8E7),
                  const Color(0xFF0C8A4B),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: initiative.categories
                .map(
                  (category) => _tag(
                    category,
                    const Color(0xFFF1F4F8),
                    AppTheme.navy,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 11),
          Text(
            initiative.description,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${initiative.views} ${initiative.views == 1 ? 'visita' : 'visitas'}',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
          ),
          const SizedBox(height: 10),
          const Text(
            'ROLES DISPONIBLES',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          ...initiative.roles.map(
            (role) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  _tag(
                    role.name,
                    const Color(0xFFE8D9FF),
                    const Color(0xFF7C3AED),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      role.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InitiativeDetailPage(
                          initiative: initiative,
                          applications: applications
                              .where((item) => item.initiativeId == initiative.id)
                              .toList(),
                          onApplicationSubmitted: (application) => setState(
                            () => applications.add(application),
                          ),
                        ),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navy,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ver iniciativa'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InitiativeDetailPage(
                          initiative: initiative,
                          applications: applications
                              .where((item) => item.initiativeId == initiative.id)
                              .toList(),
                          onApplicationSubmitted: (application) => setState(
                            () => applications.add(application),
                          ),
                        ),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.navy,
                    side: const BorderSide(color: AppTheme.navy),
                  ),
                  child: const Text('Postularme'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _tag(String text, Color background, Color foreground) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(text, style: TextStyle(color: foreground, fontSize: 10)),
  );

  Future<void> _deleteInitiative(Initiative initiative) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar iniciativa'),
        content: Text('¿Quieres eliminar "${initiative.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      setState(
        () => myInitiatives.removeWhere((item) => item.id == initiative.id),
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Iniciativa eliminada.')));
    }
  }

  Future<void> _editInitiative(Initiative initiative) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublishInitiativePage(initiative: initiative),
      ),
    );
    if (mounted) setState(() {});
  }
}
