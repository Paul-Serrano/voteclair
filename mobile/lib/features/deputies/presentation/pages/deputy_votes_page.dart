import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/deputy.dart';
import '../../domain/entities/deputy_vote.dart';
import '../providers/deputy_details_provider.dart';
import '../providers/deputy_votes_provider.dart';
import '../widgets/vote_card.dart';

class DeputyVotesPage extends ConsumerStatefulWidget {
  const DeputyVotesPage({required this.slug, super.key});

  final String slug;

  @override
  ConsumerState<DeputyVotesPage> createState() => _DeputyVotesPageState();
}

class _DeputyVotesPageState extends ConsumerState<DeputyVotesPage> {
  late final ScrollController _scrollController;
  String _searchQuery = '';

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
    if (!_scrollController.hasClients) {
      return;
    }

    final triggerPagination = _scrollController.position.extentAfter < 300;
    if (triggerPagination) {
      ref.read(deputyVotesProvider(widget.slug).notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final votesState = ref.watch(deputyVotesProvider(widget.slug));
    final deputyAsync = ref.watch(deputyDetailsProvider(widget.slug));

    final filteredVotes = _filterVotes(votesState.votes, _searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Votes du depute'),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go('/deputies/${widget.slug}');
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
        ),
      ),
      body: _buildBody(context, deputyAsync, votesState, filteredVotes),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncValue<Deputy> deputyAsync,
    DeputyVotesState votesState,
    List<DeputyVote> filteredVotes,
  ) {
    if (votesState.isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (votesState.errorMessage != null && !votesState.hasInitialData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Impossible de charger les votes.'),
              const SizedBox(height: 8),
              Text(
                votesState.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref
                    .read(deputyVotesProvider(widget.slug).notifier)
                    .loadInitial(),
                child: const Text('Reessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(deputyVotesProvider(widget.slug).notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _itemCount(filteredVotes, votesState),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _VotesHeader(deputyAsync: deputyAsync, slug: widget.slug);
          }

          if (index == 1) {
            return Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: SearchBar(
                hintText: 'Rechercher par titre de scrutin',
                leading: const Icon(Icons.search),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            );
          }

          if (filteredVotes.isEmpty && index == 2) {
            return const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: Text('Aucun vote trouve.')),
            );
          }

          const dataStartIndex = 2;
          final dataEndIndexExclusive = dataStartIndex + filteredVotes.length;

          if (index >= dataStartIndex && index < dataEndIndexExclusive) {
            final vote = filteredVotes[index - dataStartIndex];
            final scrutinId = vote.scrutin.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: VoteCard(
                vote: vote,
                onTap: scrutinId.isEmpty
                    ? null
                    : () => context.push('/scrutins/$scrutinId'),
              ),
            );
          }

          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  int _itemCount(List<DeputyVote> filteredVotes, DeputyVotesState state) {
    final hasEmptyMessage = filteredVotes.isEmpty ? 1 : filteredVotes.length;
    final hasBottomLoader = state.isLoadingMore ? 1 : 0;

    return 2 + hasEmptyMessage + hasBottomLoader;
  }

  List<DeputyVote> _filterVotes(List<DeputyVote> votes, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return votes;
    }

    return votes
        .where((vote) =>
            vote.scrutin.titre.toLowerCase().contains(normalizedQuery))
        .toList(growable: false);
  }
}

class _VotesHeader extends StatelessWidget {
  const _VotesHeader({required this.deputyAsync, required this.slug});

  final AsyncValue<Deputy> deputyAsync;
  final String slug;

  @override
  Widget build(BuildContext context) {
    return deputyAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LinearProgressIndicator(),
      ),
      error: (_, __) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Informations du depute indisponibles ($slug).'),
        ),
      ),
      data: (deputy) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                foregroundImage: _networkImageOrNull(deputy.photoUrl),
                child: const Icon(Icons.person_outline),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deputy.fullName,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(deputy.groupName ?? 'Groupe inconnu'),
                  ],
                ),
              ),
            ],
          ),
        ),
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
