import 'package:flutter/material.dart';

import '../../domain/entities/scrutin.dart';

class ScrutinGroupStatsCard extends StatelessWidget {
  const ScrutinGroupStatsCard({required this.scrutin, super.key});

  final Scrutin scrutin;

  @override
  Widget build(BuildContext context) {
    if (scrutin.groupes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Votes par groupe', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text('${scrutin.groupes.length} groupes', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            ...scrutin.groupes.map(
              (group) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _GroupStatTile(group: group),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupStatTile extends StatelessWidget {
  const _GroupStatTile({required this.group});

  final ScrutinGroupStat group;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(group.couleur);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  group.nom,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Text('Total ${group.total}'),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CountChip(label: 'POUR', value: group.pour, color: const Color(0xFF4CAF50)),
              _CountChip(label: 'CONTRE', value: group.contre, color: const Color(0xFFF44336)),
              _CountChip(label: 'ABSTENTION', value: group.abstention, color: const Color(0xFFFFC107)),
              _CountChip(label: 'NON VOTANT', value: group.nonVotant, color: const Color(0xFF9E9E9E)),
            ],
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const Color(0xFF607D8B);
    }

    final hex = value.trim().replaceFirst('#', '').toUpperCase();
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }

    return const Color(0xFF607D8B);
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.25)),
      label: Text('$label: $value'),
    );
  }
}