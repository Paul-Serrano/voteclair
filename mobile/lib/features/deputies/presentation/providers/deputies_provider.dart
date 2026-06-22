import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../data/repositories/deputy_repository_impl.dart';
import '../../domain/entities/deputy.dart';
import '../../domain/repositories/deputy_repository.dart';

final deputyRepositoryProvider = Provider<DeputyRepository>((ref) {
  return DeputyRepositoryImpl(ref.watch(apiClientProvider));
});

final deputiesProvider = FutureProvider<List<Deputy>>((ref) async {
  return ref.watch(deputyRepositoryProvider).fetchDeputies();
});
