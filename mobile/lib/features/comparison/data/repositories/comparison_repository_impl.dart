import '../../../../core/api/api_client.dart';
import '../../domain/entities/deputy_comparison.dart';
import '../../domain/repositories/comparison_repository.dart';
import '../dto/deputy_comparison_dto.dart';

class ComparisonRepositoryImpl implements ComparisonRepository {
  ComparisonRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DeputyComparison> compare({
    required String leftSlug,
    required String rightSlug,
  }) async {
    final response = await _apiClient.get(
      '/deputies/compare',
      queryParameters: <String, dynamic>{
        'left_slug': leftSlug,
        'right_slug': rightSlug,
      },
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected API payload format for /deputies/compare');
    }

    return DeputyComparisonDto.fromJson(payload).toDomain();
  }
}
