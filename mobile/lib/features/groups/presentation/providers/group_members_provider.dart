import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/group_member.dart';
import 'group_details_provider.dart';

class GroupMembersState {
  const GroupMembersState({
    this.members = const <GroupMember>[],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoadingInitial = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<GroupMember> members;
  final int currentPage;
  final int lastPage;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => currentPage < lastPage;
  bool get hasInitialData => currentPage > 0;

  GroupMembersState copyWith({
    List<GroupMember>? members,
    int? currentPage,
    int? lastPage,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GroupMembersState(
      members: members ?? this.members,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class GroupMembersNotifier extends StateNotifier<GroupMembersState> {
  GroupMembersNotifier({
    required this.slug,
    required this.ref,
  }) : super(const GroupMembersState()) {
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
      members: const <GroupMember>[],
      currentPage: 0,
      lastPage: 1,
    );

    try {
      final page = await ref.read(groupRepositoryProvider).getDeputies(slug, 1);
      state = state.copyWith(
        members: page.members,
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
      final page = await ref.read(groupRepositoryProvider).getDeputies(slug, nextPage);
      final merged = <GroupMember>[...state.members, ...page.members];

      state = state.copyWith(
        members: merged,
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

final groupMembersProvider =
    StateNotifierProvider.family<GroupMembersNotifier, GroupMembersState, String>((ref, slug) {
  return GroupMembersNotifier(slug: slug, ref: ref);
});
