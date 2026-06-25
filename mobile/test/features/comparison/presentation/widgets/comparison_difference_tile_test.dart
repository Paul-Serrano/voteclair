import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voteclair_mobile/features/comparison/domain/entities/deputy_comparison.dart';
import 'package:voteclair_mobile/features/comparison/presentation/widgets/comparison_difference_tile.dart';

void main() {
  group('ComparisonDifferenceTile', () {
    testWidgets('shows Accord badge when votes match', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ComparisonDifferenceTile(
              difference: ComparisonDifference(
                scrutinId: 'scr-1',
                numero: 120,
                titre: 'Accord test',
                importanceScore: 120,
                leftVote: 'POUR',
                rightVote: 'POUR',
                scrutinSort: 'ADOPTE',
              ),
              leftName: 'Jean Dupont',
              rightName: 'Marie Durand',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Accord'), findsOneWidget);
      expect(find.text('Desaccord'), findsNothing);
    });

    testWidgets('shows Desaccord badge when votes differ', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ComparisonDifferenceTile(
              difference: ComparisonDifference(
                scrutinId: 'scr-2',
                numero: 121,
                titre: 'Desaccord test',
                importanceScore: 80,
                leftVote: 'POUR',
                rightVote: 'CONTRE',
                scrutinSort: 'REJETE',
              ),
              leftName: 'Jean Dupont',
              rightName: 'Marie Durand',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Desaccord'), findsOneWidget);
      expect(find.text('Accord'), findsNothing);
    });
  });
}
