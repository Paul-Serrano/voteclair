class DashboardGroup {
  const DashboardGroup({
    required this.slug,
    required this.nom,
    required this.couleur,
    required this.membersCount,
  });

  final String slug;
  final String nom;
  final String? couleur;
  final int membersCount;
}
