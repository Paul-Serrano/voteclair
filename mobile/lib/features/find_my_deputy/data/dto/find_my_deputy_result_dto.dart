import '../../domain/entities/find_my_deputy_result.dart';

class FindMyDeputyResultDto {
  const FindMyDeputyResultDto({
    required this.postalCode,
    required this.deputies,
    this.institution,
    this.circonscription,
  });

  final String postalCode;
  final FindMyDeputyInstitutionDto? institution;
  final FindMyDeputyCirconscriptionDto? circonscription;
  final List<FindMyDeputyDeputyDto> deputies;

  factory FindMyDeputyResultDto.fromJson(Map<String, dynamic> json) {
    return FindMyDeputyResultDto(
      postalCode: (json['postal_code'] as String?) ?? '',
      institution: json['institution'] is Map<String, dynamic>
          ? FindMyDeputyInstitutionDto.fromJson(json['institution'] as Map<String, dynamic>)
          : null,
      circonscription: json['circonscription'] is Map<String, dynamic>
          ? FindMyDeputyCirconscriptionDto.fromJson(json['circonscription'] as Map<String, dynamic>)
          : null,
      deputies: (json['deputies'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(FindMyDeputyDeputyDto.fromJson)
          .toList(growable: false),
    );
  }

  FindMyDeputyResult toDomain() {
    return FindMyDeputyResult(
      postalCode: postalCode,
      institution: institution?.toDomain(),
      circonscription: circonscription?.toDomain(),
      deputies: deputies.map((item) => item.toDomain()).toList(growable: false),
    );
  }
}

class FindMyDeputyInstitutionDto {
  const FindMyDeputyInstitutionDto({
    required this.id,
    required this.nom,
  });

  final String id;
  final String nom;

  factory FindMyDeputyInstitutionDto.fromJson(Map<String, dynamic> json) {
    return FindMyDeputyInstitutionDto(
      id: (json['id'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
    );
  }

  FindMyDeputyInstitution toDomain() => FindMyDeputyInstitution(id: id, nom: nom);
}

class FindMyDeputyCirconscriptionDto {
  const FindMyDeputyCirconscriptionDto({
    required this.id,
    required this.nom,
  });

  final String id;
  final String nom;

  factory FindMyDeputyCirconscriptionDto.fromJson(Map<String, dynamic> json) {
    return FindMyDeputyCirconscriptionDto(
      id: (json['id'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
    );
  }

  FindMyDeputyCirconscription toDomain() => FindMyDeputyCirconscription(id: id, nom: nom);
}

class FindMyDeputyDeputyDto {
  const FindMyDeputyDeputyDto({
    required this.slug,
    required this.prenom,
    required this.nom,
    required this.latestVotes,
    this.photoUrl,
    this.profession,
    this.statsPresence,
    this.statsLoyaute,
    this.statsParticipation,
    this.group,
  });

  final String slug;
  final String prenom;
  final String nom;
  final String? photoUrl;
  final String? profession;
  final int? statsPresence;
  final int? statsLoyaute;
  final int? statsParticipation;
  final FindMyDeputyGroupDto? group;
  final List<FindMyDeputyVoteDto> latestVotes;

  factory FindMyDeputyDeputyDto.fromJson(Map<String, dynamic> json) {
    return FindMyDeputyDeputyDto(
      slug: (json['slug'] as String?) ?? '',
      prenom: (json['prenom'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
      photoUrl: json['photo_url'] as String?,
      profession: json['profession'] as String?,
      statsPresence: _asInt(json['stats_presence']),
      statsLoyaute: _asInt(json['stats_loyaute']),
      statsParticipation: _asInt(json['stats_participation']),
      group: json['group'] is Map<String, dynamic>
          ? FindMyDeputyGroupDto.fromJson(json['group'] as Map<String, dynamic>)
          : null,
      latestVotes: (json['latest_votes'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(FindMyDeputyVoteDto.fromJson)
          .toList(growable: false),
    );
  }

  FindMyDeputyDeputy toDomain() {
    return FindMyDeputyDeputy(
      slug: slug,
      prenom: prenom,
      nom: nom,
      photoUrl: photoUrl,
      profession: profession,
      statsPresence: statsPresence,
      statsLoyaute: statsLoyaute,
      statsParticipation: statsParticipation,
      group: group?.toDomain(),
      latestVotes: latestVotes.map((item) => item.toDomain()).toList(growable: false),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class FindMyDeputyGroupDto {
  const FindMyDeputyGroupDto({
    required this.nom,
    this.slug,
    this.couleur,
  });

  final String? slug;
  final String nom;
  final String? couleur;

  factory FindMyDeputyGroupDto.fromJson(Map<String, dynamic> json) {
    return FindMyDeputyGroupDto(
      slug: json['slug'] as String?,
      nom: (json['nom'] as String?) ?? '',
      couleur: json['couleur'] as String?,
    );
  }

  FindMyDeputyGroup toDomain() => FindMyDeputyGroup(slug: slug, nom: nom, couleur: couleur);
}

class FindMyDeputyVoteDto {
  const FindMyDeputyVoteDto({
    required this.scrutinId,
    required this.position,
    required this.delegated,
    required this.scrutin,
  });

  final String scrutinId;
  final String position;
  final bool delegated;
  final FindMyDeputyScrutinDto scrutin;

  factory FindMyDeputyVoteDto.fromJson(Map<String, dynamic> json) {
    return FindMyDeputyVoteDto(
      scrutinId: (json['scrutin_id'] as String?) ?? '',
      position: (json['position'] as String?) ?? '',
      delegated: json['delegated'] as bool? ?? false,
      scrutin: FindMyDeputyScrutinDto.fromJson((json['scrutin'] as Map<String, dynamic>?) ?? const <String, dynamic>{}),
    );
  }

  FindMyDeputyVote toDomain() => FindMyDeputyVote(
        scrutinId: scrutinId,
        position: position,
        delegated: delegated,
        scrutin: scrutin.toDomain(),
      );
}

class FindMyDeputyScrutinDto {
  const FindMyDeputyScrutinDto({
    required this.id,
    required this.numero,
    required this.titre,
    required this.sort,
    required this.importanceScore,
    this.date,
  });

  final String id;
  final int? numero;
  final String titre;
  final String? date;
  final String? sort;
  final int importanceScore;

  factory FindMyDeputyScrutinDto.fromJson(Map<String, dynamic> json) {
    return FindMyDeputyScrutinDto(
      id: (json['id'] as String?) ?? '',
      numero: FindMyDeputyDeputyDto._asInt(json['numero']),
      titre: (json['titre'] as String?) ?? '',
      date: json['date'] as String?,
      sort: json['sort'] as String?,
      importanceScore: FindMyDeputyDeputyDto._asInt(json['importance_score']) ?? 0,
    );
  }

  FindMyDeputyScrutin toDomain() => FindMyDeputyScrutin(
        id: id,
        numero: numero,
        titre: titre,
        date: date,
        sort: sort,
        importanceScore: importanceScore,
      );
}