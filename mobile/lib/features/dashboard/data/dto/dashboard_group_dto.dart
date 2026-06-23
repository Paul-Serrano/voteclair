import '../../domain/entities/dashboard_group.dart';

class DashboardGroupDto {
  const DashboardGroupDto({
    required this.slug,
    required this.nom,
    required this.couleur,
    this.membersCount = 0,
  });

  final String slug;
  final String nom;
  final String? couleur;
  final int membersCount;

  factory DashboardGroupDto.fromJson(Map<String, dynamic> json) {
    return DashboardGroupDto(
      slug: (json['slug'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
      couleur: json['couleur'] as String?,
      membersCount: (json['members_count'] as num?)?.toInt() ?? 0,
    );
  }

  DashboardGroup toDomain() {
    return DashboardGroup(
      slug: slug,
      nom: nom,
      couleur: couleur,
      membersCount: membersCount,
    );
  }
}
