import '../../domain/entities/deputy_comparison.dart';

class DeputyComparisonDto {
  const DeputyComparisonDto({
    required this.left,
    required this.right,
    required this.stats,
    required this.recentCommonVotes,
    required this.recentDifferences,
  });

  final ComparedDeputyDto left;
  final ComparedDeputyDto right;
  final ComparisonStatsDto stats;
  final List<ComparisonDifferenceDto> recentCommonVotes;
  final List<ComparisonDifferenceDto> recentDifferences;

  factory DeputyComparisonDto.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;

    return DeputyComparisonDto(
      left: ComparedDeputyDto.fromJson((data['left'] as Map<String, dynamic>?) ?? const {}),
      right: ComparedDeputyDto.fromJson((data['right'] as Map<String, dynamic>?) ?? const {}),
      stats: ComparisonStatsDto.fromJson((data['stats'] as Map<String, dynamic>?) ?? const {}),
        recentCommonVotes: (data['recent_common_votes'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(ComparisonDifferenceDto.fromJson)
          .toList(growable: false),
      recentDifferences: (data['recent_differences'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(ComparisonDifferenceDto.fromJson)
          .toList(growable: false),
    );
  }

  DeputyComparison toDomain() {
    return DeputyComparison(
      left: left.toDomain(),
      right: right.toDomain(),
      stats: stats.toDomain(),
      recentCommonVotes: recentCommonVotes.map((item) => item.toDomain()).toList(growable: false),
      recentDifferences: recentDifferences.map((item) => item.toDomain()).toList(growable: false),
    );
  }
}

class ComparedDeputyDto {
  const ComparedDeputyDto({
    required this.slug,
    required this.prenom,
    required this.nom,
  });

  final String slug;
  final String prenom;
  final String nom;

  factory ComparedDeputyDto.fromJson(Map<String, dynamic> json) {
    return ComparedDeputyDto(
      slug: (json['slug'] as String?) ?? '',
      prenom: (json['prenom'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
    );
  }

  ComparedDeputy toDomain() {
    return ComparedDeputy(slug: slug, prenom: prenom, nom: nom);
  }
}

class ComparisonStatsDto {
  const ComparisonStatsDto({
    required this.commonVotes,
    required this.agreements,
    required this.disagreements,
    required this.sameAbstentions,
    required this.agreementRate,
  });

  final int commonVotes;
  final int agreements;
  final int disagreements;
  final int sameAbstentions;
  final double agreementRate;

  factory ComparisonStatsDto.fromJson(Map<String, dynamic> json) {
    return ComparisonStatsDto(
      commonVotes: _asInt(json['common_votes']) ?? 0,
      agreements: _asInt(json['agreements']) ?? 0,
      disagreements: _asInt(json['disagreements']) ?? 0,
      sameAbstentions: _asInt(json['same_abstentions']) ?? 0,
      agreementRate: _asDouble(json['agreement_rate']) ?? 0,
    );
  }

  ComparisonStats toDomain() {
    return ComparisonStats(
      commonVotes: commonVotes,
      agreements: agreements,
      disagreements: disagreements,
      sameAbstentions: sameAbstentions,
      agreementRate: agreementRate,
    );
  }
}

class ComparisonDifferenceDto {
  const ComparisonDifferenceDto({
    required this.scrutinId,
    required this.numero,
    required this.titre,
    required this.importanceScore,
    required this.leftVote,
    required this.rightVote,
    this.scrutinSort,
    this.date,
  });

  final String scrutinId;
  final int numero;
  final String titre;
  final int importanceScore;
  final String leftVote;
  final String rightVote;
  final String? scrutinSort;
  final String? date;

  factory ComparisonDifferenceDto.fromJson(Map<String, dynamic> json) {
    return ComparisonDifferenceDto(
      scrutinId: (json['scrutin_id'] as String?) ?? '',
      numero: _asInt(json['numero']) ?? 0,
      titre: (json['titre'] as String?) ?? '',
      importanceScore: _asInt(json['importance_score']) ?? 0,
      leftVote: (json['left_vote'] as String?) ?? '',
      rightVote: (json['right_vote'] as String?) ?? '',
      scrutinSort: json['scrutin_sort'] as String?,
      date: json['date'] as String?,
    );
  }

  ComparisonDifference toDomain() {
    return ComparisonDifference(
      scrutinId: scrutinId,
      numero: numero,
      titre: titre,
      importanceScore: importanceScore,
      leftVote: leftVote,
      rightVote: rightVote,
      scrutinSort: scrutinSort,
      date: date != null ? DateTime.tryParse(date!) : null,
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

double? _asDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}
