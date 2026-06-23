import 'package:flutter/material.dart';

import '../../domain/entities/dashboard_group.dart';

class DashboardGroupTile extends StatelessWidget {
  const DashboardGroupTile({
    required this.group,
    required this.onTap,
    super.key,
  });

  final DashboardGroup group;
  final VoidCallback onTap;

  Color? _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupColor = _parseColor(group.couleur);

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: groupColor ?? Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              group.nom.isNotEmpty ? group.nom[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        title: Text(
          group.nom,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          '${group.membersCount} membre${group.membersCount > 1 ? 's' : ''}',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
