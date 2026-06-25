import 'package:flutter/material.dart';

import '../../domain/entities/deputy_comparison.dart';

class ComparisonSummaryCard extends StatelessWidget {
  const ComparisonSummaryCard({required this.comparison, super.key});

  final DeputyComparison comparison;

  @override
  Widget build(BuildContext context) {
    final stats = comparison.stats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${comparison.left.fullName} vs ${comparison.right.fullName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatChip(label: 'Votes communs', value: '${stats.commonVotes}'),
                _StatChip(label: 'Accords', value: '${stats.agreements}'),
                _StatChip(label: 'Desaccords', value: '${stats.disagreements}'),
                _StatChip(label: 'Abstentions communes', value: '${stats.sameAbstentions}'),
                _StatChip(label: 'Taux d\'accord', value: '${stats.agreementRate.toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
      label: Text('$label: $value'),
    );
  }
}
