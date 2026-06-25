import '../../domain/entities/deputy_vote.dart';

class DeputyVoteDto {
  const DeputyVoteDto({
    required this.position,
    required this.delegated,
    required this.scrutin,
  });

  final String position;
  final bool delegated;
  final DeputyVoteScrutinDto scrutin;

  factory DeputyVoteDto.fromJson(Map<String, dynamic> json) {
    final scrutin =
        json['scrutin'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return DeputyVoteDto(
      position: (json['position'] as String?) ?? '',
      delegated: (json['delegated'] as bool?) ?? false,
      scrutin: DeputyVoteScrutinDto.fromJson(scrutin),
    );
  }

  DeputyVote toDomain() {
    return DeputyVote(
      position: position,
      delegated: delegated,
      scrutin: scrutin.toDomain(),
    );
  }
}

class DeputyVoteScrutinDto {
  const DeputyVoteScrutinDto({
    required this.id,
    required this.numero,
    required this.titre,
    required this.date,
    required this.sort,
    required this.importanceScore,
  });

  final String id;
  final int? numero;
  final String titre;
  final String? date;
  final String? sort;
  final int importanceScore;

  factory DeputyVoteScrutinDto.fromJson(Map<String, dynamic> json) {
    return DeputyVoteScrutinDto(
      id: (json['id'] as String?) ?? '',
      numero: _asInt(json['numero']),
      titre: (json['titre'] as String?) ?? '',
      date: json['date'] as String?,
      sort: json['sort'] as String?,
      importanceScore: _asInt(json['importance_score']) ?? 0,
    );
  }

  DeputyVoteScrutin toDomain() {
    return DeputyVoteScrutin(
      id: id,
      numero: numero,
      titre: titre,
      date: date,
      sort: sort,
      importanceScore: importanceScore,
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
