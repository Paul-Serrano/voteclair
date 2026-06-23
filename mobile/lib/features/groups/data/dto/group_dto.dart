import '../../domain/entities/group.dart';

class GroupDto {
  const GroupDto({
    required this.id,
    required this.slug,
    required this.nom,
    required this.nomComplet,
    this.couleur,
    this.logoUrl,
    this.position,
    required this.membresCount,
    required this.stats,
  });

  final String id;
  final String slug;
  final String nom;
  final String nomComplet;
  final String? couleur;
  final String? logoUrl;
  final String? position;
  final int membresCount;
  final GroupStatsDto stats;

  factory GroupDto.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return GroupDto(
      id: (json['id'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
      nomComplet: (json['nom_complet'] as String?) ?? '',
      couleur: json['couleur'] as String?,
      logoUrl: json['logo_url'] as String?,
      position: json['position'] as String?,
      membresCount: _asInt(json['membres_count']) ?? 0,
      stats: GroupStatsDto.fromJson(stats),
    );
  }

  Group toDomain() {
    return Group(
      id: id,
      slug: slug,
      nom: nom,
      nomComplet: nomComplet,
      couleur: couleur,
      logoUrl: logoUrl,
      position: position,
      membresCount: membresCount,
      stats: stats.toDomain(),
    );
  }
}

class GroupStatsDto {
  const GroupStatsDto({
    required this.presence,
    required this.presenceSolennelle,
    required this.loyaute,
    required this.cohesion,
    required this.participation,
    required this.votesPour,
    required this.votesContre,
    required this.votesAbstention,
    required this.votesAbsent,
  });

  final int presence;
  final int presenceSolennelle;
  final int loyaute;
  final int cohesion;
  final int participation;
  final int votesPour;
  final int votesContre;
  final int votesAbstention;
  final int votesAbsent;

  factory GroupStatsDto.fromJson(Map<String, dynamic> json) {
    return GroupStatsDto(
      presence: _asInt(json['presence']) ?? 0,
      presenceSolennelle: _asInt(json['presence_solennelle']) ?? 0,
      loyaute: _asInt(json['loyaute']) ?? 0,
      cohesion: _asInt(json['cohesion']) ?? 0,
      participation: _asInt(json['participation']) ?? 0,
      votesPour: _asInt(json['votes_pour']) ?? 0,
      votesContre: _asInt(json['votes_contre']) ?? 0,
      votesAbstention: _asInt(json['votes_abstention']) ?? 0,
      votesAbsent: _asInt(json['votes_absent']) ?? 0,
    );
  }

  GroupStats toDomain() {
    return GroupStats(
      presence: presence,
      presenceSolennelle: presenceSolennelle,
      loyaute: loyaute,
      cohesion: cohesion,
      participation: participation,
      votesPour: votesPour,
      votesContre: votesContre,
      votesAbstention: votesAbstention,
      votesAbsent: votesAbsent,
    );
  }
}

int? _asInt(dynamic value) {
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
