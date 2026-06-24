import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/activity_item.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    required this.item,
    this.onTap,
    this.compact = false,
    super.key,
  });

  final ActivityItem item;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final badge = _positionBadge(item.latestVote.position, context);
    final date = item.latestVote.scrutin.date;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: compact ? 18 : 22,
                backgroundImage: item.deputy.photoUrl != null && item.deputy.photoUrl!.isNotEmpty
                    ? NetworkImage(item.deputy.photoUrl!)
                    : null,
                child: item.deputy.photoUrl == null || item.deputy.photoUrl!.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.deputy.fullName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: badge.background,
                          side: BorderSide(color: badge.foreground.withValues(alpha: 0.35)),
                          label: Text(
                            badge.label,
                            style: TextStyle(
                              color: badge.foreground,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (date != null)
                          Text(
                            DateFormat('d MMM yyyy - HH:mm', 'fr_FR').format(date),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.latestVote.scrutin.titre,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Padding(
                  padding: EdgeInsets.only(left: 6, top: 2),
                  child: Icon(Icons.chevron_right),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _PositionVisual _positionBadge(String position, BuildContext context) {
    final normalized = position.toUpperCase();

    return switch (normalized) {
      'POUR' => const _PositionVisual(
          label: '🟢 POUR',
          background: Color(0xFFE6F4EA),
          foreground: Color(0xFF196C2E),
        ),
      'CONTRE' => const _PositionVisual(
          label: '🔴 CONTRE',
          background: Color(0xFFFDECEA),
          foreground: Color(0xFFB42318),
        ),
      'ABSTENTION' => const _PositionVisual(
          label: '🟡 ABSTENTION',
          background: Color(0xFFFFF3D6),
          foreground: Color(0xFF8A5A00),
        ),
      _ => _PositionVisual(
          label: '⚪ NON VOTANT',
          background: Theme.of(context).colorScheme.surfaceContainerHighest,
          foreground: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
    };
  }
}

class _PositionVisual {
  const _PositionVisual({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}
