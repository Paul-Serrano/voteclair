import '../../../../core/api/api_client.dart';
import '../../domain/entities/search_results.dart';
import '../../domain/repositories/search_repository.dart';
import '../dto/search_results_dto.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<SearchResults> search(String query) async {
    final response = await _apiClient.get(
      '/search',
      queryParameters: <String, dynamic>{'q': query},
    );
    final payload = response.data;

    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected API payload format for /search');
    }

    return SearchResultsDto.fromJson(payload).toDomain();
  }
}
