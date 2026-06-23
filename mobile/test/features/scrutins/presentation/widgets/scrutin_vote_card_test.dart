import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voteclair_mobile/features/scrutins/presentation/widgets/scrutin_vote_card.dart';

import '../../../../helpers/scrutin_fixtures.dart';

void main() {
  testWidgets('renders deputy name, group and vote badge', (tester) async {
    final vote = makeScrutinVote(
      position: 'POUR',
      deputySlug: 'jean-dupont',
      nom: 'Dupont',
      prenom: 'Jean',
      groupName: 'Groupe du Centre',
      delegated: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScrutinVoteCard(vote: vote),
        ),
      ),
    );

    expect(find.text('🟢 POUR'), findsOneWidget);
    expect(find.text('Vote par délégation'), findsOneWidget);
    expect(find.text('Jean Dupont'), findsOneWidget);
    expect(find.text('Groupe du Centre'), findsOneWidget);
  });
}
