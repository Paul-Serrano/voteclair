import '../../domain/entities/paginated_deputies.dart';
import 'deputy_dto.dart';

class PaginatedDeputiesDto {
  const PaginatedDeputiesDto({
    required this.deputies,
    required this.currentPage,
    required this.lastPage,
  });

  final List<DeputyDto> deputies;
  final int currentPage;
  final int lastPage;

  factory PaginatedDeputiesDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'] as Map<String, dynamic>? ?? <String, dynamic>{};

    if (data is! List) {
      throw Exception('Missing data array in deputies response');
    }

    return PaginatedDeputiesDto(
      deputies: data
          .whereType<Map<String, dynamic>>()
          .map(DeputyDto.fromJson)
          .toList(growable: false),
      currentPage: _asInt(meta['current_page']) ?? 1,
      lastPage: _asInt(meta['last_page']) ?? 1,
    );
  }

  PaginatedDeputies toDomain() {
    return PaginatedDeputies(
      deputies: deputies.map((item) => item.toDomain()).toList(growable: false),
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
