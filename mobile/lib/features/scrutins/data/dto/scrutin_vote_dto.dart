import '../../domain/entities/scrutin_vote.dart';

class ScrutinVoteDto {
  const ScrutinVoteDto({
    required this.position,
    required this.delegated,
    required this.deputy,
  });

  final String position;
  final bool delegated;
  final ScrutinVoteDeputyDto deputy;

  factory ScrutinVoteDto.fromJson(Map<String, dynamic> json) {
    final deputyJson = json['deputy'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return ScrutinVoteDto(
      position: (json['position'] as String?) ?? '',
      delegated: (json['delegated'] as bool?) ?? false,
      deputy: ScrutinVoteDeputyDto.fromJson(deputyJson),
    );
  }

  ScrutinVote toDomain() {
    return ScrutinVote(
      position: position,
      delegated: delegated,
      deputy: deputy.toDomain(),
    );
  }
}

class ScrutinVoteDeputyDto {
  const ScrutinVoteDeputyDto({
    required this.slug,
    required this.nom,
    required this.prenom,
    this.groupName,
    this.groupColor,
  });

  final String slug;
  final String nom;
  final String prenom;
  final String? groupName;
  final String? groupColor;

  factory ScrutinVoteDeputyDto.fromJson(Map<String, dynamic> json) {
    final group = json['group'] as Map<String, dynamic>?;

    return ScrutinVoteDeputyDto(
      slug: (json['slug'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
      prenom: (json['prenom'] as String?) ?? '',
      groupName: group?['nom'] as String?,
      groupColor: group?['couleur'] as String?,
    );
  }

  ScrutinVoteDeputy toDomain() {
    return ScrutinVoteDeputy(
      slug: slug,
      nom: nom,
      prenom: prenom,
      groupName: groupName,
      groupColor: groupColor,
    );
  }
}
