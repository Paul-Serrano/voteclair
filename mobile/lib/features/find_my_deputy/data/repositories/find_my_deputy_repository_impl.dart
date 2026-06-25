import '../../../../core/api/api_client.dart';
import '../../domain/entities/find_my_deputy_result.dart';
import '../../domain/repositories/find_my_deputy_repository.dart';
import '../dto/find_my_deputy_result_dto.dart';

class FindMyDeputyRepositoryImpl implements FindMyDeputyRepository {
  FindMyDeputyRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<FindMyDeputyResult> findByPostalCode({
    required String postalCode,
    String? institutionId,
  }) async {
    final response = await _apiClient.get(
      '/find-my-deputy',
      queryParameters: <String, dynamic>{
        'postal_code': postalCode,
        if (institutionId != null && institutionId.trim().isNotEmpty) 'institution_id': institutionId.trim(),
      },
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected API payload format for /find-my-deputy');
    }

    final data = payload['data'] is Map<String, dynamic> ? payload['data'] as Map<String, dynamic> : payload;
    return FindMyDeputyResultDto.fromJson(data).toDomain();
  }
}