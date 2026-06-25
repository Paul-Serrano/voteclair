import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../core/widgets/app_bottom_navigation.dart';
import '../../../core/widgets/scrutin_filter_sort_controls.dart';
import '../domain/entities/scrutin.dart';
import 'providers/scrutins_provider.dart';

class ScrutinsPage extends ConsumerStatefulWidget {
  const ScrutinsPage({super.key});

  @override
  ConsumerState<ScrutinsPage> createState() => _ScrutinsPageState();
}

class _ScrutinsPageState extends ConsumerState<ScrutinsPage> {
  late final ScrollController _scrollController;
  Timer? _searchDebounce;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
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
      ref.read(scrutinsProvider.notifier).loadNextPage();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    setState(() => _searchText = value);

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) {
        return;
      }

      ref.read(scrutinsProvider.notifier).applySearch(_searchText);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scrutinsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scrutins')),
      body: _buildBody(context, state),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildBody(BuildContext context, ScrutinsState state) {
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
              const Text('Impossible de charger les scrutins.'),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(scrutinsProvider.notifier).loadInitial(),
                child: const Text('Reessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(scrutinsProvider.notifier).refresh(),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          SearchBar(
            hintText: 'Rechercher un scrutin',
            leading: const Icon(Icons.search),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
          ScrutinFilterSortControls(
            importanceFilter: state.importanceFilter,
            sortMode: state.sortMode,
            onImportanceChanged: (value) {
              ref.read(scrutinsProvider.notifier).applyImportanceFilter(value);
            },
            onSortModeChanged: (value) {
              ref.read(scrutinsProvider.notifier).applySortMode(value);
            },
          ),
          const SizedBox(height: 16),
          if (state.searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Résultats pour "${state.searchQuery}"',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (state.scrutins.isEmpty)
            const SizedBox(
              height: 160,
              child: Center(child: Text('Aucun scrutin trouve.')),
            )
          else
            ...state.scrutins.expand(
              (scrutin) => [
                _ScrutinListTile(scrutin: scrutin),
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
}

class _ScrutinListTile extends StatelessWidget {
  const _ScrutinListTile({required this.scrutin});

  final Scrutin scrutin;

  @override
  Widget build(BuildContext context) {
    final importance = _importanceConfig(scrutin.importanceScore);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: scrutin.id.isEmpty ? null : () => context.push('/scrutins/${scrutin.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scrutin.titre,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                [
                  if (scrutin.numero != null) 'Scrutin n${scrutin.numero}',
                  scrutin.date ?? 'Date inconnue',
                  scrutin.institution?.nom ?? 'Institution inconnue',
                ].join(' • '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SortBadge(sort: scrutin.sort),
                  Chip(
                    visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: importance.background,
                    side: BorderSide(color: importance.foreground.withValues(alpha: 0.3)),
                    label: Text(
                      importance.label,
                      style: TextStyle(
                        color: importance.foreground,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ({String label, Color background, Color foreground}) _importanceConfig(int score) {
    if (score >= 150) {
      return (
        label: 'Tres important',
        background: const Color(0xFFFFE9C2),
        foreground: const Color(0xFF7A4300),
      );
    }
    if (score >= 100) {
      return (
        label: 'Important',
        background: const Color(0xFFE9F0FF),
        foreground: const Color(0xFF1546A0),
      );
    }

    return (
      label: 'Standard',
      background: const Color(0xFFF1F3F4),
      foreground: const Color(0xFF4B5563),
    );
  }
}

class _SortBadge extends StatelessWidget {
  const _SortBadge({required this.sort});

  final String? sort;

  @override
  Widget build(BuildContext context) {
    final normalized = (sort ?? '').toUpperCase();
    final config = switch (normalized) {
      'ADOPTE' => (
          label: 'Adopté',
          background: const Color(0xFFE6F4EA),
          foreground: const Color(0xFF196C2E),
        ),
      'REJETE' => (
          label: 'Rejeté',
          background: const Color(0xFFFDECEA),
          foreground: const Color(0xFFB42318),
        ),
      _ => (
          label: '-',
          background: Theme.of(context).colorScheme.surfaceContainerHighest,
          foreground: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
    };

    return Chip(
      visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: config.background,
      side: BorderSide(color: config.foreground.withValues(alpha: 0.3)),
      label: Text(
        config.label,
        style: TextStyle(color: config.foreground, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
