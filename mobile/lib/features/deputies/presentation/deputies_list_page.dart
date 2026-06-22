import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_bottom_navigation.dart';
import '../domain/entities/deputy.dart';
import 'providers/deputies_provider.dart';

class DeputiesListPage extends ConsumerWidget {
  const DeputiesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deputiesAsync = ref.watch(deputiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Deputes')),
      body: deputiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Impossible de charger les deputes.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(deputiesProvider),
                  child: const Text('Reessayer'),
                ),
              ],
            ),
          ),
        ),
        data: (deputies) {
          if (deputies.isEmpty) {
            return const Center(child: Text('Aucun depute trouve.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: deputies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final deputy = deputies[index];
              return _DeputyListTile(deputy: deputy);
            },
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }
}

class _DeputyListTile extends StatelessWidget {
  const _DeputyListTile({required this.deputy});

  final Deputy deputy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.push('/deputies/${deputy.slug}'),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundImage: _networkImageOrNull(deputy.photoUrl),
          child: const Icon(Icons.person_outline),
        ),
        title: Text(deputy.nom),
        subtitle: Text(
          '${deputy.prenom}\n${deputy.groupName ?? 'Groupe inconnu'}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  ImageProvider<Object>? _networkImageOrNull(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    return NetworkImage(url);
  }
}
