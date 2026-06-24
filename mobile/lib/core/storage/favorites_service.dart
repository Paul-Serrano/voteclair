import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  FavoritesService(this._prefs);

  static const _key = 'favorite_deputy_slugs';

  final SharedPreferences _prefs;

  List<String> getSlugs() => _prefs.getStringList(_key) ?? [];

  Future<void> add(String slug) async {
    final slugs = getSlugs();
    if (!slugs.contains(slug)) {
      slugs.add(slug);
      await _prefs.setStringList(_key, slugs);
    }
  }

  Future<void> remove(String slug) async {
    final slugs = getSlugs();
    slugs.remove(slug);
    await _prefs.setStringList(_key, slugs);
  }

  bool contains(String slug) => getSlugs().contains(slug);
}
