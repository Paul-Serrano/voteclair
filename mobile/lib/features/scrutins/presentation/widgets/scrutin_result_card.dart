import 'package:flutter/material.dart';

import '../../domain/entities/scrutin.dart';

class ScrutinResultCard extends StatelessWidget {
  const ScrutinResultCard({required this.scrutin, super.key});

  final Scrutin scrutin;

  @override
  Widget build(BuildContext context) {
    final resultats = scrutin.resultats;
    final total = resultats.total <= 0 ? 1 : resultats.total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Résultat', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Chip(label: Text(_formatSort(scrutin.sort))),
              ],
            ),
            const SizedBox(height: 16),
            _Bar(label: 'POUR', value: resultats.pour, total: total, color: const Color(0xFF4CAF50)),
            const SizedBox(height: 10),
            _Bar(label: 'CONTRE', value: resultats.contre, total: total, color: const Color(0xFFF44336)),
            const SizedBox(height: 10),
            _Bar(label: 'ABSTENTION', value: resultats.abstention, total: total, color: const Color(0xFFFFC107)),
            const SizedBox(height: 10),
            _Bar(label: 'NON VOTANT', value: resultats.nonVotant, total: total, color: const Color(0xFF9E9E9E)),
            const SizedBox(height: 12),
            Text('Total: ${resultats.total}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  String _formatSort(String? sort) {
    switch ((sort ?? '').toUpperCase()) {
      case 'ADOPTE':
        return 'Adopté';
      case 'REJETE':
        return 'Rejeté';
      default:
        return '-';
    }
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.value, required this.total, required this.color});

  final String label;
  final int value;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 110, child: Text(label)),
            Text('$value'),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: total == 0 ? 0 : value / total,
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}
