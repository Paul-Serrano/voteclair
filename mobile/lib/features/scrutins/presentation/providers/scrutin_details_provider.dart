import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../data/repositories/scrutin_repository_impl.dart';
import '../../domain/entities/scrutin.dart';
import '../../domain/repositories/scrutin_repository.dart';

final scrutinRepositoryProvider = Provider<ScrutinRepository>((ref) {
  return ScrutinRepositoryImpl(ref.watch(apiClientProvider));
});

final scrutinDetailsProvider = FutureProvider.family<Scrutin, String>((ref, scrutinId) async {
  return ref.watch(scrutinRepositoryProvider).getById(scrutinId);
});
