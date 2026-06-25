class Deputy {
  const Deputy({
    required this.slug,
    required this.nom,
    required this.prenom,
    required this.photoUrl,
    required this.groupName,
    this.groupSlug,
    this.groupColor,
    this.profession,
    this.circonscriptionName,
    this.departement,
    this.departementName,
    this.twitter,
    this.resumeIa,
    this.parcoursIa,
    this.positionsClesIa,
    this.faitsNotablesIa,
    this.statsPresence,
    this.statsPresenceSolennel,
    this.statsLoyaute,
    this.statsParticipation,
    this.statsInterventions,
    this.statsAmendements,
    this.statsAmendementsAdoptes,
    this.statsQuestions,
    this.mostFrequentVote,
    this.mostFrequentVoteCount,
    this.groupProximityRate,
    this.groupProximityVotesCount,
    this.topTopics = const <DeputyTopicStat>[],
    this.politicalPresenceRate,
    this.politicalLoyaltyRate,
  });

  final String slug;
  final String nom;
  final String prenom;
  final String? photoUrl;
  final String? groupName;
  final String? groupSlug;
  final String? groupColor;
  final String? profession;
  final String? circonscriptionName;
  final String? departement;
  final String? departementName;
  final String? twitter;
  final String? resumeIa;
  final String? parcoursIa;
  final String? positionsClesIa;
  final String? faitsNotablesIa;
  final int? statsPresence;
  final int? statsPresenceSolennel;
  final int? statsLoyaute;
  final int? statsParticipation;
  final int? statsInterventions;
  final int? statsAmendements;
  final int? statsAmendementsAdoptes;
  final int? statsQuestions;
  final String? mostFrequentVote;
  final int? mostFrequentVoteCount;
  final double? groupProximityRate;
  final int? groupProximityVotesCount;
  final List<DeputyTopicStat> topTopics;
  final int? politicalPresenceRate;
  final int? politicalLoyaltyRate;

  String get fullName => '$prenom $nom'.trim();
}

class DeputyTopicStat {
  const DeputyTopicStat({
    required this.label,
    required this.count,
  });

  final String label;
  final int count;
}
