import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../domain/entities/group_summary.dart';
import '../providers/groups_provider.dart';

class GroupsListPage extends ConsumerStatefulWidget {
  const GroupsListPage({super.key});

  @override
  ConsumerState<GroupsListPage> createState() => _GroupsListPageState();
}

class _GroupsListPageState extends ConsumerState<GroupsListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Groupes')),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Impossible de charger les groupes.',
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
                  onPressed: () => ref.invalidate(groupsProvider),
                  child: const Text('Reessayer'),
                ),
              ],
            ),
          ),
        ),
        data: (groups) {
          final filtered = _filteredGroups(groups);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SearchBar(
                hintText: 'Rechercher un groupe',
                leading: const Icon(Icons.search),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                const SizedBox(
                  height: 180,
                  child: Center(child: Text('Aucun groupe trouve.')),
                )
              else
                ...filtered.expand((group) => [
                      _GroupListTile(group: group),
                      const SizedBox(height: 10),
                    ]),
            ],
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }

  List<GroupSummary> _filteredGroups(List<GroupSummary> groups) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return groups;
    }

    return groups.where((group) {
      return group.nom.toLowerCase().contains(query) ||
          group.nomComplet.toLowerCase().contains(query);
    }).toList(growable: false);
  }
}

class _GroupListTile extends StatelessWidget {
  const _GroupListTile({required this.group});

  final GroupSummary group;

  @override
  Widget build(BuildContext context) {
    final color = _toColor(group.couleur);

    return Card(
      child: ListTile(
        onTap: () => context.push('/groups/${group.slug}'),
        leading: CircleAvatar(
          backgroundColor: (color ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.15),
          foregroundImage: _networkImageOrNull(group.logoUrl),
          child: Icon(Icons.groups, color: color ?? Theme.of(context).colorScheme.primary),
        ),
        title: Text(group.nom),
        subtitle: Text('${group.nomComplet}\n${group.membresCount} membres'),
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

  Color? _toColor(String? hex) {
    if (hex == null || hex.trim().isEmpty) {
      return null;
    }

    final normalized = hex.replaceFirst('#', '').trim();
    if (normalized.length != 6) {
      return null;
    }

    final value = int.tryParse('FF$normalized', radix: 16);
    if (value == null) {
      return null;
    }

    return Color(value);
  }
}
