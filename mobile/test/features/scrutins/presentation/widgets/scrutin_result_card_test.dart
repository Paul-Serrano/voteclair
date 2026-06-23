import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voteclair_mobile/features/scrutins/presentation/widgets/scrutin_result_card.dart';

import '../../../../helpers/scrutin_fixtures.dart';

void main() {
  testWidgets('renders result card and progress bars', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ScrutinResultCard(scrutin: sampleScrutin),
        ),
      ),
    );

    expect(find.text('Résultat'), findsOneWidget);
    expect(find.text('Adopté'), findsOneWidget);
    expect(find.text('POUR'), findsWidgets);
    expect(find.text('CONTRE'), findsWidgets);
    expect(find.text('ABSTENTION'), findsWidgets);
  });
}
