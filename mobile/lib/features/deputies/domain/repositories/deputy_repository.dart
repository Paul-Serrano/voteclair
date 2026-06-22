import '../entities/deputy.dart';

abstract class DeputyRepository {
  Future<List<Deputy>> fetchDeputies();
}
