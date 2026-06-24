import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../providers/favorites_activity_provider.dart';
import '../widgets/activity_card.dart';

class FavoritesActivityPage extends ConsumerWidget {
  const FavoritesActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slugsAsync = ref.watch(favoriteSlugsNotifierProvider);
    final activitiesAsync = ref.watch(favoritesActivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activité de mes favoris'),
      ),
      body: slugsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _ErrorState(
          message: 'Impossible de charger l\'activité.',
          onRetry: () {
            ref.invalidate(favoriteSlugsNotifierProvider);
            ref.invalidate(favoritesActivityProvider);
          },
        ),
        data: (slugs) {
          if (slugs.isEmpty) {
            return const _InfoState(
              icon: Icons.favorite_border,
              message: 'Ajoutez des députés à vos favoris pour suivre leur activité.',
            );
          }

          return activitiesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _ErrorState(
              message: 'Impossible de charger l\'activité.',
              onRetry: () {
                ref.invalidate(favoritesActivityProvider);
              },
            ),
            data: (items) {
              if (items.isEmpty) {
                return const _InfoState(
                  icon: Icons.history_toggle_off,
                  message: 'Aucune activité récente trouvée.',
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(favoritesActivityProvider);
                  await ref.read(favoritesActivityProvider.future);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ActivityCard(
                      item: item,
                      onTap: () => context.push('/scrutins/${item.latestVote.scrutin.id}'),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }
}

class _InfoState extends StatelessWidget {
  const _InfoState({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
