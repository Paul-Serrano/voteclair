import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../core/widgets/app_bottom_navigation.dart';
import '../../groups/domain/entities/group_summary.dart';
import '../../groups/presentation/providers/groups_provider.dart';
import '../domain/entities/deputy.dart';
import 'providers/deputies_provider.dart';

class DeputiesListPage extends ConsumerStatefulWidget {
  const DeputiesListPage({super.key});

  @override
  ConsumerState<DeputiesListPage> createState() => _DeputiesListPageState();
}

class _DeputiesListPageState extends ConsumerState<DeputiesListPage> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  Timer? _searchDebounce;
  _DeputySort _sort = _DeputySort.name;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _searchController = TextEditingController(
      text: ref.read(deputiesProvider).searchQuery,
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.extentAfter < 300) {
      ref.read(deputiesProvider.notifier).loadNextPage();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) {
        return;
      }

      ref.read(deputiesProvider.notifier).applySearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deputiesProvider);

    if (_searchController.text != state.searchQuery) {
      _searchController.value = TextEditingValue(
        text: state.searchQuery,
        selection: TextSelection.collapsed(offset: state.searchQuery.length),
      );
    }

    final groupsAsync = ref.watch(groupsProvider);
    final groups = groupsAsync.maybeWhen(
      data: _groupFiltersFromSummaries,
      orElse: () => _groupFiltersFromDeputies(state.deputies),
    );
    final sortedDeputies = _sortedDeputies(state.deputies);

    return Scaffold(
      appBar: AppBar(title: const Text('Deputes')),
      body: _buildBody(context, state, groups, sortedDeputies),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DeputiesState state,
    List<_GroupFilterItem> groups,
    List<Deputy> sortedDeputies,
  ) {
    if (state.isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && !state.hasInitialData) {
      return Center(
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
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(deputiesProvider.notifier).loadInitial(),
                child: const Text('Reessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(deputiesProvider.notifier).refresh(),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          SearchBar(
            controller: _searchController,
            hintText: 'Rechercher un depute',
            leading: const Icon(Icons.search),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
          if (state.searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Résultats pour "${state.searchQuery}"',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Text(
            'Trier',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Nom'),
                selected: _sort == _DeputySort.name,
                onSelected: (_) => setState(() => _sort = _DeputySort.name),
              ),
              ChoiceChip(
                label: const Text('Presence +'),
                selected: _sort == _DeputySort.presenceDesc,
                onSelected: (_) => setState(() => _sort = _DeputySort.presenceDesc),
              ),
              ChoiceChip(
                label: const Text('Presence -'),
                selected: _sort == _DeputySort.presenceAsc,
                onSelected: (_) => setState(() => _sort = _DeputySort.presenceAsc),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Filtrer par groupe parlementaire',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Tous'),
                selected: state.selectedGroup.isEmpty,
                onSelected: (_) => ref.read(deputiesProvider.notifier).applyGroupFilter(''),
              ),
              ...groups.map(
                (group) => ChoiceChip(
                  avatar: _GroupColorDot(colorHex: group.color),
                  label: Text(group.name),
                  selected: state.selectedGroup == group.slug,
                  onSelected: (_) => ref.read(deputiesProvider.notifier).applyGroupFilter(group.slug),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sortedDeputies.isEmpty)
            const SizedBox(
              height: 180,
              child: Center(child: Text('Aucun depute trouve.')),
            )
          else
            ...sortedDeputies.expand(
              (deputy) => [
                _DeputyListTile(deputy: deputy),
                const SizedBox(height: 10),
              ],
            ),
          if (state.isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  List<_GroupFilterItem> _groupFiltersFromDeputies(List<Deputy> deputies) {
    final bySlug = <String, _GroupFilterItem>{};

    for (final deputy in deputies) {
      final slug = (deputy.groupSlug ?? '').trim();
      final name = (deputy.groupName ?? '').trim();
      if (slug.isEmpty || name.isEmpty) {
        continue;
      }
      bySlug.putIfAbsent(slug, () => _GroupFilterItem(slug: slug, name: name, color: deputy.groupColor));
    }

    final values = bySlug.values.toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));
    return values;
  }

  List<_GroupFilterItem> _groupFiltersFromSummaries(List<GroupSummary> groups) {
    final values = groups
        .map(
          (group) => _GroupFilterItem(
            slug: group.slug,
            name: group.nom,
            color: group.couleur,
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => a.name.compareTo(b.name));
    return values;
  }

  List<Deputy> _sortedDeputies(List<Deputy> deputies) {
    final sorted = List<Deputy>.from(deputies);

    if (_sort == _DeputySort.presenceDesc) {
      sorted.sort((a, b) {
        final aPresence = a.statsPresence ?? -1;
        final bPresence = b.statsPresence ?? -1;
        final comparePresence = bPresence.compareTo(aPresence);
        if (comparePresence != 0) {
          return comparePresence;
        }
        return a.nom.compareTo(b.nom);
      });
      return sorted;
    }

    if (_sort == _DeputySort.presenceAsc) {
      sorted.sort((a, b) {
        final aPresence = a.statsPresence ?? 101;
        final bPresence = b.statsPresence ?? 101;
        final comparePresence = aPresence.compareTo(bPresence);
        if (comparePresence != 0) {
          return comparePresence;
        }
        return a.nom.compareTo(b.nom);
      });
      return sorted;
    }

    sorted.sort((a, b) {
      final compareNom = a.nom.compareTo(b.nom);
      if (compareNom != 0) {
        return compareNom;
      }
      return a.prenom.compareTo(b.prenom);
    });
    return sorted;
  }
}

enum _DeputySort {
  name,
  presenceDesc,
  presenceAsc,
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(deputy.prenom),
            const SizedBox(height: 2),
            Row(
              children: [
                _GroupColorDot(colorHex: deputy.groupColor),
                const SizedBox(width: 6),
                Expanded(child: Text(deputy.groupName ?? 'Groupe inconnu')),
              ],
            ),
          ],
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

class _GroupFilterItem {
  const _GroupFilterItem({required this.slug, required this.name, this.color});

  final String slug;
  final String name;
  final String? color;
}

class _GroupColorDot extends StatelessWidget {
  const _GroupColorDot({required this.colorHex});

  final String? colorHex;

  @override
  Widget build(BuildContext context) {
    final color = _toColor(colorHex) ?? Theme.of(context).colorScheme.outline;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
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
