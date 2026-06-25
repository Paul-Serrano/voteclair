import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voteclair_mobile/features/deputies/presentation/pages/deputy_details_page.dart';
import 'package:voteclair_mobile/features/deputies/presentation/providers/deputies_provider.dart';

import '../../../../helpers/deputy_fixtures.dart';
import '../../../../helpers/fake_deputy_repository.dart';

void main() {
  group('DeputyDetailsPage', () {
    testWidgets('shows loading then renders details and actions',
        (tester) async {
      final repository = FakeDeputyRepository(
        deputies: const [sampleDeputy],
        deputyBySlug: const {'jean-dupont': sampleDeputy},
        getBySlugDelay: const Duration(milliseconds: 50),
      );

      await _pumpPage(tester, repository);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();

      expect(find.text('Fiche depute'), findsOneWidget);
      expect(find.text('Jean'), findsOneWidget);
      expect(find.text('Dupont'), findsOneWidget);
      expect(find.text('Informations generales'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Voir les votes'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(find.text('Voir les votes'), findsOneWidget);
    });

    testWidgets('shows error state when details loading fails', (tester) async {
      final repository = FakeDeputyRepository(
        throwOnGetBySlug: true,
      );

      await _pumpPage(tester, repository);
      await tester.pumpAndSettle();

      expect(find.text('Impossible de charger ce depute.'), findsOneWidget);
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
        home: DeputyDetailsPage(slug: 'jean-dupont'),
      ),
    ),
  );
}
