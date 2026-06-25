import '../../domain/entities/important_vote_item.dart';

class ImportantVoteItemDto {
  const ImportantVoteItemDto({
    required this.id,
    required this.numero,
    required this.titre,
    required this.dateScrutin,
    required this.importanceScore,
    required this.sort,
  });

  final String id;
  final int numero;
  final String titre;
  final DateTime? dateScrutin;
  final int importanceScore;
  final String? sort;

  factory ImportantVoteItemDto.fromJson(Map<String, dynamic> json) {
    final rawDate = (json['date_scrutin'] ?? json['date']) as String?;

    return ImportantVoteItemDto(
      id: (json['id'] as String?) ?? '',
      numero: (json['numero'] as num?)?.toInt() ?? 0,
      titre: (json['titre'] as String?) ?? '',
      dateScrutin: rawDate == null ? null : DateTime.tryParse(rawDate),
      importanceScore: (json['importance_score'] as num?)?.toInt() ?? 0,
      sort: json['sort'] as String?,
    );
  }

  ImportantVoteItem toDomain() {
    return ImportantVoteItem(
      id: id,
      numero: numero,
      titre: titre,
      dateScrutin: dateScrutin,
      importanceScore: importanceScore,
      sort: sort,
    );
  }
}
