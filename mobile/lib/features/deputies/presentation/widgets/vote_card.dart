import 'package:flutter/material.dart';

import '../../domain/entities/deputy_vote.dart';

class VoteCard extends StatelessWidget {
  const VoteCard({required this.vote, this.onTap, super.key});

  final DeputyVote vote;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badge = _positionBadge(vote.position);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                    const Chip(
                      label: Text('Vote par delegation'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (vote.scrutin.numero != null)
                Text(
                  'Scrutin n${vote.scrutin.numero}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              const SizedBox(height: 4),
              Text(
                vote.scrutin.titre.isEmpty
                    ? 'Titre indisponible'
                    : vote.scrutin.titre,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${_formatDate(vote.scrutin.date)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 2),
              Text(
                'Resultat: ${_formatResult(vote.scrutin.sort)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _PositionBadge _positionBadge(String rawPosition) {
    final position = rawPosition.toUpperCase();
    switch (position) {
      case 'POUR':
        return const _PositionBadge(
          label: '🟢 POUR',
          backgroundColor: Color(0xFFE6F4EA),
          borderColor: Color(0xFF53A56A),
        );
      case 'CONTRE':
        return const _PositionBadge(
          label: '🔴 CONTRE',
          backgroundColor: Color(0xFFFDECEA),
          borderColor: Color(0xFFD06A5F),
        );
      case 'ABSTENTION':
        return const _PositionBadge(
          label: '🟡 ABSTENTION',
          backgroundColor: Color(0xFFFFF8E1),
          borderColor: Color(0xFFC9AB49),
        );
      case 'NON_VOTANT':
        return const _PositionBadge(
          label: '⚪ NON VOTANT',
          backgroundColor: Color(0xFFF1F3F4),
          borderColor: Color(0xFF9AA0A6),
        );
      default:
        return _PositionBadge(
          label: rawPosition.isEmpty ? 'Position inconnue' : rawPosition,
          backgroundColor: const Color(0xFFF3F3F3),
          borderColor: const Color(0xFFC7C7C7),
        );
    }
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) {
      return '-';
    }

    return rawDate;
  }

  String _formatResult(String? rawSort) {
    final value = (rawSort ?? '').trim().toUpperCase();
    switch (value) {
      case 'ADOPTE':
        return 'adopte';
      case 'REJETE':
        return 'rejete';
      default:
        return '-';
    }
  }
}

class _PositionBadge {
  const _PositionBadge({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color borderColor;
}
