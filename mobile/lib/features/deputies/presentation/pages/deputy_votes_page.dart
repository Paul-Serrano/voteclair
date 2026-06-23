import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeputyVotesPage extends StatelessWidget {
  const DeputyVotesPage({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Votes du depute'),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go('/deputies/$slug');
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Ecran des votes a venir pour: $slug'),
      ),
    );
  }
}
