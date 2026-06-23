import '../entities/deputy.dart';

abstract class DeputyRepository {
  Future<List<Deputy>> fetchDeputies();

  Future<Deputy> getBySlug(String slug);
}
