class DeputyVote {
  const DeputyVote({
    required this.position,
    required this.delegated,
    required this.scrutin,
  });

  final String position;
  final bool delegated;
  final DeputyVoteScrutin scrutin;
}

class DeputyVoteScrutin {
  const DeputyVoteScrutin({
    required this.id,
    required this.numero,
    required this.titre,
    required this.date,
    required this.sort,
  });

  final String id;
  final int? numero;
  final String titre;
  final String? date;
  final String? sort;
}
