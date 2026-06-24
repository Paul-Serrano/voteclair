import '../../../deputies/domain/entities/deputy.dart';

abstract class FavoritesRepository {
  List<String> getSlugs();
  Future<List<Deputy>> getFavorites();
  Future<void> addFavorite(String slug);
  Future<void> removeFavorite(String slug);
  bool isFavorite(String slug);
}
