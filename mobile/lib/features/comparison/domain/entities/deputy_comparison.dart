class ComparedDeputy {
  const ComparedDeputy({
    required this.slug,
    required this.prenom,
    required this.nom,
  });

  final String slug;
  final String prenom;
  final String nom;

  String get fullName => '$prenom $nom'.trim();
}

class ComparisonStats {
  const ComparisonStats({
    required this.commonVotes,
    required this.agreements,
    required this.disagreements,
    required this.sameAbstentions,
    required this.agreementRate,
  });

  final int commonVotes;
  final int agreements;
  final int disagreements;
  final int sameAbstentions;
  final double agreementRate;
}

class ComparisonDifference {
  const ComparisonDifference({
    required this.scrutinId,
    required this.numero,
    required this.titre,
    required this.importanceScore,
    required this.leftVote,
    required this.rightVote,
    this.scrutinSort,
    this.date,
  });

  final String scrutinId;
  final int numero;
  final String titre;
  final int importanceScore;
  final String leftVote;
  final String rightVote;
  final String? scrutinSort;
  final DateTime? date;
}

class DeputyComparison {
  const DeputyComparison({
    required this.left,
    required this.right,
    required this.stats,
    this.recentCommonVotes = const <ComparisonDifference>[],
    this.recentDifferences = const <ComparisonDifference>[],
  });

  final ComparedDeputy left;
  final ComparedDeputy right;
  final ComparisonStats stats;
  final List<ComparisonDifference> recentCommonVotes;
  final List<ComparisonDifference> recentDifferences;
}
