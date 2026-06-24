import '../../../../core/api/api_client.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/repositories/activity_repository.dart';
import '../dto/activity_item_dto.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ActivityItem>> getFavoritesActivity(List<String> slugs) async {
    if (slugs.isEmpty) {
      return const [];
    }

    final response = await _apiClient.get(
      '/favorites/activity',
      queryParameters: <String, dynamic>{
        'slugs': slugs.join(','),
      },
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected API payload format for /favorites/activity');
    }

    final data = payload['data'];
    if (data is! List) {
      throw Exception('Missing data array in /favorites/activity response');
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(ActivityItemDto.fromJson)
        .map((dto) => dto.toDomain())
        .toList(growable: false);
  }
}
