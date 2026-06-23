import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../domain/entities/search_results.dart';
import '../../domain/repositories/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryImpl(ref.watch(apiClientProvider));
});

class SearchState {
  const SearchState({
    this.query = '',
    this.results = const SearchResults(),
    this.isLoading = false,
    this.errorMessage,
  });

  final String query;
  final SearchResults results;
  final bool isLoading;
  final String? errorMessage;

  bool get isIdle => query.trim().isEmpty;

  SearchState copyWith({
    String? query,
    SearchResults? results,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier({required this.ref}) : super(const SearchState());

  final Ref ref;
  Timer? _debounce;

  void onQueryChanged(String query) {
    final normalized = query.trim();

    _debounce?.cancel();

    if (normalized.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(
      query: normalized,
      isLoading: true,
      clearError: true,
      results: const SearchResults(),
    );

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _performSearch(normalized);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await ref.read(searchRepositoryProvider).search(query);

      if (state.query != query) {
        return;
      }

      state = state.copyWith(
        results: results,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      if (state.query != query) {
        return;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: '$error',
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref: ref);
});
