import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voteclair_mobile/features/comparison/domain/entities/deputy_comparison.dart';
import 'package:voteclair_mobile/features/comparison/domain/repositories/comparison_repository.dart';
import 'package:voteclair_mobile/features/comparison/presentation/pages/comparison_page.dart';
import 'package:voteclair_mobile/features/comparison/presentation/providers/comparison_provider.dart';
import 'package:voteclair_mobile/features/search/domain/entities/search_results.dart';
import 'package:voteclair_mobile/features/search/domain/repositories/search_repository.dart';

void main() {
  group('ComparisonPage', () {
    testWidgets('prefills left deputy from initial route parameters', (tester) async {
      final container = ProviderContainer(
        overrides: [
          comparisonRepositoryProvider.overrideWithValue(_FakeComparisonRepository(_sampleComparison())),
          comparisonSearchRepositoryProvider.overrideWithValue(const _FakeSearchRepository()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ComparisonPage(
              initialLeftSlug: 'jean-dupont',
              initialLeftPrenom: 'Jean',
              initialLeftNom: 'Dupont',
              initialLeftGroup: 'Centre',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Jean Dupont (Centre)'), findsOneWidget);
    });

    test('notifier compare stores result with common and disagreement votes', () async {
      final container = ProviderContainer(
        overrides: [
          comparisonRepositoryProvider.overrideWithValue(_FakeComparisonRepository(_sampleComparison())),
          comparisonSearchRepositoryProvider.overrideWithValue(const _FakeSearchRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(comparisonProvider.notifier);
      notifier.setLeftDeputy(
        const SearchDeputyResult(
          slug: 'jean-dupont',
          prenom: 'Jean',
          nom: 'Dupont',
          group: 'Centre',
        ),
      );
      notifier.setRightDeputy(
        const SearchDeputyResult(
          slug: 'marie-durand',
          prenom: 'Marie',
          nom: 'Durand',
          group: 'Gauche',
        ),
      );

      await notifier.compare();

      final loadedState = container.read(comparisonProvider);
      expect(loadedState.errorMessage, isNull);
      expect(loadedState.result, isNotNull);
      expect(loadedState.result!.recentCommonVotes.length, 2);
      expect(loadedState.result!.recentDifferences.length, 1);
    });
  });
}

class _FakeComparisonRepository implements ComparisonRepository {
  _FakeComparisonRepository(this.result);

  final DeputyComparison result;

  @override
  Future<DeputyComparison> compare({
    required String leftSlug,
    required String rightSlug,
  }) async {
    return result;
  }
}

class _FakeSearchRepository implements SearchRepository {
  const _FakeSearchRepository();

  @override
  Future<SearchResults> search(String query) async {
    return const SearchResults();
  }
}

DeputyComparison _sampleComparison() {
  return const DeputyComparison(
    left: ComparedDeputy(slug: 'jean-dupont', prenom: 'Jean', nom: 'Dupont'),
    right: ComparedDeputy(slug: 'marie-durand', prenom: 'Marie', nom: 'Durand'),
    stats: ComparisonStats(
      commonVotes: 2,
      agreements: 1,
      disagreements: 1,
      sameAbstentions: 0,
      agreementRate: 50,
    ),
    recentCommonVotes: [
      ComparisonDifference(
        scrutinId: 'scr-2',
        numero: 102,
        titre: 'Scrutin accord',
        importanceScore: 120,
        leftVote: 'POUR',
        rightVote: 'POUR',
        scrutinSort: 'ADOPTE',
      ),
      ComparisonDifference(
        scrutinId: 'scr-1',
        numero: 101,
        titre: 'Scrutin divergence',
        importanceScore: 150,
        leftVote: 'POUR',
        rightVote: 'CONTRE',
        scrutinSort: 'REJETE',
      ),
    ],
    recentDifferences: [
      ComparisonDifference(
        scrutinId: 'scr-1',
        numero: 101,
        titre: 'Scrutin divergence',
        importanceScore: 150,
        leftVote: 'POUR',
        rightVote: 'CONTRE',
        scrutinSort: 'REJETE',
      ),
    ],
  );
}
