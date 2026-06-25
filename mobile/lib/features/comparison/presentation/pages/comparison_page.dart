import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/widgets/scrutin_filter_sort_controls.dart';
import '../../../search/domain/entities/search_results.dart';
import '../../../search/presentation/widgets/search_bar.dart';
import '../../domain/entities/deputy_comparison.dart';
import '../providers/comparison_provider.dart';
import '../widgets/comparison_difference_tile.dart';
import '../widgets/comparison_summary_card.dart';

enum _ComparisonVoteScope {
  allCommon,
  disagreements,
}

class ComparisonPage extends ConsumerStatefulWidget {
  const ComparisonPage({
    this.initialLeftSlug,
    this.initialLeftPrenom,
    this.initialLeftNom,
    this.initialLeftGroup,
    super.key,
  });

  final String? initialLeftSlug;
  final String? initialLeftPrenom;
  final String? initialLeftNom;
  final String? initialLeftGroup;

  @override
  ConsumerState<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends ConsumerState<ComparisonPage> {
  bool _initializedFromRoute = false;
  _ComparisonVoteScope _voteScope = _ComparisonVoteScope.disagreements;
  ScrutinImportanceFilter _importanceFilter = ScrutinImportanceFilter.all;
  ScrutinSortMode _sortMode = ScrutinSortMode.importanceDesc;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _initializedFromRoute) {
        return;
      }

      final slug = widget.initialLeftSlug?.trim() ?? '';
      if (slug.isNotEmpty) {
        final prenom = (widget.initialLeftPrenom?.trim().isNotEmpty ?? false)
            ? widget.initialLeftPrenom!.trim()
            : slug;
        final nom = widget.initialLeftNom?.trim() ?? '';
        final group = widget.initialLeftGroup?.trim();

        ref.read(comparisonProvider.notifier).setLeftDeputy(
              SearchDeputyResult(
                slug: slug,
                prenom: prenom,
                nom: nom,
                group: (group == null || group.isEmpty) ? null : group,
              ),
            );
      }

      _initializedFromRoute = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comparisonProvider);
    final selectedVotes = switch (_voteScope) {
      _ComparisonVoteScope.allCommon => state.result?.recentCommonVotes ?? const <ComparisonDifference>[],
      _ComparisonVoteScope.disagreements => state.result?.recentDifferences ?? const <ComparisonDifference>[],
    };

    final filteredSortedVotes = _applyDifferenceFilterAndSort(
      selectedVotes,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Comparer deux deputes')),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DeputyPickerCard(
            title: 'Depute A',
            selectedDeputy: state.leftDeputy,
            onTap: () async {
              final selected = await showModalBottomSheet<SearchDeputyResult>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const _DeputyPickerSheet(),
              );

              if (selected != null) {
                ref.read(comparisonProvider.notifier).setLeftDeputy(selected);
              }
            },
          ),
          const SizedBox(height: 12),
          _DeputyPickerCard(
            title: 'Depute B',
            selectedDeputy: state.rightDeputy,
            onTap: () async {
              final selected = await showModalBottomSheet<SearchDeputyResult>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const _DeputyPickerSheet(),
              );

              if (selected != null) {
                ref.read(comparisonProvider.notifier).setRightDeputy(selected);
              }
            },
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: state.leftDeputy != null && state.rightDeputy != null
                ? () => ref.read(comparisonProvider.notifier).swapDeputies()
                : null,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Inverser A/B'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: state.canCompare && !state.isLoading
                ? () => ref.read(comparisonProvider.notifier).compare()
                : null,
            icon: state.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.compare_arrows),
            label: const Text('Comparer'),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              'Erreur: ${state.errorMessage}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (state.result != null) ...[
            const SizedBox(height: 16),
            ComparisonSummaryCard(comparison: state.result!),
            const SizedBox(height: 12),
            DropdownButtonFormField<_ComparisonVoteScope>(
              initialValue: _voteScope,
              decoration: const InputDecoration(
                labelText: 'Afficher',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(
                  value: _ComparisonVoteScope.disagreements,
                  child: Text('Seulement les desaccords'),
                ),
                DropdownMenuItem(
                  value: _ComparisonVoteScope.allCommon,
                  child: Text('Tous les scrutins communs'),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() => _voteScope = value);
              },
            ),
            const SizedBox(height: 12),
            ScrutinFilterSortControls(
              importanceFilter: _importanceFilter,
              sortMode: _sortMode,
              onImportanceChanged: (value) => setState(() => _importanceFilter = value),
              onSortModeChanged: (value) => setState(() => _sortMode = value),
            ),
            const SizedBox(height: 12),
            Text(
              _voteScope == _ComparisonVoteScope.disagreements
                  ? 'Desaccords recents'
                  : 'Scrutins communs recents',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (filteredSortedVotes.isEmpty)
              const Text('Aucun scrutin ne correspond au filtre.'),
            ...filteredSortedVotes.map(
              (difference) => ComparisonDifferenceTile(
                difference: difference,
                leftName: state.result!.left.fullName,
                rightName: state.result!.right.fullName,
                onTap: () => context.push('/scrutins/${difference.scrutinId}'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<ComparisonDifference> _applyDifferenceFilterAndSort(
    List<ComparisonDifference> values,
  ) {
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
}

class _DeputyPickerCard extends StatelessWidget {
  const _DeputyPickerCard({
    required this.title,
    required this.onTap,
    this.selectedDeputy,
  });

  final String title;
  final VoidCallback onTap;
  final SearchDeputyResult? selectedDeputy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(title),
        subtitle: Text(
          selectedDeputy == null
              ? 'Selectionner un depute'
              : '${selectedDeputy!.fullName} (${selectedDeputy!.group ?? 'Groupe inconnu'})',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _DeputyPickerSheet extends ConsumerStatefulWidget {
  const _DeputyPickerSheet();

  @override
  ConsumerState<_DeputyPickerSheet> createState() => _DeputyPickerSheetState();
}

class _DeputyPickerSheetState extends ConsumerState<_DeputyPickerSheet> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(deputySearchProvider(_query));

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              GlobalSearchBar(
                controller: _controller,
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _query.trim().isEmpty
                    ? const Center(child: Text('Tapez un nom de depute.'))
                    : resultsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(child: Text('Erreur: $error')),
                        data: (items) {
                          if (items.isEmpty) {
                            return const Center(child: Text('Aucun depute trouve.'));
                          }

                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return ListTile(
                                title: Text(item.fullName),
                                subtitle: Text(item.group ?? 'Groupe inconnu'),
                                onTap: () => Navigator.of(context).pop(item),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
