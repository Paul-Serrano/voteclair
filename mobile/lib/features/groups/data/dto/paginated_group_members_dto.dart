import '../../domain/entities/paginated_group_members.dart';
import 'group_member_dto.dart';

class PaginatedGroupMembersDto {
  const PaginatedGroupMembersDto({
    required this.members,
    required this.currentPage,
    required this.lastPage,
  });

  final List<GroupMemberDto> members;
  final int currentPage;
  final int lastPage;

  factory PaginatedGroupMembersDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'] as Map<String, dynamic>? ?? <String, dynamic>{};

    if (data is! List) {
      throw Exception('Missing data array in group members response');
    }

    return PaginatedGroupMembersDto(
      members: data
          .whereType<Map<String, dynamic>>()
          .map(GroupMemberDto.fromJson)
          .toList(growable: false),
      currentPage: _asInt(meta['current_page']) ?? 1,
      lastPage: _asInt(meta['last_page']) ?? 1,
    );
  }

  PaginatedGroupMembers toDomain() {
    return PaginatedGroupMembers(
      members: members.map((item) => item.toDomain()).toList(growable: false),
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}
