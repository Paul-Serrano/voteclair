import 'package:flutter/material.dart';

import '../../domain/entities/scrutin.dart';

class ScrutinHeader extends StatelessWidget {
  const ScrutinHeader({required this.scrutin, super.key});

  final Scrutin scrutin;

  @override
  Widget build(BuildContext context) {
    final institution = scrutin.institution;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (scrutin.numero != null)
              Text(
                'Scrutin n${scrutin.numero}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            const SizedBox(height: 4),
            Text(
              scrutin.titre,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _InfoChip(label: 'Date', value: scrutin.date ?? '-'),
                _InfoChip(
                  label: 'Institution',
                  value: institution == null ? '-' : institution.nom,
                ),
                _InfoChip(
                  label: 'Resultat',
                  value: _formatSort(scrutin.sort),
                ),
              ],
            ),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
    );
  }
}
