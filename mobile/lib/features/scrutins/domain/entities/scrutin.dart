class Scrutin {
  const Scrutin({
    required this.id,
    required this.numero,
    required this.date,
    required this.titre,
    required this.sort,
    required this.importanceScore,
    required this.resultats,
    this.groupes = const <ScrutinGroupStat>[],
    this.institution,
    this.resumeIa,
    this.demandeurTexte,
    this.sourceUrl,
    this.dossierTitre,
    this.dossierUrl,
  });

  final String id;
  final int? numero;
  final String? date;
  final String titre;
  final String? sort;
  final int importanceScore;
  final ScrutinInstitution? institution;
  final String? resumeIa;
  final String? demandeurTexte;
  final String? sourceUrl;
  final String? dossierTitre;
  final String? dossierUrl;
  final ScrutinResultats resultats;
  final List<ScrutinGroupStat> groupes;
}

class ScrutinInstitution {
  const ScrutinInstitution({
    required this.id,
    required this.slug,
    required this.nom,
    required this.pays,
  });

  final String id;
  final String slug;
  final String nom;
  final String pays;
}

class ScrutinResultats {
  const ScrutinResultats({
    required this.pour,
    required this.contre,
    required this.abstention,
    required this.nonVotant,
    required this.total,
  });

  final int pour;
  final int contre;
  final int abstention;
  final int nonVotant;
  final int total;
}

class ScrutinGroupStat {
  const ScrutinGroupStat({
    required this.slug,
    required this.nom,
    required this.pour,
    required this.contre,
    required this.abstention,
    required this.nonVotant,
    required this.total,
    this.couleur,
  });

  final String slug;
  final String nom;
  final String? couleur;
  final int pour;
  final int contre;
  final int abstention;
  final int nonVotant;
  final int total;
}
