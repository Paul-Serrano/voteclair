import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/storage/favorites_service.dart';
import '../../../deputies/data/repositories/deputy_repository_impl.dart';
import '../../../deputies/domain/entities/deputy.dart';
import '../../../deputies/domain/repositories/deputy_repository.dart';
import '../../../deputies/presentation/providers/deputies_provider.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/repositories/favorites_repository.dart';

// ─── Infrastructure ──────────────────────────────────────────────────────────

final favoritesServiceProvider = FutureProvider<FavoritesService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return FavoritesService(prefs);
});

final favoritesRepositoryProvider = FutureProvider<FavoritesRepository>((ref) async {
  final service = await ref.watch(favoritesServiceProvider.future);
  final deputyRepo = ref.watch(deputyRepositoryProvider);
  return FavoritesRepositoryImpl(service, deputyRepo);
});

// ─── Slugs notifier (reactive state) ─────────────────────────────────────────

class FavoriteSlugsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final service = await ref.watch(favoritesServiceProvider.future);
    return service.getSlugs();
  }

  /// Toggles the favorite state for [slug].
  /// Returns `true` if it was added, `false` if removed.
  Future<bool> toggle(String slug) async {
    final service = await ref.read(favoritesServiceProvider.future);
    final current = state.value ?? [];
    final isAdding = !current.contains(slug);
    if (isAdding) {
      await service.add(slug);
    } else {
      await service.remove(slug);
    }
    state = AsyncData(service.getSlugs());
    return isAdding;
  }
}

final favoriteSlugsNotifierProvider =
    AsyncNotifierProvider<FavoriteSlugsNotifier, List<String>>(
  FavoriteSlugsNotifier.new,
);

// ─── Derived providers ────────────────────────────────────────────────────────

/// Synchronously returns whether [slug] is currently favorited.
final isFavoriteProvider = Provider.family<bool, String>((ref, slug) {
  return ref.watch(favoriteSlugsNotifierProvider).value?.contains(slug) ?? false;
});

/// Returns the full [Deputy] objects for every favorited slug.
final favoritesProvider = FutureProvider<List<Deputy>>((ref) async {
  final slugs = await ref.watch(favoriteSlugsNotifierProvider.future);
  if (slugs.isEmpty) return [];
  final DeputyRepository repo = DeputyRepositoryImpl(ref.watch(apiClientProvider));
  return Future.wait(slugs.map(repo.getBySlug));
});
