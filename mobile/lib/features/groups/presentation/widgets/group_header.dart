import 'package:flutter/material.dart';

import '../../domain/entities/group.dart';

class GroupHeader extends StatelessWidget {
  const GroupHeader({required this.group, super.key});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final accent = _toColor(group.couleur) ?? Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: accent.withValues(alpha: 0.15),
              foregroundImage: _networkImageOrNull(group.logoUrl),
              child: Icon(Icons.groups, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.nom,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(group.nomComplet),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(_positionLabel(group.position)),
                        side: BorderSide(color: accent.withValues(alpha: 0.5)),
                        avatar: Icon(Icons.flag_outlined, color: accent, size: 18),
                      ),
                      Chip(
                        label: Text('${group.membresCount} membres'),
                        avatar: Icon(Icons.people_alt_outlined, color: accent, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider<Object>? _networkImageOrNull(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    return NetworkImage(url);
  }

  Color? _toColor(String? hex) {
    if (hex == null || hex.trim().isEmpty) {
      return null;
    }

    final normalized = hex.replaceFirst('#', '').trim();
    if (normalized.length != 6) {
      return null;
    }

    final value = int.tryParse('FF$normalized', radix: 16);
    if (value == null) {
      return null;
    }

    return Color(value);
  }

  String _positionLabel(String? position) {
    switch ((position ?? '').toUpperCase()) {
      case 'EXTREME_GAUCHE':
        return 'Extreme gauche';
      case 'GAUCHE':
        return 'Gauche';
      case 'CENTRE_GAUCHE':
        return 'Centre gauche';
      case 'CENTRE':
        return 'Centre';
      case 'CENTRE_DROIT':
        return 'Centre droit';
      case 'DROITE':
        return 'Droite';
      case 'EXTREME_DROITE':
        return 'Extreme droite';
      default:
        return 'Position inconnue';
    }
  }
}
