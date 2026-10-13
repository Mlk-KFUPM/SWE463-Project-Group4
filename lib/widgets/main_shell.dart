import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.add_circle), label: 'Create'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
