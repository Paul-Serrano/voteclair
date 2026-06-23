import 'deputy.dart';

class PaginatedDeputies {
  const PaginatedDeputies({
    required this.deputies,
    required this.currentPage,
    required this.lastPage,
  });

  final List<Deputy> deputies;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}
