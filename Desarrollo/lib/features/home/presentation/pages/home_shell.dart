import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/pages/profile_page.dart';
import '../../../initiatives/presentation/pages/explore_page.dart';
import '../../../initiatives/presentation/pages/my_initiatives_page.dart';
import '../../../initiatives/presentation/pages/saved_page.dart';
import '../providers/home_tab_controller.dart';
import 'home_tab.dart';

/// Contenedor principal con la barra de navegación inferior.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static const _pages = <Widget>[
    HomeTab(),
    ExplorePage(),
    MyInitiativesPage(),
    SavedPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = context.watch<HomeTabController>();

    return Scaffold(
      body: IndexedStack(index: tabs.index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabs.index,
        onDestinationSelected: tabs.go,
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
            icon: Icon(Icons.rocket_launch_outlined),
            selectedIcon: Icon(Icons.rocket_launch),
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
}
