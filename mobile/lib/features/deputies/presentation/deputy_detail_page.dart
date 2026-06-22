import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeputyDetailPage extends StatelessWidget {
  const DeputyDetailPage({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail depute'),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go('/deputies');
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Detail depute pour slug: $slug'),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/deputies'),
            child: const Text('Retour deputes'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.go('/'),
            child: const Text('Retour accueil'),
          ),
        ],
      ),
    );
  }
}
