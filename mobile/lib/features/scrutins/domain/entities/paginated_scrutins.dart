import 'scrutin.dart';

class PaginatedScrutins {
  const PaginatedScrutins({
    required this.scrutins,
    required this.currentPage,
    required this.lastPage,
  });

  final List<Scrutin> scrutins;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}