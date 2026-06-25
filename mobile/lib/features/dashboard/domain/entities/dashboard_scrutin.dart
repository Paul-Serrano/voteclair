class DashboardScrutin {
  const DashboardScrutin({
    required this.id,
    required this.numero,
    required this.titre,
    required this.date,
    required this.sort,
    required this.importanceScore,
  });

  final String id;
  final int numero;
  final String titre;
  final DateTime date;
  final String sort;
  final int importanceScore;
}
