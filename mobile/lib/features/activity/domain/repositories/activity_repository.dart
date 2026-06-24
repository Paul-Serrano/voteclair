import '../entities/activity_item.dart';

abstract class ActivityRepository {
  Future<List<ActivityItem>> getFavoritesActivity(List<String> slugs);
}
