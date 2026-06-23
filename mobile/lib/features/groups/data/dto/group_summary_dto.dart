import '../../domain/entities/group_summary.dart';

class GroupSummaryDto {
  const GroupSummaryDto({
    required this.slug,
    required this.nom,
    required this.nomComplet,
    required this.membresCount,
    this.couleur,
    this.logoUrl,
    this.position,
  });

  final String slug;
  final String nom;
  final String nomComplet;
  final int membresCount;
  final String? couleur;
  final String? logoUrl;
  final String? position;

  factory GroupSummaryDto.fromJson(Map<String, dynamic> json) {
    return GroupSummaryDto(
      slug: (json['slug'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
      nomComplet: (json['nom_complet'] as String?) ?? '',
      membresCount: _asInt(json['membres_count']) ?? 0,
      couleur: json['couleur'] as String?,
      logoUrl: json['logo_url'] as String?,
      position: json['position'] as String?,
    );
  }

  GroupSummary toDomain() {
    return GroupSummary(
      slug: slug,
      nom: nom,
      nomComplet: nomComplet,
      membresCount: membresCount,
      couleur: couleur,
      logoUrl: logoUrl,
      position: position,
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
