import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../dto/dashboard_data_dto.dart';
import '../../../../core/api/api_client.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DashboardData> getDashboard() async {
    final response = await _apiClient.get('/dashboard');
    final payload = response.data;

    if (payload is! Map<String, dynamic>) {
      throw Exception('Unexpected API payload format for /dashboard');
    }

    final data = payload['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Missing data object in /dashboard response');
    }

    return DashboardDataDto.fromJson(data).toDomain();
  }
}
