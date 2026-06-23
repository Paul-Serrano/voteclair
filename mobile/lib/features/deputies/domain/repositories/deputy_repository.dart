import '../entities/deputy.dart';
import '../entities/paginated_deputies.dart';
import '../entities/paginated_votes.dart';

abstract class DeputyRepository {
  Future<PaginatedDeputies> fetchDeputies(
    int page, {
    String group = '',
    String search = '',
  });

  Future<Deputy> getBySlug(String slug);

  Future<PaginatedVotes> getVotes(String slug, int page);
}
