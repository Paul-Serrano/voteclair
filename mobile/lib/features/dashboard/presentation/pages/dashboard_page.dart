import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_group_tile.dart';
import '../widgets/dashboard_scrutin_tile.dart';
import '../widgets/dashboard_stats_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorWidget(context, ref),
        data: (dashboard) => RefreshIndicator(
          onRefresh: () {
            // ignore: unused_result
            ref.refresh(dashboardProvider);
            return Future.value();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'VoteClair',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Comprendre les votes de vos élus.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Search Bar
                      GestureDetector(
                        onTap: () => context.push('/search'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rechercher un député, un groupe...',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Favorites shortcut
                      _FavoritesCard(ref: ref),
                      const SizedBox(height: 20),
                      // Stats Section
                      Text(
                        'Statistiques',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                        children: [
                          DashboardStatsCard(
                            label: 'Députés',
                            value: dashboard.stats.deputies.toString(),
                            icon: Icons.person,
                            color: Colors.blue,
                          ),
                          DashboardStatsCard(
                            label: 'Groupes',
                            value: dashboard.stats.groups.toString(),
                            icon: Icons.groups,
                            color: Colors.purple,
                          ),
                          DashboardStatsCard(
                            label: 'Scrutins',
                            value: dashboard.stats.scrutins.toString(),
                            icon: Icons.how_to_vote,
                            color: Colors.orange,
                          ),
                          DashboardStatsCard(
                            label: 'Votes',
                            value: _formatNumber(dashboard.stats.votes),
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Recent Activity Section
                      if (dashboard.recentActivity.lastScrutinDate != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Activité récente',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dernier scrutin',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      dashboard.recentActivity
                                              .lastScrutinTitle ??
                                          'N/A',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      DateFormat('d MMM yyyy - HH:mm',
                                              'fr_FR')
                                          .format(dashboard
                                              .recentActivity
                                              .lastScrutinDate!),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],
                        ),
                      // Latest Scrutins Section
                      Text(
                        'Derniers scrutins',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (dashboard.latestScrutins.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'Aucun scrutin disponible',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: dashboard.latestScrutins
                              .map((scrutin) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8),
                                    child: DashboardScrutinTile(
                                      scrutin: scrutin,
                                      onTap: () {
                                        context.push('/scrutins/${scrutin.id}');
                                      },
                                    ),
                                  ))
                              .toList(),
                        ),
                      const SizedBox(height: 28),
                      // Top Groups Section
                      Text(
                        'Principaux groupes',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      if (dashboard.topGroups.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'Aucun groupe disponible',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: dashboard.topGroups
                              .map((group) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8),
                                    child: DashboardGroupTile(
                                      group: group,
                                      onTap: () {
                                        context.push('/groups/${group.slug}');
                                      },
                                    ),
                                  ))
                              .toList(),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Impossible de charger les données.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // ignore: unused_result
              ref.refresh(dashboardProvider);
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}

class _FavoritesCard extends ConsumerWidget {
  const _FavoritesCard({required this.ref});

  // ignore: unused_field
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slugsAsync = ref.watch(favoriteSlugsNotifierProvider);
    final count = slugsAsync.value?.length ?? 0;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/favorites'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.favorite, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes députés favoris',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      count == 0
                          ? 'Aucun favori pour l\'instant'
                          : '$count député${count > 1 ? 's' : ''} suivi${count > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
