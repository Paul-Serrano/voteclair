import '../../../../core/api/api_client.dart';
import '../../domain/entities/paginated_scrutins.dart';
import '../../domain/entities/paginated_votes.dart';
import '../../domain/entities/scrutin.dart';
import '../../domain/repositories/scrutin_repository.dart';
import '../dto/paginated_scrutins_dto.dart';
import '../dto/paginated_votes_dto.dart';
import '../dto/scrutin_dto.dart';

class ScrutinRepositoryImpl implements ScrutinRepository {
  ScrutinRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaginatedScrutins> fetchScrutins(int page, {String search = ''}) async {
    final queryParameters = <String, dynamic>{'page': page};
    if (search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final response = await _apiClient.get(
      '/scrutins',
      queryParameters: queryParameters,
    );
    final payload = response.data;

    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected API payload format for /scrutins');
    }

    return PaginatedScrutinsDto.fromJson(payload).toDomain();
  }

  @override
  Future<Scrutin> getById(String id) async {
    final response = await _apiClient.get('/scrutins/$id');
    final payload = response.data;

    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected API payload format for /scrutins/$id');
    }

    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Missing data object in /scrutins/$id response');
    }

    return ScrutinDto.fromJson(data).toDomain();
  }

  @override
  Future<PaginatedVotes> getVotes(String scrutinId, int page) async {
    final response = await _apiClient.get(
      '/scrutins/$scrutinId/votes',
      queryParameters: <String, dynamic>{'page': page},
    );
    final payload = response.data;

    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected API payload format for /scrutins/$scrutinId/votes');
    }

    return PaginatedVotesDto.fromJson(payload).toDomain();
  }
}
