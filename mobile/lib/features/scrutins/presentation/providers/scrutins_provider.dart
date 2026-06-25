import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/widgets/scrutin_filter_sort_controls.dart';
import '../../data/repositories/scrutin_repository_impl.dart';
import '../../domain/entities/scrutin.dart';
import '../../domain/repositories/scrutin_repository.dart';

final scrutinRepositoryProvider = Provider<ScrutinRepository>((ref) {
  return ScrutinRepositoryImpl(ref.watch(apiClientProvider));
});

class ScrutinsState {
  const ScrutinsState({
    this.scrutins = const <Scrutin>[],
    this.currentPage = 0,
    this.lastPage = 1,
    this.searchQuery = '',
    this.importanceFilter = ScrutinImportanceFilter.all,
    this.sortMode = ScrutinSortMode.numeroDesc,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<Scrutin> scrutins;
  final int currentPage;
  final int lastPage;
  final String searchQuery;
  final ScrutinImportanceFilter importanceFilter;
  final ScrutinSortMode sortMode;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => currentPage < lastPage;
  bool get hasInitialData => currentPage > 0;

  ScrutinsState copyWith({
    List<Scrutin>? scrutins,
    int? currentPage,
    int? lastPage,
    String? searchQuery,
    ScrutinImportanceFilter? importanceFilter,
    ScrutinSortMode? sortMode,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ScrutinsState(
      scrutins: scrutins ?? this.scrutins,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      searchQuery: searchQuery ?? this.searchQuery,
      importanceFilter: importanceFilter ?? this.importanceFilter,
      sortMode: sortMode ?? this.sortMode,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ScrutinsNotifier extends StateNotifier<ScrutinsState> {
  ScrutinsNotifier({required this.ref}) : super(const ScrutinsState()) {
    loadInitial();
  }

  final Ref ref;

  Future<void> loadInitial() async {
    if (state.isLoadingInitial) {
      return;
    }

    state = state.copyWith(
      isLoadingInitial: true,
      isLoadingMore: false,
      clearError: true,
      scrutins: const <Scrutin>[],
      currentPage: 0,
      lastPage: 1,
    );

    try {
      final page = await ref.read(scrutinRepositoryProvider).fetchScrutins(
        1,
        search: state.searchQuery,
        importanceFilter: _importanceFilterQuery(state.importanceFilter),
        sortMode: _sortModeQuery(state.sortMode),
      );
      state = state.copyWith(
        scrutins: page.scrutins,
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

  Future<void> applySearch(String searchQuery) async {
    final normalized = searchQuery.trim();
    if (normalized == state.searchQuery) {
      return;
    }

    state = state.copyWith(searchQuery: normalized, clearError: true);
    await loadInitial();
  }

  Future<void> applyImportanceFilter(ScrutinImportanceFilter filter) async {
    if (filter == state.importanceFilter) {
      return;
    }

    state = state.copyWith(importanceFilter: filter, clearError: true);
    await loadInitial();
  }

  Future<void> applySortMode(ScrutinSortMode sortMode) async {
    if (sortMode == state.sortMode) {
      return;
    }

    state = state.copyWith(sortMode: sortMode, clearError: true);
    await loadInitial();
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingInitial || state.isLoadingMore || !state.hasMore) {
      return;
    }

    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final page = await ref.read(scrutinRepositoryProvider).fetchScrutins(
        nextPage,
        search: state.searchQuery,
        importanceFilter: _importanceFilterQuery(state.importanceFilter),
        sortMode: _sortModeQuery(state.sortMode),
      );
      final merged = <Scrutin>[...state.scrutins, ...page.scrutins];

      state = state.copyWith(
        scrutins: merged,
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

  String _importanceFilterQuery(ScrutinImportanceFilter filter) {
    return switch (filter) {
      ScrutinImportanceFilter.all => 'all',
      ScrutinImportanceFilter.important => 'important',
      ScrutinImportanceFilter.veryImportant => 'very_important',
    };
  }

  String _sortModeQuery(ScrutinSortMode sortMode) {
    return switch (sortMode) {
      ScrutinSortMode.numeroDesc => 'numero_desc',
      ScrutinSortMode.numeroAsc => 'numero_asc',
      ScrutinSortMode.importanceDesc => 'importance_desc',
      ScrutinSortMode.importanceAsc => 'importance_asc',
    };
  }
}

final scrutinsProvider = StateNotifierProvider<ScrutinsNotifier, ScrutinsState>((ref) {
  return ScrutinsNotifier(ref: ref);
});