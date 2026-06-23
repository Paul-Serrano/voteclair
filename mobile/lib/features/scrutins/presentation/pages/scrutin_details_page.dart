import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/scrutin_vote.dart';
import '../providers/scrutin_details_provider.dart';
import '../providers/scrutin_votes_provider.dart';
import '../widgets/scrutin_group_stats_card.dart';
import '../widgets/scrutin_header.dart';
import '../widgets/scrutin_result_card.dart';
import '../widgets/scrutin_vote_card.dart';

class ScrutinDetailsPage extends ConsumerStatefulWidget {
  const ScrutinDetailsPage({required this.scrutinId, super.key});

  final String scrutinId;

  @override
  ConsumerState<ScrutinDetailsPage> createState() => _ScrutinDetailsPageState();
}

class _ScrutinDetailsPageState extends ConsumerState<ScrutinDetailsPage> {
  late final ScrollController _scrollController;
  String _searchQuery = '';
  String _positionFilter = 'ALL';
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _activeTab != 1) {
      return;
    }

    if (_scrollController.position.extentAfter < 300) {
      ref.read(scrutinVotesProvider(widget.scrutinId).notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrutinAsync = ref.watch(scrutinDetailsProvider(widget.scrutinId));
    final votesState = ref.watch(scrutinVotesProvider(widget.scrutinId));

    final isLoading = scrutinAsync.isLoading || (votesState.isLoadingInitial && !votesState.hasInitialData);
    if (isLoading) {
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final scrutinError = scrutinAsync.hasError;
    final votesError = votesState.errorMessage != null && !votesState.hasInitialData;
    if (scrutinError || votesError) {
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Impossible de charger ce scrutin.'),
                const SizedBox(height: 8),
                Text(
                  scrutinError ? '${scrutinAsync.error}' : votesState.errorMessage ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(scrutinDetailsProvider(widget.scrutinId));
                    ref.read(scrutinVotesProvider(widget.scrutinId).notifier).loadInitial();
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final scrutin = scrutinAsync.value!;
    final filteredVotes = _filteredVotes(votesState.votes);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.refresh(scrutinDetailsProvider(widget.scrutinId).future),
              ref.read(scrutinVotesProvider(widget.scrutinId).notifier).refresh(),
            ]);
          },
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
            ScrutinHeader(scrutin: scrutin),
            const SizedBox(height: 16),
            ScrutinResultCard(scrutin: scrutin),
            const SizedBox(height: 16),
            _TextBlock(
              title: 'Résumé',
              content: scrutin.resumeIa,
            ),
            const SizedBox(height: 12),
            _TextBlock(
              title: 'Qui a demandé ce vote ?',
              content: scrutin.demandeurTexte,
            ),
            if (scrutin.sourceUrl != null && scrutin.sourceUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _openSource(scrutin.sourceUrl!),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Voir la source officielle'),
              ),
            ],
            const SizedBox(height: 16),
            TabBar(
              tabs: const [
                Tab(text: 'Vote par groupe'),
                Tab(text: 'Votes par députés'),
              ],
              onTap: (index) => setState(() => _activeTab = index),
            ),
            const SizedBox(height: 16),
            if (_activeTab == 0)
              ScrutinGroupStatsCard(scrutin: scrutin)
            else ...[
              SearchBar(
                hintText: 'Rechercher un député',
                leading: const Icon(Icons.search),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: 'Tous',
                    selected: _positionFilter == 'ALL',
                    onSelected: () => setState(() => _positionFilter = 'ALL'),
                  ),
                  _FilterChip(
                    label: 'POUR',
                    selected: _positionFilter == 'POUR',
                    onSelected: () => setState(() => _positionFilter = 'POUR'),
                  ),
                  _FilterChip(
                    label: 'CONTRE',
                    selected: _positionFilter == 'CONTRE',
                    onSelected: () => setState(() => _positionFilter = 'CONTRE'),
                  ),
                  _FilterChip(
                    label: 'ABSTENTION',
                    selected: _positionFilter == 'ABSTENTION',
                    onSelected: () => setState(() => _positionFilter = 'ABSTENTION'),
                  ),
                  _FilterChip(
                    label: 'NON VOTANT',
                    selected: _positionFilter == 'NON_VOTANT',
                    onSelected: () => setState(() => _positionFilter = 'NON_VOTANT'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (filteredVotes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('Aucun vote trouvé.')),
                )
              else
                ...filteredVotes.map(
                  (vote) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ScrutinVoteCard(vote: vote),
                  ),
                ),
              if (votesState.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
            ],
          ),
        ),
      ),
    );
  }

  List<ScrutinVote> _filteredVotes(List<ScrutinVote> votes) {
    final query = _searchQuery.trim().toLowerCase();

    return votes.where((vote) {
      final matchesSearch = query.isEmpty ||
          vote.deputy.nom.toLowerCase().contains(query) ||
          vote.deputy.prenom.toLowerCase().contains(query);
      final matchesPosition = _positionFilter == 'ALL' || vote.position.toUpperCase() == _positionFilter;
      return matchesSearch && matchesPosition;
    }).toList(growable: false);
  }

  Future<void> _openSource(String url) async {
    final launched = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le lien source.')),
      );
    }
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.title, required this.content});

  final String title;
  final String? content;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(content == null || content!.isEmpty ? 'Information non disponible.' : content!),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onSelected});

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
