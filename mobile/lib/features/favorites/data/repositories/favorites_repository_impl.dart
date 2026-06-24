import '../../../../core/storage/favorites_service.dart';
import '../../../deputies/domain/entities/deputy.dart';
import '../../../deputies/domain/repositories/deputy_repository.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._service, this._deputyRepository);

  final FavoritesService _service;
  final DeputyRepository _deputyRepository;

  @override
  List<String> getSlugs() => _service.getSlugs();

  @override
  Future<List<Deputy>> getFavorites() async {
    final slugs = _service.getSlugs();
    if (slugs.isEmpty) return [];
    return Future.wait(slugs.map(_deputyRepository.getBySlug));
  }

  @override
  Future<void> addFavorite(String slug) => _service.add(slug);

  @override
  Future<void> removeFavorite(String slug) => _service.remove(slug);

  @override
  bool isFavorite(String slug) => _service.contains(slug);
}
