import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voteclair_mobile/features/deputies/presentation/deputies_list_page.dart';
import 'package:voteclair_mobile/features/deputies/presentation/providers/deputies_provider.dart';

import '../../../../helpers/deputy_fixtures.dart';
import '../../../../helpers/fake_deputy_repository.dart';

void main() {
  group('DeputiesListPage', () {
    testWidgets('shows loading then displays deputies list', (tester) async {
      final repository = FakeDeputyRepository(
        deputies: const [sampleDeputy],
        fetchDeputiesDelay: const Duration(milliseconds: 50),
      );

      await _pumpPage(tester, repository);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Dupont'), findsOneWidget);
      expect(find.text('Jean\nGroupe Test'), findsOneWidget);
    });

    testWidgets('shows empty state when repository returns no deputies',
        (tester) async {
      final repository = FakeDeputyRepository(deputies: const []);

      await _pumpPage(tester, repository);
      await tester.pumpAndSettle();

      expect(find.text('Aucun depute trouve.'), findsOneWidget);
    });

    testWidgets('shows error state when repository throws', (tester) async {
      final repository = FakeDeputyRepository(throwOnFetchDeputies: true);

      await _pumpPage(tester, repository);
      await tester.pumpAndSettle();

      expect(find.text('Impossible de charger les deputes.'), findsOneWidget);
      expect(find.text('Reessayer'), findsOneWidget);
    });
  });
}

Future<void> _pumpPage(WidgetTester tester, FakeDeputyRepository repository) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        deputyRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: DeputiesListPage(),
      ),
    ),
  );
}
