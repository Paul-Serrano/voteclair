import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScrutinDetailPage extends StatelessWidget {
  const ScrutinDetailPage({required this.scrutinId, super.key});

  final String scrutinId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail scrutin'),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go('/scrutins');
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Detail scrutin pour id: $scrutinId'),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/scrutins'),
            child: const Text('Retour scrutins'),
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
