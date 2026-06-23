import '../../domain/entities/deputy.dart';

class DeputyDto {
  const DeputyDto({
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

  factory DeputyDto.fromJson(Map<String, dynamic> json) {
    final group = json['group'] as Map<String, dynamic>?;
    final circonscription = json['circonscription'] as Map<String, dynamic>?;
    final stats = json['stats'] as Map<String, dynamic>?;

    return DeputyDto(
      slug: (json['slug'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
      prenom: (json['prenom'] as String?) ?? '',
      photoUrl: json['photo_url'] as String?,
      groupName: group?['nom'] as String?,
      groupSlug: group?['slug'] as String?,
      groupColor: group?['couleur'] as String?,
      profession: json['profession'] as String?,
      circonscriptionName: circonscription?['nom'] as String?,
      departement: circonscription?['departement'] as String?,
      departementName: circonscription?['departement_name'] as String?,
      twitter: json['twitter'] as String?,
      resumeIa: json['resume_ia'] as String?,
      parcoursIa: json['parcours_ia'] as String?,
      positionsClesIa: json['positions_cles_ia'] as String?,
      faitsNotablesIa: json['faits_notables_ia'] as String?,
      statsPresence: _asInt(stats?['presence']),
      statsPresenceSolennel: _asInt(stats?['presence_solennel']),
      statsLoyaute: _asInt(stats?['loyaute']),
      statsParticipation: _asInt(stats?['participation']),
      statsInterventions: _asInt(stats?['interventions']),
      statsAmendements: _asInt(stats?['amendements']),
      statsAmendementsAdoptes: _asInt(stats?['amendements_adoptes']),
      statsQuestions: _asInt(stats?['questions']),
    );
  }

  Deputy toDomain() {
    return Deputy(
      slug: slug,
      nom: nom,
      prenom: prenom,
      photoUrl: photoUrl,
      groupName: groupName,
      groupSlug: groupSlug,
      groupColor: groupColor,
      profession: profession,
      circonscriptionName: circonscriptionName,
      departement: departement,
      departementName: departementName,
      twitter: twitter,
      resumeIa: resumeIa,
      parcoursIa: parcoursIa,
      positionsClesIa: positionsClesIa,
      faitsNotablesIa: faitsNotablesIa,
      statsPresence: statsPresence,
      statsPresenceSolennel: statsPresenceSolennel,
      statsLoyaute: statsLoyaute,
      statsParticipation: statsParticipation,
      statsInterventions: statsInterventions,
      statsAmendements: statsAmendements,
      statsAmendementsAdoptes: statsAmendementsAdoptes,
      statsQuestions: statsQuestions,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
