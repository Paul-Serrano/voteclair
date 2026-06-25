import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/deputy_comparison.dart';

class ComparisonDifferenceTile extends StatelessWidget {
  const ComparisonDifferenceTile({
    required this.difference,
    required this.leftName,
    required this.rightName,
    this.onTap,
    super.key,
  });

  final ComparisonDifference difference;
  final String leftName;
  final String rightName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isAgreement = difference.leftVote.toUpperCase() == difference.rightVote.toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(
          difference.titre,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text('n${difference.numero} • ${_sortLabel(difference.scrutinSort)} • ${_importanceLabel(difference.importanceScore)}'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _AgreementBadge(isAgreement: isAgreement),
              ],
            ),
            const SizedBox(height: 4),
            Text('$leftName: ${_positionLabel(difference.leftVote)}'),
            Text('$rightName: ${_positionLabel(difference.rightVote)}'),
            if (difference.date != null)
              Text(
                DateFormat('d MMM yyyy', 'fr_FR').format(difference.date!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  String _positionLabel(String value) {
    return switch (value.toUpperCase()) {
      'POUR' => 'Pour',
      'CONTRE' => 'Contre',
      'ABSTENTION' => 'Abstention',
      'NON_VOTANT' => 'Non votant',
      _ => value,
    };
  }

  String _sortLabel(String? value) {
    return switch ((value ?? '').toUpperCase()) {
      'ADOPTE' => 'Adopte',
      'REJETE' => 'Rejete',
      _ => '-',
    };
  }

  String _importanceLabel(int score) {
    if (score >= 150) {
      return 'Tres important';
    }
    if (score >= 100) {
      return 'Important';
    }

    return 'Standard';
  }
}

class _AgreementBadge extends StatelessWidget {
  const _AgreementBadge({required this.isAgreement});

  final bool isAgreement;

  @override
  Widget build(BuildContext context) {
    final bg = isAgreement ? const Color(0xFFDFF5E6) : const Color(0xFFFFE3E3);
    final fg = isAgreement ? const Color(0xFF1C6B3F) : const Color(0xFF9B1C1C);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Text(
        isAgreement ? 'Accord' : 'Desaccord',
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
