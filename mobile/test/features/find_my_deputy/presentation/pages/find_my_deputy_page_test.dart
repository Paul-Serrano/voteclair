import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voteclair_mobile/features/find_my_deputy/domain/entities/find_my_deputy_result.dart';
import 'package:voteclair_mobile/features/find_my_deputy/domain/repositories/find_my_deputy_repository.dart';
import 'package:voteclair_mobile/features/find_my_deputy/presentation/pages/find_my_deputy_page.dart';
import 'package:voteclair_mobile/features/find_my_deputy/presentation/providers/find_my_deputy_provider.dart';

void main() {
  group('FindMyDeputyPage', () {
    testWidgets('searches a postal code and shows the deputy result', (tester) async {
      final repository = _FakeFindMyDeputyRepository(
        result: _sampleResult(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            findMyDeputyRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(home: FindMyDeputyPage()),
        ),
      );

      expect(find.text('Entrez votre code postal.'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), '75001');
      await tester.enterText(find.byType(TextField).at(1), 'inst-an');
      await tester.tap(find.widgetWithText(FilledButton, 'Trouver mon député'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(repository.lastPostalCode, '75001');
      expect(repository.lastInstitutionId, 'inst-an');
      expect(find.text('Résultat'), findsOneWidget);
      expect(find.text('Jean Dupont'), findsOneWidget);
      expect(find.text('Profession indisponible'), findsNothing);
      expect(find.text('5 derniers votes'), findsOneWidget);
      expect(find.text('Loi Climat'), findsOneWidget);
      expect(find.text('Voir la fiche député'), findsOneWidget);
    });

    testWidgets('shows a validation message for an invalid postal code', (tester) async {
      final repository = _FakeFindMyDeputyRepository(result: _sampleResult());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            findMyDeputyRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(home: FindMyDeputyPage()),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), '75');
      await tester.tap(find.widgetWithText(FilledButton, 'Trouver mon député'));
      await tester.pumpAndSettle();

      expect(find.text('Entrez un code postal à 5 chiffres.'), findsOneWidget);
    });
  });
}

class _FakeFindMyDeputyRepository implements FindMyDeputyRepository {
  _FakeFindMyDeputyRepository({required this.result});

  final FindMyDeputyResult result;
  String? lastPostalCode;
  String? lastInstitutionId;

  @override
  Future<FindMyDeputyResult> findByPostalCode({
    required String postalCode,
    String? institutionId,
  }) async {
    lastPostalCode = postalCode;
    lastInstitutionId = institutionId;
    return result;
  }
}

FindMyDeputyResult _sampleResult() {
  return FindMyDeputyResult(
    postalCode: '75001',
    institution: const FindMyDeputyInstitution(id: 'inst-an', nom: 'Assemblee nationale'),
    circonscription: const FindMyDeputyCirconscription(id: 'cir-1', nom: 'Paris 1'),
    deputies: [
      FindMyDeputyDeputy(
        slug: 'jean-dupont',
        prenom: 'Jean',
        nom: 'Dupont',
        photoUrl: null,
        profession: 'Ingenieur',
        statsPresence: 91,
        statsLoyaute: 84,
        statsParticipation: 123,
        group: const FindMyDeputyGroup(slug: 'centre', nom: 'Centre', couleur: '#00AAFF'),
        latestVotes: [
          const FindMyDeputyVote(
            scrutinId: 'scr-1',
            position: 'POUR',
            delegated: false,
            scrutin: FindMyDeputyScrutin(
              id: 'scr-1',
              numero: 100,
              titre: 'Loi Climat',
              date: '2026-06-10',
              sort: 'ADOPTE',
              importanceScore: 110,
            ),
          ),
          const FindMyDeputyVote(
            scrutinId: 'scr-2',
            position: 'CONTRE',
            delegated: false,
            scrutin: FindMyDeputyScrutin(
              id: 'scr-2',
              numero: 101,
              titre: 'Budget Defense',
              date: '2026-06-11',
              sort: 'REJETE',
              importanceScore: 170,
            ),
          ),
        ],
      ),
    ],
  );
}