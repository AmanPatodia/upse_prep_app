import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  DateTime? _lastBackPressAt;

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

  Future<void> _handleBackPress() async {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }

    final now = DateTime.now();
    final shouldShowHint =
        _lastBackPressAt == null ||
        now.difference(_lastBackPressAt!) > const Duration(seconds: 2);

    if (shouldShowHint) {
      _lastBackPressAt = now;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
            final slide = Tween<Offset>(
              begin: const Offset(0.015, 0),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(widget.navigationShell.currentIndex),
            child: widget.navigationShell,
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          destinations: _items,
          onDestinationSelected:
              (index) =>
                  widget.navigationShell.goBranch(index, initialLocation: false),
        ),
      ),
    );
  }
}
