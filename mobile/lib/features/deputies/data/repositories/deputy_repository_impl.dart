import '../../../../core/api/api_client.dart';
import '../../domain/entities/deputy.dart';
import '../../domain/repositories/deputy_repository.dart';
import '../dto/deputy_dto.dart';

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
}
