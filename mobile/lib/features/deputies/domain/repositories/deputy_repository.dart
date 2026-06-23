import '../entities/deputy.dart';
import '../entities/paginated_votes.dart';

abstract class DeputyRepository {
  Future<List<Deputy>> fetchDeputies();

  Future<Deputy> getBySlug(String slug);

  Future<PaginatedVotes> getVotes(String slug, int page);
}
