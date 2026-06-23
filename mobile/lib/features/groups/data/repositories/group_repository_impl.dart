import '../../../../core/api/api_client.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_summary.dart';
import '../../domain/entities/paginated_group_members.dart';
import '../../domain/repositories/group_repository.dart';
import '../dto/group_dto.dart';
import '../dto/group_summary_dto.dart';
import '../dto/paginated_group_members_dto.dart';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<GroupSummary>> fetchGroups() async {
    final response = await _apiClient.get('/groups');
    final payload = response.data;

    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected API payload format for /groups');
    }

    final data = payload['data'];
    if (data is! List) {
      throw Exception('Missing data array in /groups response');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(GroupSummaryDto.fromJson)
        .map((dto) => dto.toDomain())
        .toList(growable: false);
  }

  @override
  Future<Group> getBySlug(String slug) async {
    final response = await _apiClient.get('/groups/$slug');
    final payload = response.data;

    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected API payload format for /groups/$slug');
    }

    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Missing data object in /groups/$slug response');
    }

    return GroupDto.fromJson(data).toDomain();
  }

  @override
  Future<PaginatedGroupMembers> getDeputies(String slug, int page) async {
    final response = await _apiClient.get(
      '/groups/$slug/deputies',
      queryParameters: <String, dynamic>{'page': page},
    );
    final payload = response.data;

    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected API payload format for /groups/$slug/deputies');
    }

    return PaginatedGroupMembersDto.fromJson(payload).toDomain();
  }
}
