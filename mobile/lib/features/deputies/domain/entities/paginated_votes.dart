import 'deputy_vote.dart';

class PaginatedVotes {
  const PaginatedVotes({
    required this.votes,
    required this.currentPage,
    required this.lastPage,
  });

  final List<DeputyVote> votes;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}
