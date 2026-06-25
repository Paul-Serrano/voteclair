import '../entities/important_vote_item.dart';

abstract class ImportantVotesRepository {
  Future<List<ImportantVoteItem>> getImportantVotes({int limit = 20});
}
