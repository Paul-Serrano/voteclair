import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/scrutin_filter_sort_controls.dart';
import '../../domain/entities/search_results.dart';
import '../providers/search_provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/search_result_tile.dart';
import '../widgets/search_section.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recherche')),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 4),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlobalSearchBar(
            controller: _controller,
            onChanged: (value) => ref.read(searchProvider.notifier).onQueryChanged(value),
          ),
          const SizedBox(height: 16),
          if (state.isIdle)
            const _InfoMessage(text: 'Commencez votre recherche.')
          else if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (state.errorMessage != null)
            _InfoMessage(text: 'Erreur: ${state.errorMessage}')
          else if (state.results.isEmpty)
            const _InfoMessage(text: 'Aucun résultat trouvé.')
          else
            _ResultsView(results: state.results),
        ],
      ),
    );
  }
}

class _ResultsView extends StatefulWidget {
  const _ResultsView({required this.results});

  final SearchResults results;

  @override
  State<_ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<_ResultsView> {
  ScrutinImportanceFilter _importanceFilter = ScrutinImportanceFilter.all;
  ScrutinSortMode _sortMode = ScrutinSortMode.numeroDesc;

  @override
  Widget build(BuildContext context) {
    final filteredSortedScrutins = _applyScrutinFilterAndSort(widget.results.scrutins);

    return Column(
      children: [
        SearchSection(
          title: 'Députés',
          children: widget.results.deputies
              .map(
                (item) => SearchResultTile(
                  title: item.fullName,
                  subtitle: item.group ?? 'Groupe inconnu',
                  leading: CircleAvatar(
                    foregroundImage: _networkImageOrNull(item.photoUrl),
                    child: const Icon(Icons.person_outline),
                  ),
                  onTap: () => context.push('/deputies/${item.slug}'),
                ),
              )
              .toList(growable: false),
        ),
        SearchSection(
          title: 'Groupes',
          children: widget.results.groups
              .map(
                (item) => SearchResultTile(
                  title: item.nom,
                  subtitle: '${item.membersCount} membres',
                  leading: _GroupColorDot(couleur: item.couleur),
                  onTap: () => context.push('/groups/${item.slug}'),
                ),
              )
              .toList(growable: false),
        ),
        SearchSection(
          title: 'Scrutins',
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ScrutinFilterSortControls(
                importanceFilter: _importanceFilter,
                sortMode: _sortMode,
                onImportanceChanged: (value) => setState(() => _importanceFilter = value),
                onSortModeChanged: (value) => setState(() => _sortMode = value),
              ),
            ),
            ...filteredSortedScrutins
              .map(
                (item) => SearchResultTile(
                  title: item.titre,
                  subtitle: 'n${item.numero} • ${item.date ?? '-'} • ${_sortLabel(item.sort)} • ${_importanceLabel(item.importanceScore)}',
                  onTap: () => context.push('/scrutins/${item.id}'),
                ),
              ),
          ],
        ),
      ],
    );
  }

  List<SearchScrutinResult> _applyScrutinFilterAndSort(List<SearchScrutinResult> values) {
    final filtered = values.where((item) {
      return switch (_importanceFilter) {
        ScrutinImportanceFilter.all => true,
        ScrutinImportanceFilter.important => item.importanceScore >= 100,
        ScrutinImportanceFilter.veryImportant => item.importanceScore >= 150,
      };
    }).toList(growable: false);

    final sorted = [...filtered];
    sorted.sort((a, b) {
      return switch (_sortMode) {
        ScrutinSortMode.numeroAsc => a.numero.compareTo(b.numero),
        ScrutinSortMode.numeroDesc => b.numero.compareTo(a.numero),
        ScrutinSortMode.importanceAsc => a.importanceScore.compareTo(b.importanceScore),
        ScrutinSortMode.importanceDesc => b.importanceScore.compareTo(a.importanceScore),
      };
    });

    return sorted;
  }

  ImageProvider<Object>? _networkImageOrNull(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    return NetworkImage(url);
  }

  String _sortLabel(String? sort) {
    switch ((sort ?? '').toUpperCase()) {
      case 'ADOPTE':
        return 'Adopté';
      case 'REJETE':
        return 'Rejeté';
      default:
        return '-';
    }
  }

  String _importanceLabel(int score) {
    if (score >= 150) {
      return 'Tres important';
    }
    if (score >= 100) {
      return 'Important';
    }

    return 'Standard';
  }
}

class _GroupColorDot extends StatelessWidget {
  const _GroupColorDot({required this.couleur});

  final String? couleur;

  @override
  Widget build(BuildContext context) {
    final color = _toColor(couleur) ?? Theme.of(context).colorScheme.outline;

    return CircleAvatar(
      radius: 12,
      backgroundColor: color,
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

class _InfoMessage extends StatelessWidget {
  const _InfoMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
