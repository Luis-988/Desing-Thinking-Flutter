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

  final filters = const [
    'Todos',
    'Diseñador UX/UI',
    'Desarrollador Frontend',
    'Ingeniería',
  ];

  List<Initiative> get visibleInitiatives {
    if (selectedFilter == 'Todos') return widget.initiatives;
    return widget.initiatives.where((initiative) {
      return initiative.category == selectedFilter ||
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

    final pages = [
      (
        'Mis iniciativas',
        Icons.article_outlined,
        'Aquí aparecerán las iniciativas que publiques.',
      ),
      (
        'Guardados',
        Icons.bookmark_border,
        'Aquí aparecerán tus iniciativas guardadas.',
      ),
      ('Perfil', Icons.person_outline, 'Tu perfil de innovación estará aquí.'),
    ];
    final page = pages[selectedTab - 2];

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
              'Explora iniciativas',
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PublishInitiativePage()),
        ),
        icon: const Icon(Icons.add, size: 17),
        label: const Text('Publicar'),
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

  Widget _initiativeCard(BuildContext context, Initiative initiative) => Card(
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
              if (initiative.isFeatured)
                _tag('DESTACADA', const Color(0xFFE8530A), Colors.white),
              const Spacer(),
              const Icon(Icons.bookmark_border, color: AppTheme.navy, size: 20),
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
          _tag(initiative.category, const Color(0xFFF1F4F8), AppTheme.navy),
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
                  const Spacer(),
                  Text(
                    '${role.availablePlaces} ${role.availablePlaces == 1 ? 'plaza' : 'plazas'}',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 10,
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          InitiativeDetailPage(initiative: initiative),
                    ),
                  ),
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
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecciona un rol para postularte.'),
                    ),
                  ),
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
}
