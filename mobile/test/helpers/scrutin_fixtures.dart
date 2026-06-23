import 'package:voteclair_mobile/features/scrutins/domain/entities/paginated_votes.dart';
import 'package:voteclair_mobile/features/scrutins/domain/entities/scrutin.dart';
import 'package:voteclair_mobile/features/scrutins/domain/entities/scrutin_vote.dart';

const sampleScrutin = Scrutin(
  id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  numero: 100,
  date: '2026-06-10',
  titre: 'Loi Climat',
  sort: 'ADOPTE',
  institution: ScrutinInstitution(
    id: 'inst-an',
    slug: 'assemblee-nationale',
    nom: 'Assemblée nationale',
    pays: 'France',
  ),
  resumeIa: 'Résumé Climat',
  demandeurTexte: 'Gouvernement',
  sourceUrl: 'https://example.test/scrutins/100',
  dossierTitre: 'Projet de loi Climat',
  dossierUrl: 'https://example.test/dossiers/climat',
  resultats: ScrutinResultats(
    pour: 85,
    contre: 180,
    abstention: 11,
    nonVotant: 0,
    total: 276,
  ),
  groupes: <ScrutinGroupStat>[
    ScrutinGroupStat(
      slug: 'g-centre',
      nom: 'Groupe du Centre',
      couleur: '#00AAFF',
      pour: 1,
      contre: 0,
      abstention: 1,
      nonVotant: 0,
      total: 2,
    ),
    ScrutinGroupStat(
      slug: 'g-gauche',
      nom: 'Groupe de Gauche',
      couleur: '#FF3366',
      pour: 0,
      contre: 1,
      abstention: 0,
      nonVotant: 0,
      total: 1,
    ),
  ],
);

const sampleScrutinWithDifferentResult = Scrutin(
  id: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  numero: 101,
  date: '2026-06-20',
  titre: 'Budget Defense',
  sort: 'REJETE',
  institution: ScrutinInstitution(
    id: 'inst-an',
    slug: 'assemblee-nationale',
    nom: 'Assemblée nationale',
    pays: 'France',
  ),
  resumeIa: 'Résumé Budget',
  demandeurTexte: 'Commission',
  sourceUrl: 'https://example.test/scrutins/101',
  dossierTitre: 'Projet Budget Defense',
  dossierUrl: 'https://example.test/dossiers/budget-defense',
  resultats: ScrutinResultats(
    pour: 5,
    contre: 261,
    abstention: 7,
    nonVotant: 0,
    total: 273,
  ),
);

ScrutinVote makeScrutinVote({
  required String position,
  required String deputySlug,
  required String nom,
  required String prenom,
  String? groupName,
  String? groupColor,
  bool delegated = false,
}) {
  return ScrutinVote(
    position: position,
    delegated: delegated,
    deputy: ScrutinVoteDeputy(
      slug: deputySlug,
      nom: nom,
      prenom: prenom,
      groupName: groupName,
      groupColor: groupColor,
    ),
  );
}

PaginatedVotes sampleScrutinVotesPage1() {
  return PaginatedVotes(
    votes: <ScrutinVote>[
      makeScrutinVote(
        position: 'POUR',
        deputySlug: 'jean-dupont',
        nom: 'Dupont',
        prenom: 'Jean',
        groupName: 'Groupe du Centre',
      ),
      makeScrutinVote(
        position: 'CONTRE',
        deputySlug: 'marie-durand',
        nom: 'Durand',
        prenom: 'Marie',
        groupName: 'Groupe de Gauche',
        delegated: true,
      ),
      makeScrutinVote(
        position: 'ABSTENTION',
        deputySlug: 'paul-martin',
        nom: 'Martin',
        prenom: 'Paul',
        groupName: 'Groupe du Centre',
      ),
    ],
    currentPage: 1,
    lastPage: 1,
  );
}
