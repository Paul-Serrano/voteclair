import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/dashboard_scrutin.dart';

class DashboardScrutinTile extends StatelessWidget {
  const DashboardScrutinTile({
    required this.scrutin,
    required this.onTap,
    super.key,
  });

  final DashboardScrutin scrutin;
  final VoidCallback onTap;

  ({String label, Color background, Color foreground}) _sortConfig(
    String sort,
    BuildContext context,
  ) {
    final normalized = sort.toUpperCase();

    return switch (normalized) {
      'ADOPTE' || 'ADOPTÉ' => (
          label: 'Adopté',
          background: const Color(0xFFE6F4EA),
          foreground: const Color(0xFF196C2E),
        ),
      'REJETE' || 'REJETÉ' => (
          label: 'Rejeté',
          background: const Color(0xFFFDECEA),
          foreground: const Color(0xFFB42318),
        ),
      _ => (
          label: sort,
          background: Theme.of(context).colorScheme.surfaceContainerHighest,
          foreground: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final sortConfig = _sortConfig(scrutin.sort, context);
    final dateFormat = DateFormat('d MMM yyyy', 'fr_FR');
    final formattedDate = dateFormat.format(scrutin.date);

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: sortConfig.background,
          child: Text(
            scrutin.numero.toString(),
            style: TextStyle(
              color: sortConfig.foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          scrutin.titre,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text(formattedDate),
            const SizedBox(height: 4),
            Chip(
              label: Text(sortConfig.label),
              backgroundColor: sortConfig.background,
              side: BorderSide(
                color: sortConfig.foreground.withValues(alpha: 0.3),
              ),
              labelStyle: TextStyle(
                color: sortConfig.foreground,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
