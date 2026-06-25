import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../data/repositories/find_my_deputy_repository_impl.dart';
import '../../domain/entities/find_my_deputy_result.dart';
import '../../domain/repositories/find_my_deputy_repository.dart';

final findMyDeputyRepositoryProvider = Provider<FindMyDeputyRepository>((ref) {
  return FindMyDeputyRepositoryImpl(ref.watch(apiClientProvider));
});

class FindMyDeputyState {
  const FindMyDeputyState({
    this.postalCode = '',
    this.institutionId,
    this.result,
    this.isLoading = false,
    this.errorMessage,
  });

  final String postalCode;
  final String? institutionId;
  final FindMyDeputyResult? result;
  final bool isLoading;
  final String? errorMessage;

  bool get isIdle => postalCode.trim().isEmpty;

  bool get isSuccess => result != null && !isLoading && errorMessage == null;

  FindMyDeputyState copyWith({
    String? postalCode,
    String? institutionId,
    FindMyDeputyResult? result,
    bool clearResult = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FindMyDeputyState(
      postalCode: postalCode ?? this.postalCode,
      institutionId: institutionId ?? this.institutionId,
      result: clearResult ? null : (result ?? this.result),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class FindMyDeputyNotifier extends StateNotifier<FindMyDeputyState> {
  FindMyDeputyNotifier({required this.ref}) : super(const FindMyDeputyState());

  final Ref ref;

  void setPostalCode(String value) {
    state = state.copyWith(
      postalCode: value,
      clearError: true,
      clearResult: true,
    );
  }

  void setInstitutionId(String? value) {
    state = state.copyWith(
      institutionId: value,
      clearError: true,
      clearResult: true,
    );
  }

  Future<void> find() async {
    final normalized = state.postalCode.trim();
    if (!RegExp(r'^\d{5}$').hasMatch(normalized)) {
      state = state.copyWith(errorMessage: 'postal_code_invalid', clearResult: true);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await ref.read(findMyDeputyRepositoryProvider).findByPostalCode(
            postalCode: normalized,
            institutionId: state.institutionId,
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

final findMyDeputyProvider = StateNotifierProvider<FindMyDeputyNotifier, FindMyDeputyState>((ref) {
  return FindMyDeputyNotifier(ref: ref);
});