import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voteclair_mobile/features/scrutins/presentation/widgets/scrutin_group_stats_card.dart';

import '../../../../helpers/scrutin_fixtures.dart';

void main() {
  testWidgets('renders group stats cards', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ScrutinGroupStatsCard(scrutin: sampleScrutin),
        ),
      ),
    );

    expect(find.text('Votes par groupe'), findsOneWidget);
    expect(find.text('Groupe du Centre'), findsOneWidget);
    expect(find.text('Groupe de Gauche'), findsOneWidget);
  });
}