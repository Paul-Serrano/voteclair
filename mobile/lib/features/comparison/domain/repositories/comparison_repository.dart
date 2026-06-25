import '../entities/deputy_comparison.dart';

abstract class ComparisonRepository {
  Future<DeputyComparison> compare({
    required String leftSlug,
    required String rightSlug,
  });
}
