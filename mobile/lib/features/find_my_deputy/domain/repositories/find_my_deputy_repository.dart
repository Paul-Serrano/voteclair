import '../entities/find_my_deputy_result.dart';

abstract class FindMyDeputyRepository {
  Future<FindMyDeputyResult> findByPostalCode({
    required String postalCode,
    String? institutionId,
  });
}