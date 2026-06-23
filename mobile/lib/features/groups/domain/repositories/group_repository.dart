import '../entities/group.dart';
import '../entities/paginated_group_members.dart';
import '../entities/group_summary.dart';

abstract class GroupRepository {
  Future<List<GroupSummary>> fetchGroups();

  Future<Group> getBySlug(String slug);

  Future<PaginatedGroupMembers> getDeputies(String slug, int page);
}
