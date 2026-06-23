import '../../domain/entities/paginated_scrutins.dart';
import 'scrutin_dto.dart';

class PaginatedScrutinsDto {
  const PaginatedScrutinsDto({
    required this.scrutins,
    required this.currentPage,
    required this.lastPage,
  });

  final List<ScrutinDto> scrutins;
  final int currentPage;
  final int lastPage;

  factory PaginatedScrutinsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'] as Map<String, dynamic>? ?? <String, dynamic>{};

    if (data is! List) {
      throw Exception('Missing data array in scrutins response');
    }

    return PaginatedScrutinsDto(
      scrutins: data
          .whereType<Map<String, dynamic>>()
          .map(ScrutinDto.fromJson)
          .toList(growable: false),
      currentPage: _asInt(meta['current_page']) ?? 1,
      lastPage: _asInt(meta['last_page']) ?? 1,
    );
  }

  PaginatedScrutins toDomain() {
    return PaginatedScrutins(
      scrutins: scrutins.map((scrutin) => scrutin.toDomain()).toList(growable: false),
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