class FindMyDeputyResult {
  const FindMyDeputyResult({
    required this.postalCode,
    required this.deputies,
    this.institution,
    this.circonscription,
  });

  final String postalCode;
  final FindMyDeputyInstitution? institution;
  final FindMyDeputyCirconscription? circonscription;
  final List<FindMyDeputyDeputy> deputies;

  bool get isEmpty => deputies.isEmpty;
}

class FindMyDeputyInstitution {
  const FindMyDeputyInstitution({
    required this.id,
    required this.nom,
  });

  final String id;
  final String nom;
}

class FindMyDeputyCirconscription {
  const FindMyDeputyCirconscription({
    required this.id,
    required this.nom,
  });

  final String id;
  final String nom;
}

class FindMyDeputyDeputy {
  const FindMyDeputyDeputy({
    required this.slug,
    required this.prenom,
    required this.nom,
    required this.latestVotes,
    this.photoUrl,
    this.profession,
    this.statsPresence,
    this.statsLoyaute,
    this.statsParticipation,
    this.group,
  });

  final String slug;
  final String prenom;
  final String nom;
  final String? photoUrl;
  final String? profession;
  final int? statsPresence;
  final int? statsLoyaute;
  final int? statsParticipation;
  final FindMyDeputyGroup? group;
  final List<FindMyDeputyVote> latestVotes;

  String get fullName => '$prenom $nom'.trim();
}

class FindMyDeputyGroup {
  const FindMyDeputyGroup({
    required this.nom,
    this.slug,
    this.couleur,
  });

  final String? slug;
  final String nom;
  final String? couleur;
}

class FindMyDeputyVote {
  const FindMyDeputyVote({
    required this.scrutinId,
    required this.position,
    required this.delegated,
    required this.scrutin,
  });

  final String scrutinId;
  final String position;
  final bool delegated;
  final FindMyDeputyScrutin scrutin;
}

class FindMyDeputyScrutin {
  const FindMyDeputyScrutin({
    required this.id,
    required this.numero,
    required this.titre,
    required this.sort,
    required this.importanceScore,
    this.date,
  });

  final String id;
  final int? numero;
  final String titre;
  final String? date;
  final String? sort;
  final int importanceScore;
}