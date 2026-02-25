import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.track_changes_outlined),
      label: 'Prelims',
    ),
    NavigationDestination(icon: Icon(Icons.edit_note_outlined), label: 'Mains'),
    NavigationDestination(
      icon: Icon(Icons.newspaper_outlined),
      label: 'Current',
    ),
    NavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      label: 'Analytics',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: _items,
        onDestinationSelected:
            (index) => navigationShell.goBranch(index, initialLocation: true),
      ),
    );
  }
}
