import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_bottom_navigation.dart';
import '../../../core/widgets/navigation_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VoteClair')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'VoteClair',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Base Flutter prête: navigation, thème et architecture.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          NavigationTile(
            title: 'Deputes',
            subtitle: 'Acceder a la liste des deputes',
            icon: Icons.how_to_vote_outlined,
            onTap: () => context.go('/deputies'),
          ),
          const SizedBox(height: 12),
          NavigationTile(
            title: 'Scrutins',
            subtitle: 'Acceder a la liste des scrutins',
            icon: Icons.ballot_outlined,
            onTap: () => context.go('/scrutins'),
          ),
          const SizedBox(height: 12),
          NavigationTile(
            title: 'Rechercher',
            subtitle: 'Trouver un depute, un groupe ou un scrutin',
            icon: Icons.search,
            onTap: () => context.go('/search'),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }
}
