import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voteclair_mobile/features/scrutins/domain/entities/paginated_votes.dart';
import 'package:voteclair_mobile/features/scrutins/presentation/pages/scrutin_details_page.dart';
import 'package:voteclair_mobile/features/scrutins/presentation/providers/scrutin_details_provider.dart';

import '../../../../helpers/fake_scrutin_repository.dart';
import '../../../../helpers/scrutin_fixtures.dart';

void main() {
  group('ScrutinDetailsPage', () {
    testWidgets('shows loading then renders scrutin details and filters votes',
        (tester) async {
      final repository = FakeScrutinRepository(
        scrutinById: const {'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa': sampleScrutin},
        votesByScrutinAndPage: <String, Map<int, PaginatedVotes>>{
          'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa': <int, PaginatedVotes>{
            1: sampleScrutinVotesPage1(),
          },
        },
        getByIdDelay: const Duration(milliseconds: 50),
        getVotesDelay: const Duration(milliseconds: 50),
      );

      await _pumpPage(tester, repository);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Detail scrutin'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(find.text('Votes par groupe'), findsOneWidget);
      expect(find.text('Groupe du Centre'), findsOneWidget);
    });

    testWidgets('shows empty state when scrutin has no votes', (tester) async {
      final repository = FakeScrutinRepository(
        scrutinById: const {'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa': sampleScrutin},
        votesByScrutinAndPage: <String, Map<int, PaginatedVotes>>{
          'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa': <int, PaginatedVotes>{
            1: const PaginatedVotes(votes: [], currentPage: 1, lastPage: 1),
          },
        },
      );

      await _pumpPage(tester, repository);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Votes par députés'));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.text('Aucun vote trouvé.'), findsOneWidget);
    });

    testWidgets('shows error state when scrutin load fails', (tester) async {
      final repository = FakeScrutinRepository(
        throwOnGetById: true,
      );

      await _pumpPage(tester, repository);
      await tester.pumpAndSettle();

      expect(find.text('Impossible de charger ce scrutin.'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });
  });
}

Future<void> _pumpPage(WidgetTester tester, FakeScrutinRepository repository) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        scrutinRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: ScrutinDetailsPage(scrutinId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'),
      ),
    ),
  );
}
