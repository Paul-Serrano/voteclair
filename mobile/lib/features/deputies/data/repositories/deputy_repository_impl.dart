import '../../../../core/api/api_client.dart';
import '../../domain/entities/deputy.dart';
import '../../domain/entities/paginated_deputies.dart';
import '../../domain/entities/paginated_votes.dart';
import '../../domain/repositories/deputy_repository.dart';
import '../dto/deputy_dto.dart';
import '../dto/paginated_deputies_dto.dart';
import '../dto/paginated_votes_dto.dart';

class DeputyRepositoryImpl implements DeputyRepository {
  DeputyRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaginatedDeputies> fetchDeputies(
    int page, {
    String group = '',
    String search = '',
  }) async {
    final queryParameters = <String, dynamic>{'page': page};
    if (group.trim().isNotEmpty) {
      queryParameters['group'] = group.trim();
    }
    if (search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final response = await _apiClient.get('/deputies', queryParameters: queryParameters);
    final payload = response.data;

    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected API payload format for /deputies');
    }

    return PaginatedDeputiesDto.fromJson(payload).toDomain();
  }

  @override
  Future<Deputy> getBySlug(String slug) async {
    final response = await _apiClient.get('/deputies/$slug');
    final payload = response.data;

    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected API payload format for /deputies/$slug');
    }

    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Missing data object in /deputies/$slug response');
    }

    return DeputyDto.fromJson(data).toDomain();
  }

  @override
  Future<PaginatedVotes> getVotes(String slug, int page) async {
    final response = await _apiClient.get(
      '/deputies/$slug/votes',
      queryParameters: <String, dynamic>{'page': page},
    );
    final payload = response.data;

    if (payload is! Map<String, dynamic>) {
      throw Exception(
          'Unexpected API payload format for /deputies/$slug/votes');
    }

    return PaginatedVotesDto.fromJson(payload).toDomain();
  }
}
