import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(apiClientProvider));
});

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getDashboard();
});
