import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voteclair_mobile/features/deputies/domain/entities/deputy.dart';
import 'package:voteclair_mobile/features/deputies/domain/entities/deputy_vote.dart';
import 'package:voteclair_mobile/features/deputies/domain/entities/paginated_votes.dart';
import 'package:voteclair_mobile/features/deputies/domain/repositories/deputy_repository.dart';
import 'package:voteclair_mobile/features/deputies/presentation/pages/deputy_votes_page.dart';
import 'package:voteclair_mobile/features/deputies/presentation/providers/deputies_provider.dart';

import '../../../../helpers/deputy_fixtures.dart';
import '../../../../helpers/fake_deputy_repository.dart';

void main() {
  group('DeputyVotesPage', () {
    testWidgets('shows loading then votes and filters locally by scrutin title',
        (tester) async {
      final repository = FakeDeputyRepository(
        deputies: const <Deputy>[sampleDeputy],
        deputyBySlug: const <String, Deputy>{'jean-dupont': sampleDeputy},
        votesBySlugAndPage: <String, Map<int, PaginatedVotes>>{
          'jean-dupont': <int, PaginatedVotes>{
            1: PaginatedVotes(
              votes: <DeputyVote>[
                makeVote(
                    id: 'v1',
                    title: 'Budget 2026',
                    position: 'POUR',
                    sort: 'ADOPTE'),
                makeVote(
                    id: 'v2',
                    title: 'Loi Climat',
                    position: 'CONTRE',
                    sort: 'REJETE'),
              ],
              currentPage: 1,
              lastPage: 1,
            ),
          },
        },
        getVotesDelay: const Duration(milliseconds: 50),
      );

      await _pumpPage(tester, repository);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Budget 2026'), findsOneWidget);
      expect(find.text('Loi Climat'), findsOneWidget);

      await tester.enterText(find.byType(SearchBar), 'climat');
      await tester.pumpAndSettle();

      expect(find.text('Budget 2026'), findsNothing);
      expect(find.text('Loi Climat'), findsOneWidget);
    });

    testWidgets('shows empty state when no votes are returned', (tester) async {
      final repository = FakeDeputyRepository(
        deputies: const <Deputy>[sampleDeputy],
        deputyBySlug: const <String, Deputy>{'jean-dupont': sampleDeputy},
        votesBySlugAndPage: <String, Map<int, PaginatedVotes>>{
          'jean-dupont': <int, PaginatedVotes>{
            1: const PaginatedVotes(
              votes: <DeputyVote>[],
              currentPage: 1,
              lastPage: 1,
            ),
          },
        },
      );

      await _pumpPage(tester, repository);
      await tester.pumpAndSettle();

      expect(find.text('Aucun vote trouve.'), findsOneWidget);
    });

    testWidgets('shows error state when initial load fails', (tester) async {
      final repository = FakeDeputyRepository(
        deputies: const <Deputy>[sampleDeputy],
        deputyBySlug: const <String, Deputy>{'jean-dupont': sampleDeputy},
        throwOnGetVotes: true,
      );

      await _pumpPage(tester, repository);
      await tester.pumpAndSettle();

      expect(find.text('Impossible de charger les votes.'), findsOneWidget);
      expect(find.text('Reessayer'), findsOneWidget);
    });
  });
}

Future<void> _pumpPage(WidgetTester tester, DeputyRepository repository) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        deputyRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: DeputyVotesPage(slug: 'jean-dupont'),
      ),
    ),
  );
}
