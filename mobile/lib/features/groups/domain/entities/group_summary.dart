class GroupSummary {
  const GroupSummary({
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
}
