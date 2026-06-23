import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voteclair_mobile/features/deputies/domain/entities/deputy_vote.dart';
import 'package:voteclair_mobile/features/deputies/presentation/widgets/vote_card.dart';

void main() {
  testWidgets('renders vote content and visual badge for POUR', (tester) async {
    const vote = DeputyVote(
      position: 'POUR',
      delegated: true,
      scrutin: DeputyVoteScrutin(
        id: 'scrutin-1',
        numero: 7407,
        titre: 'Projet de loi climat',
        date: '2026-06-16',
        sort: 'ADOPTE',
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VoteCard(vote: vote),
        ),
      ),
    );

    expect(find.text('🟢 POUR'), findsOneWidget);
    expect(find.text('Vote par delegation'), findsOneWidget);
    expect(find.text('Projet de loi climat'), findsOneWidget);
    expect(find.text('Date: 2026-06-16'), findsOneWidget);
    expect(find.text('Resultat: adopte'), findsOneWidget);
  });
}
