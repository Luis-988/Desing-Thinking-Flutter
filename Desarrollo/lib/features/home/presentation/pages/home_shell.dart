import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../initiatives/presentation/pages/explore_page.dart';
import '../../../initiatives/presentation/pages/my_initiatives_page.dart';
import '../../../initiatives/presentation/pages/community_feed_page.dart';
import '../../../initiatives/presentation/pages/saved_page.dart';
import '../providers/home_tab_controller.dart';
import 'home_tab.dart';
import '../../../initiatives/presentation/providers/public_feed_controller.dart';

/// Contenedor principal con la barra de navegación inferior.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static const _pages = <Widget>[
    HomeTab(),
    ExplorePage(),
    MyInitiativesPage(),
    CommunityFeedPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = context.watch<HomeTabController>();
    final selectedIndex = switch (tabs.index) {
      HomeTabs.home => 0,
      HomeTabs.explore => 1,
      HomeTabs.community => 2,
      HomeTabs.profile => 3,
      _ => 0,
    };

    return Scaffold(
      drawer: _AppDrawer(onNavigate: tabs.go),
      body: IndexedStack(index: tabs.index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          final destination = switch (index) {
            0 => HomeTabs.home,
            1 => HomeTabs.explore,
            2 => HomeTabs.community,
            _ => HomeTabs.profile,
          };
          tabs.go(destination);
          if (destination == HomeTabs.community) {
            context.read<PublicFeedController>().load();
          }
        },
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
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Comunidad',
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
}

class _AppDrawer extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const _AppDrawer({required this.onNavigate});

  void _go(BuildContext context, int destination) {
    Navigator.pop(context);
    onNavigate(destination);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 20, 24),
              color: AppColors.navy,
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.white, size: 30),
                  SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Innovación Uninorte',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.rocket_launch_outlined),
              title: const Text('Mis iniciativas'),
              onTap: () => _go(context, HomeTabs.myInitiatives),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('Guardados'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: SavedPage()),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Perfil'),
              onTap: () => _go(context, HomeTabs.profile),
            ),
          ],
        ),
      ),
    );
  }
}
