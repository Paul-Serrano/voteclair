import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/repositories/activity_repository_impl.dart';
import '../../domain/entities/activity_item.dart';
import '../../domain/repositories/activity_repository.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepositoryImpl(ref.watch(apiClientProvider));
});

final favoritesActivityProvider = FutureProvider<List<ActivityItem>>((ref) async {
  final slugs = await ref.watch(favoriteSlugsNotifierProvider.future);
  if (slugs.isEmpty) {
    return const [];
  }

  final repository = ref.watch(activityRepositoryProvider);
  return repository.getFavoritesActivity(slugs);
});

final favoritesActivityPreviewProvider = FutureProvider<List<ActivityItem>>((ref) async {
  final all = await ref.watch(favoritesActivityProvider.future);
  return all.take(5).toList(growable: false);
});
