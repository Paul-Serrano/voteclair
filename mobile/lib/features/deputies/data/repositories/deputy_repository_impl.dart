import '../../../../core/api/api_client.dart';
import '../../domain/entities/deputy.dart';
import '../../domain/entities/paginated_votes.dart';
import '../../domain/repositories/deputy_repository.dart';
import '../dto/deputy_dto.dart';
import '../dto/paginated_votes_dto.dart';

class DeputyRepositoryImpl implements DeputyRepository {
  DeputyRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Deputy>> fetchDeputies() async {
    final response = await _apiClient.get('/deputies');
    final payload = response.data;

    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected API payload format for /deputies');
    }

    final data = payload['data'];
    if (data is! List) {
      throw Exception('Missing data array in /deputies response');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(DeputyDto.fromJson)
        .map((dto) => dto.toDomain())
        .toList(growable: false);
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
