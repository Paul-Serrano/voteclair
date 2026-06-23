import 'package:flutter/material.dart';

import '../../domain/entities/scrutin_vote.dart';

class ScrutinVoteCard extends StatelessWidget {
  const ScrutinVoteCard({required this.vote, super.key});

  final ScrutinVote vote;

  @override
  Widget build(BuildContext context) {
    final badge = _badgeFor(vote.position);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  label: Text(badge.label),
                  backgroundColor: badge.backgroundColor,
                  side: BorderSide(color: badge.borderColor),
                ),
                if (vote.delegated)
                  const Chip(label: Text('Vote par délégation')),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              vote.deputy.fullName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(vote.deputy.groupName ?? 'Groupe inconnu'),
          ],
        ),
      ),
    );
  }

  _Badge _badgeFor(String position) {
    switch (position.toUpperCase()) {
      case 'POUR':
        return const _Badge(
          label: '🟢 POUR',
          backgroundColor: Color(0xFFE6F4EA),
          borderColor: Color(0xFF53A56A),
        );
      case 'CONTRE':
        return const _Badge(
          label: '🔴 CONTRE',
          backgroundColor: Color(0xFFFDECEA),
          borderColor: Color(0xFFD06A5F),
        );
      case 'ABSTENTION':
        return const _Badge(
          label: '🟡 ABSTENTION',
          backgroundColor: Color(0xFFFFF8E1),
          borderColor: Color(0xFFC9AB49),
        );
      case 'NON_VOTANT':
        return const _Badge(
          label: '⚪ NON VOTANT',
          backgroundColor: Color(0xFFF1F3F4),
          borderColor: Color(0xFF9AA0A6),
        );
      default:
        return _Badge(
          label: position.isEmpty ? 'Position inconnue' : position,
          backgroundColor: const Color(0xFFF3F3F3),
          borderColor: const Color(0xFFC7C7C7),
        );
    }
  }
}

class _Badge {
  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color borderColor;
}
