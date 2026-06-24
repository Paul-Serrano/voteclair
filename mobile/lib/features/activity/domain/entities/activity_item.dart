class ActivityItem {
  const ActivityItem({
    required this.deputy,
    required this.latestVote,
  });

  final ActivityDeputy deputy;
  final ActivityVote latestVote;
}

class ActivityDeputy {
  const ActivityDeputy({
    required this.slug,
    required this.nom,
    required this.prenom,
    required this.photoUrl,
  });

  final String slug;
  final String nom;
  final String prenom;
  final String? photoUrl;

  String get fullName => '$prenom $nom'.trim();
}

class ActivityVote {
  const ActivityVote({
    required this.id,
    required this.position,
    required this.scrutin,
  });

  final String id;
  final String position;
  final ActivityScrutin scrutin;
}

class ActivityScrutin {
  const ActivityScrutin({
    required this.id,
    required this.titre,
    required this.date,
  });

  final String id;
  final String titre;
  final DateTime? date;
}
