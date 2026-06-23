import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/scrutin_vote.dart';
import 'scrutin_details_provider.dart';

class ScrutinVotesState {
  const ScrutinVotesState({
    this.votes = const <ScrutinVote>[],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<ScrutinVote> votes;
  final int currentPage;
  final int lastPage;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => currentPage < lastPage;
  bool get hasInitialData => currentPage > 0;

  ScrutinVotesState copyWith({
    List<ScrutinVote>? votes,
    int? currentPage,
    int? lastPage,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ScrutinVotesState(
      votes: votes ?? this.votes,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ScrutinVotesNotifier extends StateNotifier<ScrutinVotesState> {
  ScrutinVotesNotifier({
    required this.scrutinId,
    required this.ref,
  }) : super(const ScrutinVotesState()) {
    loadInitial();
  }

  final String scrutinId;
  final Ref ref;

  Future<void> loadInitial() async {
    if (state.isLoadingInitial) {
      return;
    }

    state = state.copyWith(
      isLoadingInitial: true,
      isLoadingMore: false,
      clearError: true,
      votes: const <ScrutinVote>[],
      currentPage: 0,
      lastPage: 1,
    );

    try {
      final page = await ref.read(scrutinRepositoryProvider).getVotes(scrutinId, 1);
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
      final page = await ref.read(scrutinRepositoryProvider).getVotes(scrutinId, nextPage);
      final merged = <ScrutinVote>[...state.votes, ...page.votes];

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

final scrutinVotesProvider =
    StateNotifierProvider.family<ScrutinVotesNotifier, ScrutinVotesState, String>((ref, scrutinId) {
  return ScrutinVotesNotifier(scrutinId: scrutinId, ref: ref);
});
