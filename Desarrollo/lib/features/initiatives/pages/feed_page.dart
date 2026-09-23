import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/initiative.dart';
import '../../profile/data/auth_repository.dart';
import '../../profile/pages/profile_page.dart';
import '../data/initiative_repository.dart';
import 'initiative_pages.dart';

class FeedPage extends StatefulWidget {
  final ProfileUser? initialUser;

  const FeedPage({super.key, this.initialUser});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  String selectedFilter = 'Todos';
  int selectedTab = 0;
  final _initiativeRepository = InitiativeRepository();
  final _authRepository = AuthRepository();
  List<Initiative> initiatives = [];
  final Set<String> savedInitiativeIds = {};
  ProfileUser? currentUser;
  final List<InitiativeApplication> applications = [];
  bool isLoading = true;
  String? loadError;

  List<Initiative> get myInitiatives =>
      initiatives.where((initiative) => initiative.isMine).toList();

  @override
  void initState() {
    super.initState();
    currentUser = widget.initialUser;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });
    try {
      final loadedInitiatives = await _initiativeRepository.fetchInitiatives();
      final loadedApplications = await _initiativeRepository.fetchApplications();
      if (!mounted) return;
      setState(() {
        initiatives = loadedInitiatives;
        applications
          ..clear()
          ..addAll(loadedApplications);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loadError = 'No se pudieron cargar las iniciativas. $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  bool _requireLogin(String action) {
    if (currentUser != null) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inicia sesión para $action.'),
        action: SnackBarAction(
          label: 'Entrar',
          onPressed: () => _openAuth(false),
        ),
      ),
    );
    return false;
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error con Roble: $error')),
    );
  }

  Future<void> _submitApplication(InitiativeApplication application) async {
    if (!_requireLogin('postularte')) return;
    try {
      final saved = await _initiativeRepository.createApplication(application);
      if (mounted) setState(() => applications.add(saved));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _openDetail(Initiative initiative) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InitiativeDetailPage(
          initiative: initiative,
          applications: applications
              .where((item) => item.initiativeId == initiative.id)
              .toList(),
          onApplicationSubmitted: _submitApplication,
        ),
      ),
    );
    _initiativeRepository.saveViews(initiative);
    if (mounted) setState(() {});
  }

  final filters = const [
    'Todos',
    'Diseñador UX/UI',
    'Desarrollador Frontend',
    'Ingeniería',
  ];

  List<Initiative> get allInitiatives => initiatives;

  List<Initiative> get visibleInitiatives {
    if (selectedFilter == 'Todos') return allInitiatives;
    return allInitiatives.where((initiative) {
      return initiative.categories.contains(selectedFilter) ||
          initiative.roles.any((role) => role.name == selectedFilter);
    }).toList();
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

    return ProfilePage(
      user: currentUser,
      onLogin: () => _openAuth(false),
      onRegister: () => _openAuth(true),
      onLogout: () async {
        await _authRepository.logout();
        if (!mounted) return;
        setState(() => currentUser = null);
        _loadData();
      },
    );
  }

  Future<void> _openAuth(bool startInRegisterMode) async {
    final user = await Navigator.push<ProfileUser>(
      context,
      MaterialPageRoute(
        builder: (_) => AuthPage(
          startInRegisterMode: startInRegisterMode,
          onSubmit: _authenticate,
        ),
      ),
    );
    if (user != null && mounted) {
      setState(() => currentUser = user);
      _loadData();
    }
  }

  Future<AuthResult> _authenticate({
    required bool isRegistering,
    required String name,
    required String email,
    required String program,
    required String semester,
    required String password,
  }) async {
    if (isRegistering) {
      return _authRepository.register(
        name: name,
        email: email,
        program: program,
        semester: semester,
        password: password,
      );
    }
    return _authRepository.login(email: email, password: password);
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
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              _intro(context),
              const SizedBox(height: 14),
              _filters(),
              const SizedBox(height: 18),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!isLoading && loadError != null)
                Column(
                  children: [
                    Text(
                      loadError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFB42318)),
                    ),
                    TextButton(
                      onPressed: _loadData,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              if (!isLoading && loadError == null && visibleInitiatives.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Aún no hay iniciativas publicadas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              ...visibleInitiatives.map(
                (initiative) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _initiativeCard(context, initiative),
                ),
              ),
            ],
          ),
          ),
        ),
      ],
    );
  }

  List<InitiativeApplication> get receivedApplications {
    final myIds = myInitiatives.map((initiative) => initiative.id).toSet();
    return applications
        .where((item) => myIds.contains(item.initiativeId) && !item.isMine)
        .toList();
  }

  Widget _applicationsSection() {
    final received = receivedApplications;
    if (received.isEmpty) return const SizedBox.shrink();

    final pendingApplications = received
        .where((item) => item.status == ApplicationStatus.pending)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Postulaciones recibidas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3),
        Text(
          '$pendingApplications pendientes · ${received.length} en total',
          style: const TextStyle(color: Color(0xFF52627A), fontSize: 12),
        ),
        const SizedBox(height: 12),
        ...received.map((application) {
          final initiative = initiatives
              .where((item) => item.id == application.initiativeId)
              .firstOrNull;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (initiative != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          initiative.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _tag(
                        'Mi iniciativa',
                        const Color(0xFFE7EEF8),
                        AppTheme.navy,
                      ),
                    ],
                  ),
                ),
              _applicationCard(application),
            ],
          );
        }),
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

  Future<void> _updateApplication(
    InitiativeApplication application,
    ApplicationStatus status,
  ) async {
    try {
      await _initiativeRepository.updateApplicationStatus(application, status);
    } catch (e) {
      _showError(e);
      return;
    }
    if (!mounted) return;
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
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Explora proyectos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(
              '${allInitiatives.where((i) => i.isActive).length} iniciativas activas',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ],
        ),
      ),
      ElevatedButton.icon(
        onPressed: () async {
          if (!_requireLogin('publicar un proyecto')) return;
          final initiative = await Navigator.push<Initiative>(
            context,
            MaterialPageRoute(
              builder: (_) => PublishInitiativePage(
                leaderName: currentUser?.name ?? 'Tú',
              ),
            ),
          );
          if (initiative == null || !mounted) return;
          try {
            final saved = await _initiativeRepository.createInitiative(
              initiative,
            );
            if (mounted) setState(() => initiatives.add(saved));
          } catch (e) {
            _showError(e);
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
              if (initiative.isPopular)
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
                  onPressed: () => _openDetail(initiative),
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
                  onPressed: () => _openDetail(initiative),
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
      try {
        await _initiativeRepository.deleteInitiative(initiative);
      } catch (e) {
        _showError(e);
        return;
      }
      if (!mounted) return;
      setState(
        () => initiatives.removeWhere((item) => item.id == initiative.id),
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Iniciativa eliminada.')));
    }
  }

  Future<void> _editInitiative(Initiative initiative) async {
    final edited = await Navigator.push<Initiative>(
      context,
      MaterialPageRoute(
        builder: (_) => PublishInitiativePage(initiative: initiative),
      ),
    );
    if (edited != null) {
      try {
        await _initiativeRepository.updateInitiative(edited);
      } catch (e) {
        _showError(e);
      }
    }
    if (mounted) setState(() {});
  }
}
