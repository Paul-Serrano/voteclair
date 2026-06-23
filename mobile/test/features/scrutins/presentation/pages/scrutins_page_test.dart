import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voteclair_mobile/features/scrutins/domain/entities/paginated_scrutins.dart';
import 'package:voteclair_mobile/features/scrutins/presentation/scrutins_page.dart';
import 'package:voteclair_mobile/features/scrutins/presentation/providers/scrutins_provider.dart';

import '../../../../helpers/fake_scrutin_repository.dart';
import '../../../../helpers/scrutin_fixtures.dart';

void main() {
  testWidgets('renders loaded scrutins list', (tester) async {
    final repository = FakeScrutinRepository(
      scrutinsByPage: {
        1: const PaginatedScrutins(
          scrutins: [sampleScrutin, sampleScrutinWithDifferentResult],
          currentPage: 1,
          lastPage: 1,
        ),
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scrutinRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: ScrutinsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Loi Climat'), findsOneWidget);
    expect(find.text('Budget Defense'), findsOneWidget);
    expect(find.text('Adopté'), findsOneWidget);
    expect(find.text('Rejeté'), findsOneWidget);
  });

  testWidgets('filters scrutins by search query', (tester) async {
    final repository = FakeScrutinRepository(
      scrutinsByPage: {
        1: const PaginatedScrutins(
          scrutins: [sampleScrutin, sampleScrutinWithDifferentResult],
          currentPage: 1,
          lastPage: 1,
        ),
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scrutinRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: ScrutinsPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(SearchBar), 'budget');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Budget Defense'), findsOneWidget);
    expect(find.text('Loi Climat'), findsNothing);
    expect(find.text('Résultats pour "budget"'), findsOneWidget);
  });
}