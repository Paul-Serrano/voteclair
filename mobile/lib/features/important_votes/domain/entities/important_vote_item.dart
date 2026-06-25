class ImportantVoteItem {
  const ImportantVoteItem({
    required this.id,
    required this.numero,
    required this.titre,
    required this.dateScrutin,
    required this.importanceScore,
    required this.sort,
  });

  final String id;
  final int numero;
  final String titre;
  final DateTime? dateScrutin;
  final int importanceScore;
  final String? sort;
}
