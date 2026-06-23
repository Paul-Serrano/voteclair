import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/deputy_vote.dart';
import 'deputies_provider.dart';

class DeputyVotesState {
  const DeputyVotesState({
    this.votes = const <DeputyVote>[],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<DeputyVote> votes;
  final int currentPage;
  final int lastPage;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => currentPage < lastPage;
  bool get hasInitialData => currentPage > 0;

  DeputyVotesState copyWith({
    List<DeputyVote>? votes,
    int? currentPage,
    int? lastPage,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeputyVotesState(
      votes: votes ?? this.votes,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DeputyVotesNotifier extends StateNotifier<DeputyVotesState> {
  DeputyVotesNotifier({
    required this.slug,
    required this.ref,
  }) : super(const DeputyVotesState()) {
    loadInitial();
  }

  final String slug;
  final Ref ref;

  Future<void> loadInitial() async {
    if (state.isLoadingInitial) {
      return;
    }

    state = state.copyWith(
      isLoadingInitial: true,
      isLoadingMore: false,
      clearError: true,
      votes: const <DeputyVote>[],
      currentPage: 0,
      lastPage: 1,
    );

    try {
      final page = await ref.read(deputyRepositoryProvider).getVotes(slug, 1);
      state = state.copyWith(
        votes: page.votes,
        currentPage: page.currentPage,
        lastPage: page.lastPage,
        isLoadingInitial: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingInitial: false,
        isLoadingMore: false,
        errorMessage: '$error',
      );
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingInitial || state.isLoadingMore || !state.hasMore) {
      return;
    }

    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final page =
          await ref.read(deputyRepositoryProvider).getVotes(slug, nextPage);
      final merged = <DeputyVote>[...state.votes, ...page.votes];

      state = state.copyWith(
        votes: merged,
        currentPage: page.currentPage,
        lastPage: page.lastPage,
        isLoadingMore: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: '$error',
      );
    }
  }
}

final deputyVotesProvider =
    StateNotifierProvider.family<DeputyVotesNotifier, DeputyVotesState, String>(
        (ref, slug) {
  return DeputyVotesNotifier(slug: slug, ref: ref);
});
