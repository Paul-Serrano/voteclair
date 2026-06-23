import 'group_member.dart';

class PaginatedGroupMembers {
  const PaginatedGroupMembers({
    required this.members,
    required this.currentPage,
    required this.lastPage,
  });

  final List<GroupMember> members;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}
