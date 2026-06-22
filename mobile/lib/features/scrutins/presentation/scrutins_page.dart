import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_bottom_navigation.dart';

class ScrutinsPage extends StatelessWidget {
  const ScrutinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scrutins')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Liste des scrutins (placeholder sprint 02).'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.push('/scrutins/exemple-id'),
            child: const Text('Ouvrir un detail exemple'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/'),
            child: const Text('Retour accueil'),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }
}
