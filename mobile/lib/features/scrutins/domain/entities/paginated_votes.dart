import 'scrutin_vote.dart';

class PaginatedVotes {
  const PaginatedVotes({
    required this.votes,
    required this.currentPage,
    required this.lastPage,
  });

  final List<ScrutinVote> votes;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}
