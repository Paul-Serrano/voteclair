class ScrutinVote {
  const ScrutinVote({
    required this.position,
    required this.delegated,
    required this.deputy,
  });

  final String position;
  final bool delegated;
  final ScrutinVoteDeputy deputy;
}

class ScrutinVoteDeputy {
  const ScrutinVoteDeputy({
    required this.slug,
    required this.nom,
    required this.prenom,
    this.groupName,
    this.groupColor,
  });

  final String slug;
  final String nom;
  final String prenom;
  final String? groupName;
  final String? groupColor;

  String get fullName => '$prenom $nom'.trim();
}
