import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../search/data/repositories/search_repository_impl.dart';
import '../../../search/domain/entities/search_results.dart';
import '../../../search/domain/repositories/search_repository.dart';
import '../../data/repositories/comparison_repository_impl.dart';
import '../../domain/entities/deputy_comparison.dart';
import '../../domain/repositories/comparison_repository.dart';

final comparisonRepositoryProvider = Provider<ComparisonRepository>((ref) {
  return ComparisonRepositoryImpl(ref.watch(apiClientProvider));
});

final comparisonSearchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepositoryImpl(ref.watch(apiClientProvider));
});

class ComparisonState {
  const ComparisonState({
    this.leftDeputy,
    this.rightDeputy,
    this.result,
    this.isLoading = false,
    this.errorMessage,
  });

  final SearchDeputyResult? leftDeputy;
  final SearchDeputyResult? rightDeputy;
  final DeputyComparison? result;
  final bool isLoading;
  final String? errorMessage;

  bool get canCompare =>
      leftDeputy != null &&
      rightDeputy != null &&
      leftDeputy!.slug != rightDeputy!.slug;

  ComparisonState copyWith({
    SearchDeputyResult? leftDeputy,
    bool updateLeft = false,
    SearchDeputyResult? rightDeputy,
    bool updateRight = false,
    DeputyComparison? result,
    bool clearResult = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ComparisonState(
      leftDeputy: updateLeft ? leftDeputy : this.leftDeputy,
      rightDeputy: updateRight ? rightDeputy : this.rightDeputy,
      result: clearResult ? null : (result ?? this.result),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ComparisonNotifier extends StateNotifier<ComparisonState> {
  ComparisonNotifier({required this.ref}) : super(const ComparisonState());

  final Ref ref;

  void setLeftDeputy(SearchDeputyResult deputy) {
    state = state.copyWith(
      leftDeputy: deputy,
      updateLeft: true,
      clearError: true,
      clearResult: true,
    );
  }

  void setRightDeputy(SearchDeputyResult deputy) {
    state = state.copyWith(
      rightDeputy: deputy,
      updateRight: true,
      clearError: true,
      clearResult: true,
    );
  }

  void swapDeputies() {
    state = state.copyWith(
      leftDeputy: state.rightDeputy,
      updateLeft: true,
      rightDeputy: state.leftDeputy,
      updateRight: true,
      clearError: true,
      clearResult: true,
    );
  }

  Future<void> compare() async {
    if (!state.canCompare || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await ref.read(comparisonRepositoryProvider).compare(
            leftSlug: state.leftDeputy!.slug,
            rightSlug: state.rightDeputy!.slug,
          );

      state = state.copyWith(
        result: result,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '$error',
      );
    }
  }
}

final comparisonProvider =
    StateNotifierProvider<ComparisonNotifier, ComparisonState>((ref) {
  return ComparisonNotifier(ref: ref);
});

final deputySearchProvider =
    FutureProvider.family<List<SearchDeputyResult>, String>((ref, query) async {
  final normalized = query.trim();
  if (normalized.isEmpty) {
    return const <SearchDeputyResult>[];
  }

  final results = await ref.read(comparisonSearchRepositoryProvider).search(normalized);

  return results.deputies;
});
