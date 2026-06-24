import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../deputies/domain/entities/deputy.dart';

class FavoriteDeputyTile extends StatelessWidget {
  const FavoriteDeputyTile({required this.deputy, super.key});

  final Deputy deputy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.push('/deputies/${deputy.slug}'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundImage: _networkImageOrNull(deputy.photoUrl),
          child: const Icon(Icons.person_outline),
        ),
        title: Text(
          deputy.fullName,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _GroupColorDot(colorHex: deputy.groupColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    deputy.groupName ?? 'Groupe inconnu',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (deputy.statsPresence != null)
                  _StatBadge(
                    label: 'Présence',
                    value: '${deputy.statsPresence}%',
                    color: _presenceColor(deputy.statsPresence!),
                  ),
                if (deputy.statsLoyaute != null)
                  _StatBadge(
                    label: 'Loyauté',
                    value: '${deputy.statsLoyaute}%',
                    color: Colors.blue,
                  ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  ImageProvider<Object>? _networkImageOrNull(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    return NetworkImage(url);
  }

  Color _presenceColor(int presence) {
    if (presence >= 75) return Colors.green;
    if (presence >= 50) return Colors.orange;
    return Colors.red;
  }
}

class _GroupColorDot extends StatelessWidget {
  const _GroupColorDot({required this.colorHex});

  final String? colorHex;

  @override
  Widget build(BuildContext context) {
    final color = _toColor(colorHex) ?? Theme.of(context).colorScheme.outline;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Color? _toColor(String? hex) {
    if (hex == null || hex.trim().isEmpty) return null;
    final normalized = hex.replaceFirst('#', '').trim();
    if (normalized.length != 6) return null;
    final value = int.tryParse('FF$normalized', radix: 16);
    return value == null ? null : Color(value);
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$label $value',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
