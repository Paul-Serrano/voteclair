import '../entities/paginated_scrutins.dart';
import '../entities/paginated_votes.dart';
import '../entities/scrutin.dart';

abstract class ScrutinRepository {
  Future<PaginatedScrutins> fetchScrutins(
    int page, {
    String search = '',
    String importanceFilter = 'all',
    String sortMode = 'numero_desc',
  });

  Future<Scrutin> getById(String id);

  Future<PaginatedVotes> getVotes(String scrutinId, int page);
}
