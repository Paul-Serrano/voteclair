import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({required this.currentIndex, super.key});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/');
          case 1:
            context.go('/deputies');
          case 2:
            context.go('/scrutins');
          case 3:
            context.go('/groups');
          case 4:
            context.go('/search');
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        NavigationDestination(
          icon: Icon(Icons.how_to_vote_outlined),
          selectedIcon: Icon(Icons.how_to_vote),
          label: 'Deputes',
        ),
        NavigationDestination(
          icon: Icon(Icons.ballot_outlined),
          selectedIcon: Icon(Icons.ballot),
          label: 'Scrutins',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups),
          label: 'Groupes',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search),
          label: 'Recherche',
        ),
      ],
    );
  }
}
