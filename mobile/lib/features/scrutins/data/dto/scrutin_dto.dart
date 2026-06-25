import '../../domain/entities/scrutin.dart';

class ScrutinDto {
  const ScrutinDto({
    required this.id,
    required this.numero,
    required this.date,
    required this.titre,
    required this.sort,
    required this.importanceScore,
    required this.resultats,
    required this.groupes,
    this.institution,
    this.resumeIa,
    this.demandeurTexte,
    this.sourceUrl,
    this.dossierTitre,
    this.dossierUrl,
  });

  final String id;
  final int? numero;
  final String? date;
  final String titre;
  final String? sort;
  final int importanceScore;
  final ScrutinInstitutionDto? institution;
  final String? resumeIa;
  final String? demandeurTexte;
  final String? sourceUrl;
  final String? dossierTitre;
  final String? dossierUrl;
  final ScrutinResultatsDto resultats;
  final List<ScrutinGroupStatDto> groupes;

  factory ScrutinDto.fromJson(Map<String, dynamic> json) {
    return ScrutinDto(
      id: (json['id'] as String?) ?? '',
      numero: _asInt(json['numero']),
      date: json['date'] as String?,
      titre: (json['titre'] as String?) ?? '',
      sort: json['sort'] as String?,
      importanceScore: _asInt(json['importance_score']) ?? 0,
      institution: json['institution'] is Map<String, dynamic>
          ? ScrutinInstitutionDto.fromJson(json['institution'] as Map<String, dynamic>)
          : null,
      resumeIa: json['resume_ia'] as String?,
      demandeurTexte: json['demandeur_texte'] as String?,
      sourceUrl: json['source_url'] as String?,
      dossierTitre: (json['dossier'] as Map<String, dynamic>?)?['titre'] as String?,
      dossierUrl: (json['dossier'] as Map<String, dynamic>?)?['url'] as String?,
      resultats: ScrutinResultatsDto.fromJson(json['resultats'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      groupes: (json['groupes'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(ScrutinGroupStatDto.fromJson)
          .toList(growable: false),
    );
  }

  Scrutin toDomain() {
    return Scrutin(
      id: id,
      numero: numero,
      date: date,
      titre: titre,
      sort: sort,
      importanceScore: importanceScore,
      institution: institution?.toDomain(),
      resumeIa: resumeIa,
      demandeurTexte: demandeurTexte,
      sourceUrl: sourceUrl,
      dossierTitre: dossierTitre,
      dossierUrl: dossierUrl,
      resultats: resultats.toDomain(),
      groupes: groupes.map((groupe) => groupe.toDomain()).toList(growable: false),
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

class ScrutinInstitutionDto {
  const ScrutinInstitutionDto({
    required this.id,
    required this.slug,
    required this.nom,
    required this.pays,
  });

  final String id;
  final String slug;
  final String nom;
  final String pays;

  factory ScrutinInstitutionDto.fromJson(Map<String, dynamic> json) {
    return ScrutinInstitutionDto(
      id: (json['id'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
      pays: (json['pays'] as String?) ?? '',
    );
  }

  ScrutinInstitution toDomain() {
    return ScrutinInstitution(id: id, slug: slug, nom: nom, pays: pays);
  }
}

class ScrutinResultatsDto {
  const ScrutinResultatsDto({
    required this.pour,
    required this.contre,
    required this.abstention,
    required this.nonVotant,
    required this.total,
  });

  final int pour;
  final int contre;
  final int abstention;
  final int nonVotant;
  final int total;

  factory ScrutinResultatsDto.fromJson(Map<String, dynamic> json) {
    return ScrutinResultatsDto(
      pour: _asInt(json['pour']) ?? 0,
      contre: _asInt(json['contre']) ?? 0,
      abstention: _asInt(json['abstention']) ?? 0,
      nonVotant: _asInt(json['non_votant']) ?? 0,
      total: _asInt(json['total']) ?? 0,
    );
  }

  ScrutinResultats toDomain() {
    return ScrutinResultats(
      pour: pour,
      contre: contre,
      abstention: abstention,
      nonVotant: nonVotant,
      total: total,
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

class ScrutinGroupStatDto {
  const ScrutinGroupStatDto({
    required this.slug,
    required this.nom,
    required this.couleur,
    required this.pour,
    required this.contre,
    required this.abstention,
    required this.nonVotant,
    required this.total,
  });

  final String slug;
  final String nom;
  final String? couleur;
  final int pour;
  final int contre;
  final int abstention;
  final int nonVotant;
  final int total;

  factory ScrutinGroupStatDto.fromJson(Map<String, dynamic> json) {
    return ScrutinGroupStatDto(
      slug: (json['slug'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
      couleur: json['couleur'] as String?,
      pour: _asInt(json['pour']) ?? 0,
      contre: _asInt(json['contre']) ?? 0,
      abstention: _asInt(json['abstention']) ?? 0,
      nonVotant: _asInt(json['non_votant']) ?? 0,
      total: _asInt(json['total']) ?? 0,
    );
  }

  ScrutinGroupStat toDomain() {
    return ScrutinGroupStat(
      slug: slug,
      nom: nom,
      couleur: couleur,
      pour: pour,
      contre: contre,
      abstention: abstention,
      nonVotant: nonVotant,
      total: total,
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
