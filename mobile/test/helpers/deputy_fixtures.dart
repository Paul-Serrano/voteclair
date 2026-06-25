import 'package:voteclair_mobile/features/deputies/domain/entities/deputy.dart';
import 'package:voteclair_mobile/features/deputies/domain/entities/deputy_vote.dart';

const Deputy sampleDeputy = Deputy(
  slug: 'jean-dupont',
  nom: 'Dupont',
  prenom: 'Jean',
  photoUrl: null,
  groupName: 'Groupe Test',
  groupColor: '#00AAFF',
  profession: 'Ingenieur',
  circonscriptionName: 'Paris 1',
  departement: '75',
  departementName: 'Paris',
  twitter: '@jean',
  resumeIa: 'Resume court',
  parcoursIa: 'Parcours test',
  positionsClesIa: 'Position cle test',
  faitsNotablesIa: 'Fait notable test',
  statsPresence: 90,
  statsPresenceSolennel: 88,
  statsLoyaute: 80,
  statsParticipation: 75,
  statsInterventions: 12,
  statsAmendements: 30,
  statsAmendementsAdoptes: 6,
  statsQuestions: 14,
);

DeputyVote makeVote({
  required String id,
  required String title,
  required String position,
  required String sort,
  bool delegated = false,
}) {
  return DeputyVote(
    position: position,
    delegated: delegated,
    scrutin: DeputyVoteScrutin(
      id: id,
      numero: 101,
      titre: title,
      date: '2026-06-20',
      sort: sort,
      importanceScore: 120,
    ),
  );
}
