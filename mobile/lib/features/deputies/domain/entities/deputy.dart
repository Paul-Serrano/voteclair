class Deputy {
  const Deputy({
    required this.slug,
    required this.nom,
    required this.prenom,
    required this.photoUrl,
    required this.groupName,
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
  });

  final String slug;
  final String nom;
  final String prenom;
  final String? photoUrl;
  final String? groupName;
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

  String get fullName => '$prenom $nom'.trim();
}
